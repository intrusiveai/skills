#!/usr/bin/env bash
# Offline integration checks; all installation writes stay in a temporary directory.
set -eo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
installer=$repo_dir/install.sh
test_root=$(mktemp -d "${TMPDIR:-/tmp}/sandbox-skills-install.XXXXXX")
trap 'rm -rf -- "$test_root"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
skills=(interceptor-sandbox-management operator-sandbox-management scenario-bundle-generation attack-simulation-results-reporting)
checks=0

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { checks=$((checks + 1)); printf 'ok %s - %s\n' "$checks" "$*"; }
expect_failure() {
  local expected=$1 actual=0
  shift
  "$@" > "$test_root/error.log" 2>&1 || actual=$?
  [[ "$actual" == "$expected" ]] || fail "Expected exit $expected, got $actual: $*"
}
assert_copy() {
  diff -r -- "$repo_dir/${2//-/_}" "$1/$2" || fail "Incomplete copy: $1/$2"
}

"$installer" --list > "$test_root/list"
printf '%s\n' "${skills[@]}" > "$test_root/expected-list"
cmp "$test_root/list" "$test_root/expected-list"
"$installer" --help > "$test_root/help"
pass 'help and skill listing'

mkdir "$test_root/project"
"$installer" --target both --project-dir "$test_root/project" > "$test_root/install.log"
for harness in .agents .claude; do
  for skill in "${skills[@]}"; do assert_copy "$test_root/project/$harness/skills" "$skill"; done
done
pass 'both harnesses receive every skill, reference, and asset byte'

mkdir -p "$test_root/selected/.claude/skills/unrelated"
printf 'local content\n' > "$test_root/selected/.claude/skills/unrelated/SKILL.md"
"$installer" --target claude --project-dir "$test_root/selected" --skill "${skills[3]}" --skill "${skills[3]}" > "$test_root/install.log"
assert_copy "$test_root/selected/.claude/skills" "${skills[3]}"
[[ ! -e "$test_root/selected/.agents" && ! -e "$test_root/selected/.claude/skills/${skills[0]}" ]]
[[ $(cat "$test_root/selected/.claude/skills/unrelated/SKILL.md") == 'local content' ]]
pass 'skill selection, duplicate selection, and unrelated skills'

mkdir "$test_root/preview"
"$installer" --target both --project-dir "$test_root/preview" --dry-run > "$test_root/preview.log"
[[ -z $(find "$test_root/preview" -mindepth 1 -print) ]]
[[ $(grep -c 'Would copy' "$test_root/preview.log") == 8 ]]
pass 'dry run previews all destinations without creating files'

custom="$test_root/custom skills \$(literal)"
(cd "$test_root" && "$installer" --dest="$custom" --skill "${skills[2]}") > "$test_root/install.log"
assert_copy "$custom" "${skills[2]}"
pass 'custom destination, spaces, literal shell characters, and different working directory'

expect_failure 1 "$installer" --dest "$custom" --skill "${skills[2]}"
assert_copy "$custom" "${skills[2]}"
mkdir -p "$test_root/conflict/.claude/skills/${skills[3]}"
printf 'local edits\n' > "$test_root/conflict/.claude/skills/${skills[3]}/SKILL.md"
expect_failure 1 "$installer" --target both --project-dir "$test_root/conflict"
[[ ! -e "$test_root/conflict/.agents" ]]
[[ $(cat "$test_root/conflict/.claude/skills/${skills[3]}/SKILL.md") == 'local edits' ]]
pass 'repeat installs and second-target conflicts leave existing files unchanged'

mkdir -p "$test_root/legacy/${skills[0]//-/_}"
expect_failure 1 "$installer" --dest "$test_root/legacy"
[[ ! -e "$test_root/legacy/${skills[0]}" ]]
pass 'underscore-named installations also prevent duplicate installation'

mkdir -p "$test_root/links" "$test_root/unrelated"
printf 'keep\n' > "$test_root/unrelated/keep"
ln -s "$test_root/unrelated" "$test_root/links/${skills[0]}"
expect_failure 1 "$installer" --dest "$test_root/links"
[[ $(cat "$test_root/unrelated/keep") == keep ]]
ln -s "$test_root/missing" "$test_root/links/${skills[1]}"
expect_failure 1 "$installer" --dest "$test_root/links" --skill "${skills[1]}"
pass 'existing and dangling destination skill symlinks are not followed'

expect_failure 1 "$installer" --target codex --project-dir "$test_root/missing-project"
printf 'file\n' > "$test_root/file"
expect_failure 1 "$installer" --dest "$test_root/file/skills"
expect_failure 1 "$installer" --dest "$repo_dir/${skills[0]//-/_}/nested"
[[ ! -e "$repo_dir/${skills[0]//-/_}/nested" ]]
pass 'missing projects, file parents, and recursive source destinations are rejected'

expect_failure 2 "$installer"
expect_failure 2 "$installer" --target other
expect_failure 2 "$installer" --target codex --dest "$test_root/invalid"
expect_failure 2 "$installer" --dest "$test_root/invalid" --project-dir "$test_root/project"
expect_failure 2 "$installer" --dest "$test_root/invalid" --skill ../bad
expect_failure 2 "$installer" --target
expect_failure 2 "$installer" --dest ''
pass 'invalid arguments fail before writing'

mkdir "$test_root/bin"
cat > "$test_root/bin/cp" <<'STUB'
#!/usr/bin/env bash
case "$3" in
  */operator_sandbox_management/.)
    printf 'partial\n' > "$4/partial"
    exit 1 ;;
esac
exec /bin/cp "$@"
STUB
chmod +x "$test_root/bin/cp"
expect_failure 1 env PATH="$test_root/bin:$PATH" "$installer" --dest "$test_root/interrupted" --skill "${skills[0]}" --skill "${skills[1]}"
assert_copy "$test_root/interrupted" "${skills[0]}"
[[ ! -e "$test_root/interrupted/${skills[1]}" ]]
pass 'copy failure removes only the partial skill and preserves completed installs'

# Exercise user-scope selection without changing HOME or writing user files.
for harness in codex claude; do
  status=0
  "$installer" --target "$harness" --skill "${skills[2]}" --dry-run > "$test_root/user.log" 2>&1 || status=$?
  case "$harness" in codex) directory=.agents ;; claude) directory=.claude ;; esac
  [[ "$status" == 0 || "$status" == 1 ]]
  grep -F "/$directory/skills/" "$test_root/user.log" > /dev/null
  if [[ "$status" == 1 ]]; then grep -F 'Already exists:' "$test_root/user.log" > /dev/null; fi
done
pass 'user-scope paths checked using dry runs only'

printf '%s installer checks passed.\n' "$checks"
