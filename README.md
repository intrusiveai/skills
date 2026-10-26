# INTRUSIVE.AI Sandbox Skills

Skills for AI coding assistants that help prepare application test environments,
configure and run attack simulation campaigns, author scenario bundles, and produce
evidence-based security review reports.

These are instructions and supporting resources for your assistant. Installing
them does not install the sandbox products, configure credentials, or run a campaign.

## The skills

| Skill | Purpose | Example request |
| --- | --- | --- |
| [Interceptor Sandbox management](interceptor_sandbox_management/SKILL.md) | Install and configure Interceptor, create application environment Blueprints, and manage sessions, snapshots, and evidence. | “Prepare an Interceptor Blueprint for this application and validate it.” |
| [Operator Sandbox management](operator_sandbox_management/SKILL.md) | Install and configure Operator and compatible Attack Harness; prepare target profiles and inputs; execute, inspect, and terminate campaigns. | “Configure Operator for this target and prepare a campaign using this bundle.” |
| [Scenario bundle generation](scenario_bundle_generation/SKILL.md) | Turn user-selected objectives and scenarios into a functional bundle with capability references and supporting artifacts. It prescribes no scenario catalog or attack techniques. | “Create a bundle from these objectives and the exported target capabilities.” |
| [Attack simulation results reporting](attack_simulation_results_reporting/SKILL.md) | Produce portable HTML security review reports covering configuration, application context, bundle coverage, scenario results, evidence, and justified recommendations. | “Generate an HTML security review from this retained campaign export.” |

Each skill has a short `SKILL.md` entry point and focused references loaded when
needed. The reporting skill also includes HTML, CSS, and JavaScript assets matching
the INTRUSIVE.AI website theme.

A typical workflow is to prepare an Interceptor environment, author a bundle from
its exported capabilities, execute it through Operator and Attack Harness, and
report on retained evidence. You can start with an existing environment, bundle,
or completed campaign; the skills work independently. Operator also supports
configured HTTPS targets without an Interceptor environment.

## Install for Codex CLI or Claude Code

The installer needs Bash 3.2 or newer, standard Unix utilities, and a local copy
of this repository. It works with the Bash shipped on macOS and on Linux; on
Windows, use WSL. It needs no Python and makes no network requests. Git is needed
only if you clone the repository rather than download it.

```sh
git clone https://github.com/intrusiveai/skills.git
cd skills
./install.sh --help
```

### Install for your user account

Choose one harness, or install for both:

```sh
./install.sh --target codex
./install.sh --target claude
./install.sh --target both
```

These are alternatives; you do not need to run all three commands.

| Harness | User installation | Project installation |
| --- | --- | --- |
| Codex CLI | `~/.agents/skills/<skill-name>/` | `<project>/.agents/skills/<skill-name>/` |
| Claude Code | `~/.claude/skills/<skill-name>/` | `<project>/.claude/skills/<skill-name>/` |

The defaults follow the current [Codex skill locations](https://learn.chatgpt.com/docs/build-skills)
and [Claude Code skill locations](https://code.claude.com/docs/en/skills).
For an installation using a different skill location, pass that directory explicitly
with `--dest`; the installer does not infer custom locations from harness settings.

### Install for one project

Pass an existing project directory. This installs the selected skills under that
project rather than your home directory:

```sh
./install.sh --target both --project-dir /path/to/application
```

Use `--project-dir .` only when the current directory is the intended project.
You can invoke the script by its absolute path from any working directory. Commit
project-installed skills if you want to share them with collaborators.

### Select skills and preview changes

All four skills are installed by default. Use installed names with hyphens to
select a subset; repeat `--skill` to select more than one:

```sh
./install.sh --list
./install.sh --target codex --skill scenario-bundle-generation --dry-run
./install.sh --target claude \
  --skill operator-sandbox-management \
  --skill attack-simulation-results-reporting
```

`--dry-run` checks the planned destinations and prints them without writing files.
The installer copies complete skill folders, including references and assets.
Repository folder names use underscores; installed folders use the hyphenated
`name` from each skill's frontmatter.

Existing selected skill folders cause installation to stop before copying, including
folders using the repository's underscore names. Other installed skills are left
alone. If an I/O error interrupts copying, earlier completed skills may remain;
the failed skill's partial directory is removed.

### Use the installed skills

Open a new session in your working project. Ask your assistant to list available
skills or select the skill explicitly. In Codex, name the skill in your request,
for example:

```text
Use the scenario-bundle-generation skill to create a bundle from these objectives
and ./environment/capabilities.json.
```

In Claude Code, use the installed slash command, for example:

```text
/attack-simulation-results-reporting Generate an HTML security review from ./exports/campaign.
```

Claude Code supports explicit `/skill-name` invocation and automatic selection when
relevant. See its [skill usage documentation](https://code.claude.com/docs/en/skills).
For either harness, provide the relevant application sources, target configuration,
objectives, bundle, run directory, or export with your request. Allow the assistant
access to the local files and tools needed for the requested task.

### Update or remove

Installations are independent copies; updating this checkout does not update them.
To update, obtain the desired repository revision, move the previous selected skill
folders outside the harness's skills directories, then rerun the installer for
those skills. This preserves local edits for comparison. Avoid keeping duplicate
versions under different names inside discovery directories.

To uninstall, remove only this repository's installed skill folders from the chosen
destination, then open a new session. The installer does not change harness settings.

## Other AI harnesses

For a harness supporting directory-based Agent Skills, use its documented skills
directory as a custom destination:

```sh
./install.sh --dest /path/to/harness/skills
./install.sh --dest /path/to/harness/skills --skill interceptor-sandbox-management
```

These illustrate installing all skills or a selected skill; choose one. Keep each
skill's complete directory intact, with `SKILL.md` at its root and references/assets
beside it. Register or enable the skills using that harness's own mechanism.
`--dest` copies files; it does not configure another harness's discovery settings.

Without native skill support, make the folders accessible to the assistant and
instruct it to read the chosen `SKILL.md`, following its relative references as
needed. Avoid pasting every reference into a permanent system prompt. Tool access,
automatic discovery, and execution permissions depend on the harness.

## Component repositories

The skills use the public component repositories as their source of truth:

- [Operator Sandbox](https://github.com/intrusiveai/operator_sandbox): campaign orchestration, configuration, retained results, and exports.
- [Attack Harness](https://github.com/intrusiveai/attack_harness): campaign execution agent managed by Operator.
- [Interceptor Sandbox](https://github.com/intrusiveai/interceptor_sandbox): application environments, target sessions, feedback, and native evidence.

Follow the component release instructions for the task you are performing. Match
documentation and contracts to the selected release or retained campaign; installing
these skills alone does not establish product compatibility or runtime readiness.
These management skills belong in your assistant's skill library; they are not
automatically instructions to submit to the campaign's Attack Harness.

## Installer checks

Run the offline installer checks with Bash:

```sh
bash tests/test_install.sh
```

The tests use temporary directories and do not install skills into your real user
configuration or launch either harness.
