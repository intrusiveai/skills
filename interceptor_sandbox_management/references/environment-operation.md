# Environment operation

Use an existing Blueprint without loading application-assessment guidance unless
it must change. The examples below use placeholder paths and identifiers; replace
them with inspected values. Preserve the same selected CLI, host account, and
`INTERCEPTOR_DATA_DIR` throughout.

## Validate, seal, and build

```sh
interceptor environment validate ./interceptor-environment --json
interceptor environment inspect ./interceptor-environment --json
```

Inspect checks an existing seal. For a new or deliberately changed environment,
validate first, confirm the actual application image and review record, then
perform the requested preparation:

```sh
interceptor environment seal ./interceptor-environment --json
interceptor app build --environment ./interceptor-environment --tag target-sandbox:local
interceptor app verify --environment ./interceptor-environment --json
interceptor capabilities --environment ./interceptor-environment
```

`reviewed_by` and RFC 3339 `reviewed_at` must identify a real completed review.
The reviewed CLI requires these even during validation; report an unreviewed
draft as blocked on review rather than inventing metadata.
Do not silently reseal unexpected changes to bypass inspection.
A real image digest is required; a syntactically valid placeholder is insufficient.
Building an application image and building its Interceptor wrapper are distinct.

The wrapper contains the Linux supervisor, any public sandbox CA, and any declared
invocation adapter. `app build` copies the sealed `code.adapter_asset` directory
into `<launch.workdir>/.interceptor-adapter/`; the original application image stays
unchanged. Adapter or helper edits require inspection/review, resealing, and a
matching rebuild. See [invocation adapters](invocation-adapters.md) for imports,
path restrictions, lifecycle, and failure handling. The matching application lock
and private TLS material stay under the host data root.
Do not run the wrapper manually or add `sandboxd` to the application Dockerfile.
If the CLI, source image, seal, or build material no longer matches, diagnose the
mismatch and rebuild as required instead of editing locks.

For declared `network.tls.python_environments`, `app build` also installs the
public CA into each image interpreter's Certifi bundle. See [Python CA trust](python-ca-trust.md)
for build failures and mount conflicts. Changed declarations or dependencies need
the appropriate reseal/rebuild; do not repair a running sandbox's packages.

The generated capability manifest is a native Interceptor artifact. Operator
exports a separate public projection and native companion for campaign inputs;
use [the capability guide](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/operator-capabilities.md)
for that handoff.

## Start and verify a session

Use the established provider/authentication choice. For example, a host credential
reference with a compatible Chat application:

```sh
interceptor run \
  --environment ./interceptor-environment \
  --model-provider openai-chat \
  --provider-base-url https://api.openai.com/v1 \
  --model-credential-id target-model \
  --credential-config /absolute/private/credentials.yaml \
  --allow-model APPROVED_MODEL \
  --feedback-profile black-box
```

