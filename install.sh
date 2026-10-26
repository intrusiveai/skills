#!/usr/bin/env bash
# Copy complete skills into Codex, Claude Code, or custom skill directories.
# Compatible with Bash 3.2 (including the version shipped with macOS).
set -eo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
skills=(
  interceptor-sandbox-management
  operator-sandbox-management
  scenario-bundle-generation
  attack-simulation-results-reporting
)
selected=()
roots=()
sources=()
destinations=()
target='' custom_dest='' project_dir=''
dry_run=false list=false
active_destination=''

usage() {
  cat <<'USAGE'
Usage: ./install.sh --target codex|claude|both [options]
       ./install.sh --dest DIRECTORY [options]
       ./install.sh --list

Install all four skills by default. Existing skill folders are never overwritten.

  --target NAME       Install for codex, claude, or both (user scope by default)
  --project-dir DIR   Install under an existing project instead of your home
  --dest DIR          Custom skills directory; cannot be combined with --target
                     or --project-dir
  --skill NAME        Install only this hyphenated skill name; repeat to select more
  --dry-run           Check and display copies without writing
  --list              List skill names and exit
  -h, --help          Show this help
USAGE
}

fail() { printf 'Installation failed: %s\n' "$*" >&2; exit 1; }
arg_error() { printf 'Argument error: %s\n' "$*" >&2; exit 2; }

# Resolve existing parents without creating directories or requiring GNU realpath.
canonical_path() {
  local input=$1 parent leaf
  case "$input" in
    '~') input=$HOME ;;
    '~/'*) input=$HOME/${input:2} ;;
  esac
  case "$input" in /*) ;; *) input=$PWD/$input ;; esac
  if [[ -d "$input" ]]; then
    (cd -- "$input" && pwd -P)
  else
    [[ ! -e "$input" && ! -L "$input" ]] || fail "Destination parent is not a directory: $input"
    parent=$(canonical_path "$(dirname -- "$input")") || return
    leaf=$(basename -- "$input")
    case "$leaf" in
      .) printf '%s\n' "$parent" ;;
      ..) dirname -- "$parent" ;;
      *) printf '%s/%s\n' "${parent%/}" "$leaf" ;;
    esac
  fi
}

cleanup() {
  if [[ -n "$active_destination" ]]; then
    rm -rf -- "$active_destination"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

while (( $# )); do
  case "$1" in --*=*) set -- "${1%%=*}" "${1#*=}" "${@:2}" ;; esac
  case "$1" in
    --target|--dest|--project-dir|--skill)
      (( $# >= 2 )) && [[ -n "$2" && "$2" != --* ]] || arg_error "$1 needs a value"
      case "$1" in
        --target) target=$2 ;;
        --dest) custom_dest=$2 ;;
        --project-dir) project_dir=$2 ;;
        --skill)
          valid=false
          for name in "${skills[@]}"; do [[ "$2" != "$name" ]] || valid=true; done
          $valid || arg_error "Unknown skill: $2 (see --list)"
          duplicate=false
          for name in "${selected[@]}"; do [[ "$2" != "$name" ]] || duplicate=true; done
          $duplicate || selected+=("$2")
          ;;
      esac
      shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    --list) list=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) arg_error "Unknown option: $1 (see --help)" ;;
  esac
done

if $list; then printf '%s\n' "${skills[@]}"; exit 0; fi
[[ -n "$target" || -n "$custom_dest" ]] || arg_error 'Choose --target or --dest'
[[ -z "$custom_dest" || ( -z "$target" && -z "$project_dir" ) ]] || arg_error '--dest cannot be combined with --target or --project-dir'
if [[ -n "$target" ]]; then
  case "$target" in codex|claude|both) ;; *) arg_error "Unknown target: $target" ;; esac
fi
(( ${#selected[@]} )) || selected=("${skills[@]}")

if [[ -n "$custom_dest" ]]; then
  roots+=("$(canonical_path "$custom_dest")")
else
  if [[ -n "$project_dir" ]]; then
    base=$(canonical_path "$project_dir")
    [[ -d "$base" ]] || fail "Project directory does not exist: $base"
  else
    [[ -n "${HOME:-}" ]] || fail 'HOME is unset; use --project-dir or --dest'
    base=$HOME
  fi
  if [[ "$target" == codex || "$target" == both ]]; then
    roots+=("$(canonical_path "$base/.agents/skills")")
  fi
  if [[ "$target" == claude || "$target" == both ]]; then
    roots+=("$(canonical_path "$base/.claude/skills")")
  fi
fi

# Check every source and destination before writing any part of the installation.
for root in "${roots[@]}"; do
  for name in "${selected[@]}"; do
    source_dir=$repo_dir/${name//-/_}
    destination=$root/$name
    [[ ! -L "$source_dir" && -f "$source_dir/SKILL.md" ]] || fail "Missing regular source skill: $source_dir"
    unsupported=$(find "$source_dir" ! -type f ! -type d -print)
    [[ -z "$unsupported" ]] || fail "Unsupported source entry: $unsupported"
    for candidate in "$destination" "$root/${name//-/_}"; do
      [[ ! -e "$candidate" && ! -L "$candidate" ]] || fail "Already exists: $candidate
Move the previous skill outside the skills directory before reinstalling."
    done
    case "$root/" in "$source_dir/"*) fail "Cannot install a skill inside its source: $root" ;; esac
    sources+=("$source_dir")
    destinations+=("$destination")
  done
done

for ((i=0; i<${#sources[@]}; i++)); do
  source_dir=${sources[i]}
  destination=${destinations[i]}
  if $dry_run; then
    printf 'Would copy %s -> %s\n' "${source_dir##*/}" "$destination"
  else
    mkdir -p -- "$(dirname -- "$destination")"
    # Reserve exclusively; cleanup owns only the directory created by this process.
    mkdir -- "$destination"
    active_destination=$destination
    cp -R -- "$source_dir/." "$destination/" || fail "Could not copy $source_dir"
    active_destination=''
    printf 'Installed %s\n' "$destination"
  fi
done
if $dry_run; then
  printf 'Dry run complete; no files written.\n'
else
  printf 'Open a new harness session and select a skill by its installed name.\n'
fi
