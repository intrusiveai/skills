# Separately supplied Python and Node invocation adapters

Read this when the application needs invocation glue that is not already in its
image, or when building/troubleshooting such an adapter. Reuse an existing code
module if it already meets Interceptor's convention. HTTP, command, stdio/REPL,
and the external framed adapter remain separate supported interfaces; this feature
extends `kind: code`, not the external adapter protocol.

## Check the selected executable

This guide describes the implementation verified at
[979458c](https://github.com/intrusiveai/interceptor_sandbox/tree/979458c256455b3ecae071570e9e0c4a18fae784).
Use that revision's [interface documentation](https://github.com/intrusiveai/interceptor_sandbox/blob/979458c256455b3ecae071570e9e0c4a18fae784/docs/application-interfaces.md#supplying-an-adapter-separately)
and [runnable examples](https://github.com/intrusiveai/interceptor_sandbox/tree/979458c256455b3ecae071570e9e0c4a18fae784/examples/invocation-adapters),
or their equivalents for the selected release.

Check `interceptor version`, the archive's `release.json` source revision, and
the matching implementation/validator for `code.adapter_asset` and `code.close`.
A rolling candidate can retain its version while its contents change, and a
candidate branch can exist before a feature is merged. Do not infer support from
`v0.1.3` alone. If unavailable, report the version mismatch and use the user's
authorized upgrade/source-build choice; do not silently switch releases, remove
the adapter field, or execute different code as a fallback.

## Author the smallest adapter

Inspect the target's API before writing glue. Identify initialization, session
construction, invocation arguments/results, cleanup, and dependencies. Keep the
application's normal behavior; the adapter translates Interceptor's input into
that API. It does not emulate databases, vector stores, embeddings, or other
missing dependencies, nor automatically expose new attack operations.

Put the adapter and any helpers in a directory below the Blueprint:

```text
interceptor-environment/
  environment.yaml
  assets/adapter/
    support_adapter.py
    helpers.py
```

For Python, adapt this fragment to the inspected image and API:

```yaml
application:
  launch:
    command: ["/usr/local/bin/python3"]
    workdir: /app
    environment:
      MODEL_BASE_URL: http://127.0.0.1:18080/v1
      PYTHONDONTWRITEBYTECODE: "1"
  interface:
    kind: code
    operations:
      - id: ask
    code:
      language: python
      adapter_asset: assets/adapter
      module: support_adapter
      initialize: initialize
      invoke: invoke
      close: close
      init_arguments:
        customer_id: alice
      concurrency: 1
    startup_timeout_ms: 30000
    turn_timeout_ms: 120000
  persistence:
    snapshot_capable: false
    quiesce: {kind: none}
```

This is not a complete Blueprint: supply the real image digest, actual review
metadata, and remaining environment fields. `close` is optional; configure it
only when the returned object exposes that method. Keep real credentials out of
code and `init_arguments`.

| Language | Entry/import rules |
| --- | --- |
| Python | `module` is a dotted name inside the adapter directory. Packages require `__init__.py`. Helpers import from that directory; application modules resolve from the workdir and installed Python packages. |
| Node | Launch the image's Node executable, set `language: node`, and use an explicit relative entry such as `module: ./support_adapter.mjs`. `.mjs`, `.cjs`, and `.js` with suitable `package.json` semantics are supported. Relative helpers stay in the adapter; package imports resolve through the workdir's parent chain, including `/app/node_modules` when the workdir is `/app`. Use explicit container paths for application files, such as `/app/support_app.mjs`. |

The configured initializer receives one dictionary/object (`init_arguments`) and
returns an object with the configured invocation method. Create the application
and customer/session objects once there; `invoke(input)` delegates each JSON
input to the target API and returns its result. Without initialization, Interceptor
calls the configured module export. Without `adapter_asset`, existing installed
module invocation still works. Neither route calls an arbitrary class constructor
or multi-step application workflow from YAML.

Synchronous and async methods are supported. Python async lifecycle calls share
one event loop; Node preserves the method receiver (`this`). Calls are serial by
default. Python supports `single` input or object-to-keyword expansion with
`input_mode: kwargs`; Node uses one JSON value. Keep concurrency at one unless the
Node adapter is explicitly safe for overlapping calls (the supported limit is 32).
With `code.state`, concurrency must remain one for either language; see
[application state adapters](application-state-adapters.md).
Interceptor establishes observation windows after adapter capacity is available;
no adapter-supplied turn header is needed. Work that outlives a call and overlapping
invocations limit turn association. Preserve the application's normal execution
and describe those limits rather than serializing or rewriting it solely to
manufacture causal evidence. See [native observations](environment-operation.md#interpret-native-observations).
Return JSON-compatible values: Python retains its string fallback for other
values; Node serialization failures fail the turn.

## Build and lifecycle boundaries

- `adapter_asset` names a directory, relative to the Blueprint rather than the
  shell's working directory. Include helpers in that tree. Missing entry files,
  path escapes, symlinks (including source-path components), hard links, and
  unsupported filesystem objects are rejected.
- `environment seal` includes the code and its configuration in existing asset
  integrity records. `app build` verifies the copied bytes and installs them at
  `<launch.workdir>/.interceptor-adapter/`. It preserves the original target image.
  Do not hand-copy code into a live container, add a separate host source mount,
  or edit locks to work around changes. Use the standard validate/seal/build/verify
  commands in [environment operation](environment-operation.md).
- The installed destination must be absent in the source image. Its parents
  cannot be symlinks. It cannot overlap mutable roots, seeds, runtime mounts
  (including `/tmp` and `/run`), or an inherited image `VOLUME`. Use a dedicated
  application workdir such as `/app`; do not weaken these checks to make it fit.
- The image supplies the runtime, application, and dependencies. Interceptor
  installs adapter source without running it during construction or invoking
  pip/npm/downloads. Released wrapper builds require no host Python/Node or Go;
  macOS still requires the complete archive with its matching Linux companion.
- The installed adapter runs as the unprivileged application user. Readiness
  means import/initialization succeeded and the invoke method is callable. With
  state hooks, it also requires hook validation and, on restored startup,
  successful state reconstruction.
  Ordinary application print/console output is separate from response framing
  and is available in the application logs.
- One application process retains one adapter/session object across turns.
  Separate sandboxes do not share it. A [state adapter](application-state-adapters.md)
  can save conversation/session data and reconstruct it in a replacement process,
  even without a framework checkpointer. Open clients and locks must be recreated.
  Keep snapshots disabled unless application persistence or the adapter has a
  verified restore contract covering all required state.
- An optional `close` method on the initialized object (or module) runs once on
  orderly shutdown, with a two-second bound including async completion. Cleanup
  errors are reported. Forced termination cannot guarantee cleanup.
- Invocation exceptions fail a turn. A timeout or cancellation after dispatch
  terminates the language process and rejects further calls; another concurrent
  Node call may also be affected. Start a new session and investigate possible
  side effects rather than replaying automatically. Canceling while waiting for
  an invocation slot does not terminate the process.

## Remote model calls during initialization

An adapter can configure the application's generation and embeddings SDK clients
and call them during initialization or subsequent turns. Use the existing local
model proxy and independent host provider configuration described in
[remote embeddings](remote-embeddings.md). Package SDK dependencies and any
tokenizer cache in the image, declare required cache paths in the launch
environment, and bound initialization and invocation timeouts. Do not replace
remote embeddings with fabricated vectors or imply database emulation.

## Verify and troubleshoot

For a working integration, follow the normal build and `interceptor run` flow,
then invoke the declared operation through Operator or the version-matched local
API client. The printed loopback API is not a direct application HTTP endpoint.
Preserve native operation envelopes and inspect observation output/evidence.

Use at least two turns whose second result demonstrates retained state, confirm
one initialization, exercise an application error, and check orderly cleanup.
Verify that the wrapper contains the sealed adapter bytes and loads its installed
entry rather than host code. The normal read-only Blueprint mount remains for
verification; it is not a separate adapter-code installation mechanism.

Reuse the pinned Python/Node examples when isolating driver/build behavior.
Their `local-api-smoke --adapter-only` client attaches a campaign, makes calls,
checks evidence, and stops the target. Use a dedicated test session, not a status
probe against an Operator-bound session. Developer tooling to build this client
does not become a requirement for released CLI users.

For release/package qualification, the matching checkout's
`scripts/qualify_release.py --adapter-language python` or `node` exercises an
extracted native archive outside the checkout with Go unavailable to the CLI.
Follow the example's exact required arguments and use a fresh evidence directory.
It builds separate target/wrapper images and cleans up its own temporary resources.
Distinguish locally built archives from CI-produced artifacts and report the
actual host/container architectures exercised.

Diagnose failures at the boundary that failed: unknown fields suggest a CLI
version mismatch; stale locks require deliberate review/reseal/rebuild; import
errors need the right entry/dependencies/workdir; path collisions or mounted
destinations need a compatible image/workdir. Readiness alone does not establish
application fidelity. Adapter success does not resolve separate database, model,
TLS, or simulated-service gaps. For Certifi-backed Python HTTPS, use
[Blueprint trust configuration](python-ca-trust.md) rather than adding a custom
HTTP transport or SSL context to the invocation adapter solely for sandbox trust.
