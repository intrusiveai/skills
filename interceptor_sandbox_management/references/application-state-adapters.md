# Application state adapters

Read when assessing, authoring, building, or verifying conversation/session
restoration for a Python or Node code-interface application. Reuse an existing
application persistence mechanism when it already reconstructs all necessary
state. A framework checkpointer is optional; a separately supplied adapter can
provide persistence without changing the target's source when the required state
is accessible and reconstructible.

Use the [application interface contract](https://github.com/intrusiveai/interceptor_sandbox/blob/b9829e2d7e82e2995d2d99caac35883f4cdddedd/docs/application-interfaces.md#saving-and-restoring-application-state)
and [Python/Node examples](https://github.com/intrusiveai/interceptor_sandbox/tree/b9829e2d7e82e2995d2d99caac35883f4cdddedd/examples/application-state-snapshots)
for concrete implementation patterns. Framework membership or callable method
names alone do not establish full snapshot support.

## Assess what must survive

Trace how the next model request and application decision are constructed. Record
which state is saved by the adapter, managed services/files, or an existing
application mechanism, and which state remains unsupported. In particular check:

- Ordered messages, structured content, tool calls and results with their IDs,
  summaries, truncation state, and other context used on subsequent turns.
- Logical session/thread identity, authenticated user association, and registries
  or object relationships required for that session to remain valid.
- Counters, pending restrictions, failed-interaction markers, and safeguards that
  affect future actions. Do not save only the transcript when these exist.
- Background work and initialization side effects. Initialization runs before
  restoration, so it must recreate transient resources without issuing business
  operations that would change the restored world.

Reconstruct locks, connections, and clients rather than serializing them. Keep
real provider credentials outside the adapter and state payload. Preserving a
logical identity must not revive expired credentials or bypass authorization.
Provider-side conversation identifiers do not save the remote conversation;
unsupported external state remains a gap.

If required state cannot be reconstructed faithfully, leave
`snapshot_capable: false` and explain the missing capability. Do not rewrite the
application or substitute a partial restore without discussing that scope change.

## Implement the adapter

Extend the same invocation object or module described in
[invocation adapters](invocation-adapters.md):

- `save_state()` returns a JSON object containing all required application state.
  It must be repeatable and leave the live application's logical state unchanged.
- `restore_state(state)` applies that object to the newly initialized application
  and rebuilds required relationships before the next invocation. Its return
  value is ignored.
- Both languages support synchronous and asynchronous hooks. Methods resolve on
  the initializer's return value, or the imported module without an initializer.
  Node retains `this`; Python async hooks use the invocation event loop.

Use an application-specific payload format version and validate its fields,
identity, and compatibility. Encode framework message objects explicitly,
preserving their semantics. The driver requires lossless JSON: no arbitrary
objects, non-string object keys, dropped values, cycles, or non-finite numbers.
Do not rely on Python invocation output's string fallback, pickle, or equivalent
object deserialization. The driver owns the file envelope and atomic write;
return application state rather than writing or loading that envelope yourself.

Preserve prompts, tool definitions, message order, truncation policy, identity
checks, and safeguards. Save/restore must not invoke models, replay previous
inputs or tool side effects, or inject history into model requests. The adapter
is part of the tested configuration; it does not establish that the original
application has production restart support. Coupling to private fields requires
reassessment when application internals change.

## Configure and package

Merge this fragment into the existing code interface and persistence settings;
retain the application's launch, module, operations, and other mutable roots:

```yaml
application:
  interface:
    kind: code
    code:
      concurrency: 1
      state:
        save: save_state
        restore: restore_state
        path: /app-state/agent.json
  persistence:
    snapshot_capable: true
    mutable_roots: [/app-state]
    quiesce:
      kind: none
      timeout_ms: 5000
```

The names are configurable. `save`, `restore`, and `path` are all required when
`state` is present. State-enabled adapters require concurrency one for both Python
and Node; the higher Node invocation-only limit does not apply.

Use an absolute file path below a declared mutable root, outside the application
workdir, installed code, protected/runtime paths, seeded targets, and file-injection
namespaces. Do not seed a root that covers the checkpoint path or expose the file
for harness mutation. Reject path escapes and links rather than working around
validation. Existing mutable storage provides the writable location; no new volume
service or installer is needed. The driver creates group-readable files for the
existing application/supervisor identities; do not replace them with world-writable
permissions to address a failure.

Include the hooks and helpers in `code.adapter_asset` when supplied separately.
An installed application module can implement the same contract. Follow the normal
validate/seal/build/verify flow. Adapter/configuration changes require resealing
and rebuilding; do not patch a live container. `app build` packages the sealed code
without running it, modifying the original image, or installing runtime dependencies.

## Capture, restore, and diagnose

Interceptor waits for completed invocations, performs configured quiescence, and
calls the save hook at snapshot creation. It includes the resulting state file in
the existing filesystem integrity records and snapshot byte accounting. Saving is
not performed on every turn. `quiesce.kind: none` skips an additional flush action,
not the state hook. Both `limits.max_blob_bytes` and snapshot byte limits apply.

Background tasks must not change required state between export and capture. Use
existing quiescence facilities where needed; serial invocation alone does not
stop background work. Snapshots do not resume a partially executed invocation.

Restore reconstructs the selected environment and files, initializes the adapter,
and loads state before readiness. A new sandbox session ID and binding are expected;
the saved logical application conversation and identity should continue. A fresh
session does not load a checkpoint just because a file exists. Use the existing
[restore lifecycle](environment-operation.md#snapshots-and-restore); no new restore
command or endpoint is needed.

With [managed PostgreSQL](postgresql.md#verify-committed-state-and-restoration),
save hooks can finish database work before the coordinator freezes and backs it
up. Resolve open transactions before capture; idle pools may remain. On restore,
the backend is ready before application initialization and pools reconnect normally.
Serialize logical application context, not database files, connections or pools.

| Failure | Required handling |
| --- | --- |
| Missing/non-callable hooks or invalid path | Correct the adapter/configuration and reseal/rebuild as appropriate |
| Save exception, lossy JSON, write failure, or size exhaustion | Snapshot failed; do not use a stale file as proof of a successful save. A recoverable rejection permits continued operation |
| Save timeout or broken protocol with uncertain execution | The application session is unusable; inspect the outcome and use supported lifecycle recovery without replaying actions automatically |
| Missing, corrupt, incompatible, or rejected restored state | Restored startup fails before readiness; do not substitute a fresh conversation or hand-edit snapshot evidence |
| Native `evidence_storage_error` or `evidence_incomplete` taint | Further turns and new snapshots are blocked; use [storage failure handling](environment-operation.md#required-evidence-storage-failures), not the recoverable state-save path |

Snapshot waiting/capture uses the quiescence timeout (default five seconds).
Restored startup uses the existing startup timeout. Diagnose blocked work or
excessive state before increasing limits; do not discard required context to make
an incomplete checkpoint appear valid.

## Verify faithful continuation

For a requested working integration, test the actual packaged application and
adapter through Interceptor, using a dedicated session and existing qualification
or Operator tools. Capture only at a completed-turn boundary:

1. Establish several conversation turns, logical identity, and relevant safeguards;
   perform a tool action that changes a managed record or declared file.
2. Snapshot the known state. Run a chosen next input and retain the outgoing model
   request and resulting state as the uninterrupted baseline, then make additional
   context and environment changes.
3. Restore the selected checkpoint into a new process. Invoke the same next input
   and compare its actual model-request context, identity, safeguards, and relevant
   service/file state with the baseline. Explain any normalization of transient
   fields; do not normalize away meaningful context differences.
4. Verify post-snapshot facts are absent and earlier tool effects were not replayed.
   Run at least two further turns to prove the restored memory continues updating.
5. Exercise a relevant failure, such as incompatible restored state or a rejected
   save, and verify it cannot be reported as a successful full restore.

Live model responses need not be identical; compare the inputs and state governing
them. A harness interaction log, successful checkpoint creation, readiness, or
matching final answer alone does not demonstrate restored agent context.

The upstream `scripts/qualify_release.py --adapter-language python --state-snapshots`
(and `node`) exercises the supplied examples from an extracted archive with Docker
and a deterministic host model fixture. The `local-api-smoke --state-snapshots`
client binds a campaign, performs two restores, stops targets, and exports evidence;
it is not a status probe. Use the example instructions for complete commands.
Those examples qualify the mechanism, not an unrelated application-specific adapter.

Report the application/image and adapter identity, captured and unsupported state,
actual runtime/platform, restored lineage, and checks performed. Distinguish local
fixtures from live model access and CI artifacts from local builds. Retain evidence
and clean up test resources according to the task's authorization.
