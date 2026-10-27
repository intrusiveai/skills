# Setup and configuration

Use this guide for installation, upgrades, model access, and host execution.
Existing Blueprint use continues in [environment operation](environment-operation.md);
application assessment is not an installation prerequisite.

## Install or check the selected version

1. Identify host OS/CPU and Docker daemon architecture. Support is Linux or macOS,
   AMD64 or ARM64, with a matching application image. Use Docker Engine on Linux
   or Docker Desktop on macOS. Cross-architecture execution is not this workflow.
2. Inspect `interceptor version`, `interceptor help`, and Docker availability
   (`docker version` and `docker info`). Distinguish an absent CLI, unreachable
   daemon, architecture mismatch, and an older binary.
3. Prefer the complete archive and matching SHA-256 file from
   [public releases](https://github.com/intrusiveai/interceptor_sandbox/releases).
   Select the requested release; if unspecified, resolve a suitable published
   release and its compatibility requirements rather than guessing a version.
4. Follow the selected release's
   [installation guide](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/getting-started.md#install-a-release).
   Verify the download before extraction. For v0.1.2 and later, archive names use
   `interceptor_sandbox-v<version>-<os>_<architecture>.tar.gz` with a matching
   `-SHA256SUMS` file. Older releases have different naming.
5. Extract each release into its own directory and keep its contents together.
   On macOS, `interceptor-linux` and `release.json` must remain beside the real
   CLI executable. A symlink on PATH is supported; copying only the CLI is not.
   Re-extract a damaged or mismatched release instead of mixing companion files.
6. Recheck the selected executable's version and help. Preserve older installation
   and retained data unless their removal is part of the request.

When a task needs separately supplied adapters, follow the
[adapter version check](invocation-adapters.md#check-the-selected-executable).
Do not assume the latest stable release or a rolling candidate version includes
the required code, silently switch channels, or remove unsupported fields to make
an older CLI validate. The target image supplies Python/Node and application
dependencies; these interpreters need not be installed on the host for released
wrapper builds.

For Python HTTPS integration, the target image must already supply Certifi in
each declared interpreter's environment. Configure [Python CA trust](python-ca-trust.md)
in the Blueprint; installing Certifi or the sandbox CA on the host does not
configure the application container.

Released installations need neither Go nor a source checkout for wrapper builds.
Use source builds only for development or a requested source revision. Read the
matching repository's build prerequisites and run its build command from that
checkout; do not assume a pre-existing `bin/interceptor` reflects current source.

## Establish host configuration

Interceptor has no general configuration file or global configuration flag.
Use command-specific flags and documented environment variables. The credential
store file below configures credentials, not the whole installation.

Choose a private local data root when a predictable location is needed:

```sh
export INTERCEPTOR_DATA_DIR=/absolute/private/interceptor-data
```

Use the same root and user account for build, run, and later administration.
The default is the platform user configuration directory's `interceptor`
subdirectory. Preserve application locks and generated TLS material alongside
retained state; they are needed for future runs and restores from that build.

Keep the standard foreground process model. The default bridge is `spool`;
`unix` is for supported native Linux hosts. Do not expose the local API through
a tunnel or public listener as part of ordinary installation.

## Select model access

Read only the relevant pairing in
[model providers](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/model-providers.md).
The application's native API determines the compatible host adapter:

| Application protocol | Host adapter |
| --- | --- |
| OpenAI Chat Completions | `openai-chat`, or matching Azure/LiteLLM route |
| OpenAI Responses | `openai-responses`, or matching Azure/LiteLLM route |
| OpenAI-compatible embeddings | Independent `--embeddings-provider openai-compatible`; see [remote embeddings](remote-embeddings.md) |
| Anthropic Messages | `anthropic-messages` |
| Gemini generateContent | `gemini-api` or `vertex-gemini` |
| Bedrock Converse | `bedrock-converse` |

Interceptor does not translate between these protocols. Check the selected
version's supported request subset: streaming, provider-hosted tools, stored
conversation dependencies, and multimodal/file input are not supported by the
reviewed version. A working host key cannot fix an incompatible application API.

For remote embeddings, configure the separate endpoint, authentication, and model
allowlist described in [remote embeddings](remote-embeddings.md#configure-independent-host-access).
Generation options do not enable or authorize embeddings.

Select a fixed upstream origin and exact allowed model IDs. HTTP adapters use
`--provider-base-url`; Bedrock uses its AWS configuration. The application's
`MODEL_BASE_URL` points to the in-container loopback proxy, not that upstream
origin. SDK-required application keys are separately declared synthetic values.

## Configure authentication without copying secrets

Reuse the user's selected authentication mechanism. For a new model API-key setup,
prefer a stable host credential reference from an existing supported secret store;
do not provision a new cloud service solely to impose that preference.

- For stored keys, read
  [credential stores](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/credential-stores.md).
  Use a private profiles/credentials file with `--model-credential-id` and
  `--credential-config`. Supported stores are AWS, Azure, Google, and Vault KV v2.
- For cloud identity, profiles, CLI caches, or GitHub OIDC, read
  [host authentication](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/cloud-authentication.md).
  Match the selector to the actual bootstrap identity. Model authentication and
  secret-store authentication are independent choices.
- An existing host environment key uses explicit
  `--provider-auth api-key-env --model-api-key-env VARIABLE_NAME`. The reviewed
  implementation supports this in production too; `--production` rejects
  implicit environment lookup. Older application-integration prose saying all
  environment keys are development-only is superseded by the common auth contract.
- Unauthenticated `--provider-auth none` is for an explicitly selected LiteLLM
  gateway. Do not use it to bypass a missing provider credential.

Never print secret values or put them in CLI arguments, service definitions,
Blueprints, assessment notes, or container environment variables.

For a requested live store-access check, use `interceptor credentials check`
with `--live`, the selected credential/config, a probe ID, and a new private
output file as documented upstream. It retrieves a real secret but makes no
model call; success does not prove model access.

## Verify the requested setup

Confirm executable identity, complete release layout, architecture, Docker access,
and selected configuration. If a working target is requested, continue through
build/start and a representative invocation in [environment operation](environment-operation.md).
Report a model connection as verified only after a successful allowed model call.

For a contained first-run demonstration, use the upstream reference agent and mock
provider from a matching source checkout. That example needs a source build of
the reference application and mock; installing Interceptor itself does not.

Only if service-manager execution was requested, read
[host lifetime](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/host-lifetime.md)
and adapt its per-user templates. Services use their own configured account and
environment, with automatic startup/restart disabled. On macOS, normal foreground
execution already manages sleep prevention; no system power-setting change is needed.
