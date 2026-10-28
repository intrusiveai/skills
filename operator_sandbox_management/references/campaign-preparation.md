# Campaign preparation

Prepare reusable inputs and, when requested, a saved start request without launching
Attack Harness. Use the existing Operator contract, target export, and submission
validator; do not recreate their schemas or digest rules.

## Select the target and policy

Identify the intended target, existing scenario bundle, output location, selected
configuration, and needed feedback/limits. Inspect existing artifacts before
regenerating them.

An Operator environment directory contains:

- private `target-profile.json`;
- public `capabilities.json`;
- the export's exact hash-named native/source companion beside it.

This is not an Interceptor Blueprint directory. The directory must be owned by
the service user or root and not writable by others; keep the target profile
private. Profiles select allowed operations, caller identities, injection routes,
feedback, timeout, and target-stop policy. Capabilities alone grant none of these
permissions. Use only the target branch below.

### Interceptor target

Use Interceptor management for Blueprint creation, sealing, wrapper builds, and
session lifecycle. For capability authoring, an existing sealed Blueprint can
produce a native export without starting a session.

Adapt the matching
[Interceptor profile template](https://github.com/intrusiveai/operator_sandbox/blob/main/release/templates/interceptor-target-profile.json)
using [target preparation](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/CAMPAIGN_PREPARATION.md).
Choose a logical target ID, intended operations and routes, feedback ceiling,
and deliberate `allow_target_stop` policy. Do not claim the template's operation
IDs or injection routes exist without checking the actual export.

With the Operator environment directory and profile already prepared:

```sh
interceptor capabilities --environment ./interceptor-environment > ./native-capabilities.json
operatorctl capabilities export --config /absolute/private/config.yaml \
  --target-profile /absolute/operator-environment/target-profile.json \
  --native ./native-capabilities.json \
  --output /absolute/operator-environment/capabilities.json
```

Use a new path for the native file too; shell redirection would otherwise overwrite
it. Operator writes the public file and its companion; preserve both unchanged.
Never handwrite a capability digest or use a raw file hash in place of the native
manifest's digest.

Before live start, the intended Interceptor instance must be running and ready on
the same trusted host at `127.0.0.1:8080`. There is no integration token or remote
gateway. Do not attach a probe campaign: Interceptor binds to its first campaign
for the process lifetime. An offline export does not establish live readiness.

### PostgreSQL-backed Interceptor targets

Use the generated public export to identify the database service and supported
`database_response` / `environment_state` actions. Configure explicit permitted
routes for the intended mode and table/field scope. Public capabilities describe
what is available; they do not authorize arbitrary SQL or disclose private schema,
seed contents, credentials or oracle queries. Keep those in the Interceptor
Blueprint. Use Interceptor management for database setup, TLS and readiness checks.

Response injection changes returned content; persistent state injection commits
an allowed record change. Creation permission and bounds must be present in the
advertised policy; an available database service alone does not grant them.
Regenerate exports through the normal tooling when the Blueprint changes, and
preserve the generated companion. Use the projection's actual identifiers and
route vocabulary; do not relabel a database response as an HTTP response or edit
exported JSON to make policy validation pass.

### HTTPS target

Read [HTTPS targets](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/HTTPS_TARGETS.md)
and adapt the [profile template](https://github.com/intrusiveai/operator_sandbox/blob/main/release/templates/https-target-profile.json).
The private mapping fixes destination, request placement, response selection,
authentication, network policy, and byte/time limits.

Use a host credential ID for authenticated mappings, not literal secrets.
Private or loopback destinations require explicit permitted CIDRs; do not disable
TLS verification or enable redirects to make a target connect. Match the selected
request/response shape to the actual application's interface.

Generate capabilities directly from the profile:

```sh
operatorctl capabilities export --config /absolute/private/config.yaml \
  --target-profile /absolute/operator-environment/target-profile.json \
  --output /absolute/operator-environment/capabilities.json
```

This is offline and does not contact the application. Do not supply `--native`
for HTTPS. HTTPS targets support their declared application operations and bounded
feedback, not Interceptor injections, snapshots, restore, native oracles, or target
stop. Do not represent an HTTPS response as evidence of remote cleanup/reset.

## Check the bundle and supporting files

Use the scenario bundle generation skill when objectives or scenarios must be
authored or materially revised. For an existing bundle, verify its target ID,
authoring capability source, required references, requested feedback, and limits
against the selected export and installed contract. Objectives-only input is valid.

Keep required capability failures distinct from optional gaps. Do not silently
drop a requirement, broaden policy, or manufacture a capability to pass admission.
An optional projection digest requests an exact static match; otherwise live
admission checks compatible requirements. Neither mode grants permission.

When artifacts are present, read the supporting-reference section of the
[bundle contract](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/SCENARIO_BUNDLE_CONTRACT.md).
Each supplied file must be the declared direct regular child named
`sha256-<hex>`, with exact bytes and size. No extra files, links, directories,
or undeclared fetches. Preserve explicit optional omissions; do not invent empty
files. Supporting references are passive content, not installed skills or
execution artifact receipts.

## Submit and validate offline

Create the parent directory and select a new run output:

```sh
mkdir -p ./runs
operatorctl submit --config /absolute/private/config.yaml \
  --bundle ./scenario-bundle.json --environment ./operator-environment \
  --output ./runs/example
operatorctl validate --config /absolute/private/config.yaml --run ./runs/example
```

Add `--artifacts ./bundle-artifacts` to submission only when needed. Alternatively,
use `--target-profile FILE --capabilities FILE`; these cannot be combined with
`--environment`. Plain `--capabilities FILE` uses the installed default profile
during preparation.

Submission verifies the installed package, bundle, capability provenance, and
artifact inventory, then publishes immutable copies and `run.json`. Success
means `validated-offline`; it creates no authoritative campaign execution state.
The output must be new and its parent must exist. Do not reuse an incomplete
directory or edit retained input bytes. Changed inputs or an explicitly selected
profile require a new submission.

These commands do not contact Docker, Interceptor, model providers, or secret
stores. Read [submission](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/SUBMISSION.md)
for exact selection and publication rules.

## Save a prepared campaign only when useful

If the user wants a saved start without execution:

```sh
operatorctl campaign prepare --config /absolute/private/config.yaml --run ./runs/example
```

The private state root must already exist. Preparation freezes configuration,
profiles, model/credential references, submission, and instruction selections into
a saved start request. Its `submitted` phase is not campaign acceptance.
It remains offline, although it writes start records and the run's lookup link.
Ordinary `campaign start` can perform this step itself; do not require a separate
prepare command for every run.

Only for requested Harness instructions, read
[custom skills](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/SKILLS.md).
Build/import the intended instruction-only bundle and select explicit digests
with `--skill`, or one exclusive frozen `--skill-set FILE`. These are instructions
for the guest, not these host-administration skills and not new tools or permissions.
Use `--system-prompt` for explicit replacement or repeatable
`--system-prompt-append` for extension; the two modes are exclusive.

Selections and their bytes freeze with preparation. Omitted selections reuse the
saved ones. Changed selections require a deliberate fresh campaign; do not modify
saved manifests or clear claims. If independent service execution is requested,
select `--service` when preparing; the saved execution mode cannot change later.

Hand off the run directory, selected target, validation receipt and optional gaps,
and any prepared campaign/start IDs. State live prerequisites separately. Continue
to [campaign operation](campaign-operation.md) only when execution is requested.
