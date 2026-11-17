# Setup and configuration

Use this guide for installing Operator and its compatible Harness, host settings,
and model access. Target-specific work continues in
[campaign preparation](campaign-preparation.md).

## Select compatible installation inputs

Identify the host OS/CPU, intended execution account, local Docker endpoint, and
requested release. Supported hosts are Linux/macOS on AMD64/ARM64, using Docker
Engine on Linux and Docker Desktop on macOS with the matching Linux Harness image.
Remote Docker daemons and cross-architecture emulation are outside this workflow.
See [host runtime profiles](https://github.com/intrusiveai/operator_sandbox/blob/main/HOST_RUNTIME_PROFILES.md)
for actual runtime requirements; a listed baseline is not a patch-version allowlist.

Inspect `operatorctl version` and existing configuration first. Select:

- an Operator release with its complete shared-contract package;
- a locally available Attack Harness image for the matching architecture;
- the exact shared-interface version **and digest** accepted by both components;
- for Interceptor targets, the Interceptor OpenAPI identity approved by Operator.

The Operator/Harness pair is `info.version` and SHA-256 of the exact
`schemas/asyncapi.json` bytes, including formatting and final newline. Existing
`package_version`/`package_digest` fields and `contract.version`/`contract.digest`
carry that interface identity. The distribution package's inventory hash, validator
source revision, and product release version are separate. Read the selected
[Operator lock](https://github.com/intrusiveai/operator_sandbox/blob/main/release/contract-lock.json)
and [Harness lock](https://github.com/intrusiveai/attack_harness/blob/main/build/contract-lock.json);
do not compute compatibility from an archive or whole source tree.

For Interceptor, Operator checks `/v1/contract-version` before attachment, requiring
the compiled version and SHA-256 of complete OpenAPI bytes to match. This is
independent of the target capability digest and product version. Routine setup
does not export or adopt a new contract or change compiled approvals. See
[integration compatibility](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/INTERCEPTOR_CLIENT.md#automatic-integration-compatibility).

Use [Operator releases](https://github.com/intrusiveai/operator_sandbox/releases),
[Harness releases](https://github.com/intrusiveai/attack_harness/releases), and the
matching [Harness integration guide](https://github.com/intrusiveai/attack_harness/blob/main/docs/INTEGRATION.md).
Resolve published versions rather than guessing a latest release. A matching
version label alone does not establish contract compatibility.

Operator does not pull images automatically. Obtain the selected image through
the configured Docker daemon as part of the requested setup, then set
`engine.image` to it. Admission reads the embedded compatibility record and
actual image contents. Do not bypass a mismatch by editing compatibility files
or substituting contract digests.

## Install or upgrade

Follow the selected release's
[installation guide](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/HOST_DISTRIBUTION.md).
Verify the archive against its published checksum, extract into private staging,
and use the staged CLI to check/install the package:

```sh
/absolute/staging/operator_sandbox/bin/operatorctl release check --directory /absolute/staging/operator_sandbox
/absolute/staging/operator_sandbox/bin/operatorctl install \
  --archive /absolute/downloads/SELECTED_ARCHIVE.tar.gz \
  --image SELECTED_LOCAL_HARNESS_IMAGE
```

Replace the placeholders with verified values. Current archives use
`operator_sandbox-v<version>-<os>_<architecture>.tar.gz`, extracting into
`operator_sandbox/`. Older layouts/installers differ; use the newly extracted
installer when upgrading from v0.1.0.

On Linux, the documented account/path provisioning is a separate privileged
step. Docker group access is an explicit administrator choice, not an implicit
side effect of configuration. Service-manager provisioning is only needed for
requested `--service` execution. On macOS, use the logged-in Docker Desktop user;
installation rejects root. Do not introduce a service manager for foreground use.

The installer preserves existing configuration and retained campaigns and writes
a versioned example for comparison. Review and update the selected contract and
profile paths when upgrading. Do not overwrite existing choices or delete older
releases still referenced by workers. Installation does not resume campaigns.

Use source builds only for requested development or source revisions. A plain
`go build` CLI may have empty release contract pins and does not supply a full
installation. If building a package is necessary, follow
[contract publication](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/CONTRACT_PUBLICATION.md)
using a CLI and schemas from the same selected source revision and the independently
approved interface identity. The current release lock pins interface bytes, not an
Operator source commit. Native release builds also include the embedded 1Password
SDK; a standalone development binary is not a verified distribution archive.

## Configure private host settings

Use [host configuration](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/HOST_CONFIGURATION.md)
and the selected release's templates. Default configuration locations are
`/etc/operator/config.yaml` on Linux and
`~/Library/Application Support/Operator/config/config.yaml` on macOS.
Select other files explicitly with an absolute `--config` path.

The configuration and private profiles must be owned by the executing account or
root, have private permissions (normally 0600), and be regular, singly linked
files. Paths inside configuration must be absolute and literal: no tilde,
environment expansion, or shell substitutions. Use the selected account's
private state root consistently.

Configure the existing fields rather than adding a new configuration layer:

- `engine.image` and the exact `contract.directory`, `version`, and `digest`;
- `model.profile_file`, optional default `target.profile_file`, and credential
  configuration when the selected authentication needs it;
- `docker.endpoint` and optionally `docker.executable` for the intended local
  daemon, rather than relying on ambient Docker contexts;
- `state.root`, campaign/harness limits, and storage bounds as required;
- `target.max_operation_timeout_ms`, `operation_timeouts_ms`, and `size_limits`
  for complete-attempt ceilings, request waits, and operating sizes.

All three `contract` fields are required when any is specified. `cache.release_directory`
is accepted only for legacy compatibility and is unused. The strict YAML loader
rejects unknown/duplicate fields, anchors, aliases, coercions, and extra documents;
do not merge examples into duplicate sections.

### Budgets, request waits, and sizes

Use the effective values from `config check`. The current installation defaults are:

| Settings | Defaults |
| --- | --- |
| `spool.max_bytes`, `evidence.max_archive_bytes` | 512 MiB spool; 4 GiB per native evidence archive |
| `journal.max_bytes`, `segment_bytes`, `minimum_free_bytes` | 8 GiB cumulative; 16 MiB segment; 256 MiB free-space floor |
| `limits.max_attempt_admissions`, `max_active_seconds`, `max_model_tokens` | 100 attempts; 1800 seconds; 250000 tokens |
| `limits.max_artifact_bytes`, `max_artifact_objects`, `max_observation_reads` | 1 GiB; 4096 objects; 2000 reads |
| `limits.max_snapshot_admissions`, `max_snapshot_bytes` | 20; 1 GiB; zero disables snapshot creation |
| `limits.harness.max_model_turns`, `max_tool_calls`, `max_tool_calls_per_response` | 300; 2000; 16 |
| `limits.harness.max_invalid_tool_calls`, `max_consecutive_invalid_tool_calls`, `max_no_progress_turns` | 50; 5; 10 |
| `limits.harness.max_read_bytes` | 256 MiB cumulative delivered reference/observation bytes |

Use unquoted decimal integers in YAML. Other loop limits must be positive; zero
does not mean unlimited. The 1800-second campaign lifetime is a hard maximum.
See [Harness execution rules](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/HARNESS_EXECUTION_RULES.md)
for counting semantics. Storage allowances do not reserve physical disk space.

Only overrides need to be supplied:

```yaml
target:
  max_operation_timeout_ms: 120000
operation_timeouts_ms:
  engine.attempt_execute: 120000
  engine.model_generate: 120000
  engine.snapshot_request: 300000
  engine.restore_request: 300000
size_limits:
  direct_input_bytes: 32768
  assessment_bytes: 1048576
  artifact_bytes: 16777216
  artifact_part_bytes: 262144
  observation_chunk_bytes: 262144
  snapshot_page_items: 100
```

This fragment shows defaults, not a complete installation file. Merge it into the
existing sections, retaining `target.profile_file` if selected. Other registered
operations default to 30000 ms. Waits and the global target ceiling allow
1..1800000 ms. The target profile chooses its own `operation_timeout_ms`, bounded
by that ceiling; a direct HTTP target still has its separate 30000 ms maximum.

For a multi-step Interceptor target, coordinate the Blueprint turn allowance, the
complete-attempt allowance (including setup and observations), and the Harness
request wait. For example, 60 seconds / 90000 ms / 120000 ms leaves room for each
layer. Shorter caller deadlines and remaining campaign lifetime still win. Raising
only one setting cannot extend the others. Model waits are independently configured;
there is no additional fixed two-minute provider-response ceiling when a longer
valid model request deadline is supplied.

Direct inputs, artifact parts, and observation chunks may be raised to 1 MiB;
assessments remain capped at 1 MiB, artifacts at 16 MiB, and snapshot pages at 100.
Encoded requests must also fit the 4 MiB frame. See
[operating limits](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/OPERATING_LIMITS_CONTRACT.md).
Operator freezes these settings into Harness startup; there is no separate Harness
timeout/size configuration file. Changes apply to new campaigns, not active ones
or healthy restores.

Bundle-requested limits can only narrow installed limits. Feedback also remains
bounded by target policy. Do not enlarge limits or add permissions to make an
otherwise incompatible bundle run.

## Configure the Harness model and authentication

Read only the selected provider's
[model profile](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/MODEL_PROVIDERS.md)
and [authentication](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/HOST_AUTHENTICATION.md)
guidance. Use a release template with the matching native codec, model, endpoint,
token/response bounds, and required codec options.

Operator's model profile controls Attack Harness's model. Interceptor separately
configures the target application's model; the two do not need the same provider.
Operator HTTP model profiles require the **complete HTTPS operation endpoint**,
not Interceptor's provider base URL. Bedrock instead selects `region` and its native
SDK endpoint, with no endpoint override. Optional `ca_certificates_pem` adds private
CA trust to an HTTPS model profile without disabling hostname verification.

Set positive `maximum_prompt_tokens`, `maximum_completion_tokens`, and
`maximum_response_bytes` (at most 4 MiB). Optional `context_warning_percent` is an
integer 1–99, default 80. These are local allowances, not a claim about the model's
physical context window. The prompt allowance includes frozen instructions/tools.

`codec_options` holds only the selected codec's host-owned options: Chat
`instruction_role` (`developer` by default or `system`), Responses `reasoning`,
Anthropic `thinking` and `output_config` (including effort), Gemini
`thinking_config`, or an empty Bedrock object. Select values supported by the actual
provider/model. Legacy `codec_options.response_models` is accepted but ignored for
model-label admission; it is no longer an enforced response-model allowlist.
Provider metadata does not establish the request route. Do not add these fields
to the Harness request: Operator supplies model, options, prompt, tools, and output
allowance from its frozen configuration.

Budget model requests using `R = maximum_prompt_tokens + maximum_completion_tokens`.
The current Harness starts exploration only with at least `3 × R` tokens and three
model calls remaining, reserving capacity for assessment and one correction. An
oversized local prompt allowance can force immediate finalization even when the
actual prompt is small. Do not automatically increase budgets to defeat this rule.
The adaptive loop uses local conversation checkpoints, preserving counters and
retained evidence; it does not buy model-generated summaries. See
[Harness model relay](https://github.com/intrusiveai/attack_harness/blob/main/docs/MODEL_RELAY.md)
and [context allowances](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/MODEL_CONTEXT_CONTRACT.md).

Reuse the user's chosen authentication. Stored model keys use a host credential
reference and the existing [credential resolver](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/CREDENTIALS.md).
Explicit host environment keys use `authentication: api-key-env` plus the
variable's name in `api_key_env`. Cloud identity selectors must match the actual
bootstrap mechanism; secret-store login is separate from model authentication.
Do not provision a new secret service merely to replace a supported existing choice.

Keep actual values out of CLI arguments, prompts, bundles, profiles, logs, and
service definitions. Profiles contain credential IDs or variable names, not keys.
For GitHub OIDC or service-account login, load only the relevant section of
[cloud authentication](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/CLOUD_AUTHENTICATION.md).
A detached service cannot assume it inherits terminal/job authentication.

Supported stores include AWS Secrets Manager, Azure Key Vault, Google Secret
Manager, Vault KV v2, and [1Password](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/ONEPASSWORD.md).
For 1Password, use backend `onepassword` with an `op://vault/item/[section/]field`
reference and an allowed prefix ending at a `/` component boundary. Desktop mode
uses `onepassword-desktop`, `onepassword_account`, and the app's SDK integration;
automation uses `onepassword-service-account` and host `OP_SERVICE_ACCOUNT_TOKEN`,
omitting the account field. The embedded SDK needs no `op` CLI. These are store
profile authentication choices; the model profile still selects `secret-store`
and `credential_id`. Desktop mode needs the user's signed-in app session; a detached
service needs its own usable identity. Local profile validation does not read a secret.

## Verify setup at the requested level

```sh
operatorctl config check --config /absolute/private/config.yaml
operatorctl doctor --config /absolute/private/config.yaml --offline
operatorctl doctor --config /absolute/private/config.yaml
```

`config check` validates configuration syntax and settings; it does not open
referenced profiles or establish runtime readiness. Offline doctor checks installed
files, profiles, credential references, and state-root permissions. Normal doctor
also performs read-only local Docker daemon/image inspection. It does not create
containers, pull images, resolve secrets, attach a target, or call a model.

Report skipped and failed checks. For a requested working installation, continue
through [campaign preparation](campaign-preparation.md) and
[campaign operation](campaign-operation.md) with a representative bounded task.
Only a real successful model/target interaction verifies those live paths.
