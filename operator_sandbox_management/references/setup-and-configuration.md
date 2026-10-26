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
- the exact shared-contract version **and digest** accepted by both components.

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
from the exact source in the release lock, rather than treating a package built
from a floating checkout as the installed contract.

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
- `state.root`, campaign/harness limits, and storage bounds as required.

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
not Interceptor's provider base URL. Accepted response model IDs must be explicit;
do not accept arbitrary IDs to work around an alias mismatch.

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