Replace the model, credential ID, path, and adapter with configured values.
For explicit environment-key or cloud identity authentication, read only the
matching section of [setup and configuration](setup-and-configuration.md). When
the target also uses remote embeddings, add the independent
[embeddings options](remote-embeddings.md#configure-independent-host-access);
`--allow-model` alone does not grant embeddings access.

Keep `run` in the foreground in a managed terminal/process session. It owns the
target, host provider bridge, and fixed API at `http://127.0.0.1:8080`; only one
instance is supported. The session selects a declared feedback profile once.
No separate gateway or integration credential is needed.

Record the printed session ID and verify readiness:

```sh
interceptor list --json
interceptor status --json SESSION_ID
```

Place `--json` before the session ID for `status`: the reviewed CLI's parser
requires that order despite the upstream usage example. Other command examples
here use their respective parsers' accepted order.

A persisted status record is not by itself proof of current process health.
For a requested smoke test, exercise a representative application task through
Operator or a version-matched local API client, then inspect its model/service
observations and coverage. Do not call the application's internal HTTP port
directly on the host; current integration has no public convenience application URL.

For a source-based reference demonstration, the matching checkout provides
`examples/mock-provider` and `examples/local-api-smoke`. Follow
[getting started](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/getting-started.md)
with a copied reference environment and new evidence output directory. The smoke
client attaches a campaign, exercises invocation and snapshot restore, stops the
target, and exports both sessions; it is not a harmless status probe.

For adapter qualification, use the version-matched Python/Node examples and the
client's `--adapter-only` mode as described in [invocation adapters](invocation-adapters.md).
It also attaches a campaign and stops the target: use a dedicated test session.
Verify repeated stateful calls, application errors, logs, and orderly cleanup.
For embeddings targets, exercise document/query embeddings at the phases the
application uses, together with generation in the same session; follow
[embeddings verification](remote-embeddings.md#verify-and-troubleshoot).
For Python HTTPS targets, follow [trust verification](python-ca-trust.md#verify-the-application-path)
to exercise their actual environments and clients, confirm fixture evidence, and
check certificate rejection with verification enabled.
A code call canceled after dispatch or timed out can have side effects; the driver
terminates that language process and rejects further turns. Start a new session
and inspect the outcome rather than automatically replaying the call.

## Direct testing and Operator integration

Read [local API](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/local-api.md)
only when attaching a tester, issuing native operations, or restoring. Reuse
Operator or the supplied client before implementing a new one.

All routes use POST with strict JSON. The first `/v1/attach` binds the service
to one campaign for its lifetime. Do not attach a throwaway campaign to a target
intended for Operator. Local host users with loopback access are inside the trust
boundary; campaign IDs are correlation, not authentication.

Use the returned binding and capabilities. Preserve the native operation envelope,
digests, expected state revisions, operation IDs, and deadlines from the matching
contract; do not synthesize an envelope from remembered fields. Native JSON status
is inside an HTTP wrapper, so HTTP 200 alone does not prove operation success.
An uncertain mutation outcome is not permission to replay it; inspect recorded
operation status and follow the terminal-state rules.

For limited manual experiments, use supported native operations and feedback.
Bundle creation and adaptive campaign execution remain separate requested tasks.

## Snapshots and restore

For an unbound administrative session, the CLI can create a checkpoint:

```sh
interceptor snapshot create SESSION_ID --name baseline --json
interceptor snapshot list SESSION_ID --json
interceptor snapshot inspect SESSION_ID CHECKPOINT_ID
```

For a campaign-bound session, create snapshots through native `snapshot.create`
via Operator or the local API. Administrative inventory and inspection remain
available. Respect native and campaign snapshot limits.

Restore uses `POST /v1/lifecycle` with `operation: snapshot.restore` and the
current campaign/session binding, checkpoint ID, caller attribution, and stable
operation ID from the [restore contract](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/local-api.md#snapshot-and-restore).
There is no standalone `interceptor restore` command. Do not close campaign
execution before a planned healthy restore.

The service stops the source before starting its replacement. Record the returned
fresh session ID and updated binding/revision before further operations. Known
preflight rejection may leave the original healthy session usable; uncertain
outcomes or failures after source closure are terminal.

Snapshots save declared logical state, not process memory, network connections,
or the harness conversation. For a restore test, checkpoint a known state, mutate
it through a supported operation, restore, and verify the expected state plus
session lineage. Read [snapshot semantics](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/snapshots-and-restore.md)
only when the saved-state boundary matters.

## Inspect, stop, and export

While the session is running, administrator checks include:

```sh
interceptor coverage SESSION_ID
interceptor evaluate SESSION_ID --json
interceptor logs tail SESSION_ID --channel evaluation
```

`coverage` and `evaluate` require a running session. `logs tail` reads current
events once; it does not follow new events. Protected evaluation data is not
automatically permitted harness feedback.

For requested termination and retained evidence:

```sh
interceptor stop SESSION_ID
interceptor status --json SESSION_ID
interceptor logs verify SESSION_ID
interceptor logs export SESSION_ID --output ./session-evidence.tar
```

Choose a new export path to avoid replacing an existing archive. Exports require
a stopped or error session and verified evidence. Stop retains journals and assets;
the API remains available until the owning `run` process exits. Ctrl+C shuts down
the service and any remaining target.

Export every relevant session in a restore lineage. Abnormal termination may leave
a partial evidence bundle; integrity does not prove completeness or a successful
attack. Keep retained evidence for results reporting. Raw model/application content
can be sensitive even though host credentials are excluded. See
[evidence and storage](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/evidence-and-storage.md)
for archive contents and size limits.

Purge only when deletion is requested, using the narrowest session/campaign selector.
It removes retained evidence and restore points after inactive-state checks.
Stopping or exporting does not imply permission to purge.

## Troubleshooting and completion

Use [troubleshooting](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/troubleshooting.md)
for the observed failure, and [Docker identity](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/docker-identity.md)
when cleanup is unconfirmed. Stop uses the saved Docker identity, not whichever
context is currently selected. Do not delete retained state to hide a failure.

Sleep, logout, host loss, or Docker interruption ends execution. Retain unknown
operation outcomes; later administration can clean up and export, not resume or
adopt the session. Ordinary macOS execution manages its own sleep-prevention helper.

Report the requested resulting state, current and source session IDs where relevant,
artifact locations, observed verification, and unconfirmed cleanup/evidence gaps.
Do not equate session readiness, an armed injection, or a successful archive export
with demonstrated application behavior or a successful attack.
