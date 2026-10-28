# Source assessment for a Blueprint

Read this for onboarding an unfamiliar application or changing a dependency.
For a narrow edit, trace only the affected behavior and its callers.

## Record evidence compactly

Prefer the selected entry point's implementation, executable tests, and immutable
build configuration over general prose. Use a call graph when available to trace
dependencies; do not require an additional analysis service.

For each material decision, record the source path and revision, observed behavior,
proposed mapping, and any gap. A small table is sufficient:

| Behavior | Source evidence | Blueprint mapping | Unresolved limitation |
| --- | --- | --- | --- |

Separate facts from assumptions. Inspect configuration names and delivery
mechanisms without reading or copying runtime secret values.

## Trace only what the chosen application needs

1. **Launch and interface.** Find the actual argv, workdir, required variables,
   runtime user assumptions, readiness signal, and invocation input/output.
   Check image file permissions for Interceptor's non-root application identity.
   Select an existing HTTP route, one-shot command, framed process, REPL, or
   Python/Node function. Preserve framing and error behavior. Health, administration,
   and quiescence endpoints are not automatically attack operations.
   For Python/Node, inspect constructors, retained session objects, callable
   signatures, sync/async behavior, cleanup, and imports. If the application does
   not expose Interceptor's initializer/invoke convention, use a small separately
   supplied [invocation adapter](invocation-adapters.md); do not assume it is
   already in the target image or require a target-source change solely for glue.
2. **Request contracts.** Derive input shapes from routes, parser/validation code,
   tests, or declared tool schemas. Note media types, size constraints, and
   confirmed versus unknown output shapes. Do not infer a universal output schema
   from one response. Author public delivery examples separately from private seeds.
3. **Model path.** Trace SDK creation, native API, model IDs, endpoint override,
   tools, streaming, stored state, and credential requirements. Check the exact
   supported subset in
   [model providers](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/model-providers.md).
   Identify generation and embeddings clients separately, including startup calls,
   endpoint overrides, model/dimension choices, SDK tokenization, and batch size.
   Distinguish remote embeddings from a local model and from vector-store access;
   use [remote embeddings](remote-embeddings.md) for the supported transport.
   Hard-coded endpoints and unsupported features are integration gaps; identify
   any source change needed instead of claiming the Blueprint fixes it.
4. **Dependencies.** Trace actual HTTP/MCP methods and file/subprocess access,
   including pagination, retries, mutation, error responses, authentication, DNS,
   and TLS trust. An SDK name is not evidence of which operations are needed.
   Include network calls made by subprocesses. Arbitrary subprocess output,
   private pipes, databases, queues, browsers, and live cloud APIs are not
   automatically intercepted or faithfully simulated.
5. **Identity.** Identify workload identity, inbound users, delegated access,
   audiences, scopes, token delivery, and authorization enforcement. Simulate only
   paths the app implements. Service-wide bearer checks do not reproduce
   route-specific policies, live federation, browser login, or cloud IAM semantics.
6. **State.** Locate persistent files, caches, databases, conversation state, and
   buffered writes, including dependency/subprocess writes during initialization.
   Record required initial contents, path configuration, and ownership-sensitive
   operations such as chmod. Map ordinary evidence/cache writes to existing mutable
   roots using [container packaging](container-packaging.md); retained caches need
   no special disposable-storage behavior. Check restart behavior and the actual
   flush protocol before enabling snapshots; keep unsupported external state visible.
   For conversation/session restoration, inventory messages, tool history, summaries,
   identity, safeguards, and required object relationships using
   [state adapters](application-state-adapters.md#assess-what-must-survive). Reuse
   existing persistence or assess an application-specific adapter; a framework
   name or absent framework checkpointer is not the deciding criterion.
7. **Observations.** Identify reachable output, managed service mutations, sink
   requests, file changes, and model/tool boundaries that can support deterministic
   observations. Associate canaries and oracles with these paths, not a generic
   attack catalog. Distinguish potential injection placement from proof of delivery.

## Map dependencies deliberately

| Observed dependency | Candidate mapping | What to establish |
| --- | --- | --- |
| Immutable HTTP response | `fixture_http` | Exact request match and response; no broad success fallback |
| Mutable JSON service | `stateful_http` | Small seed/route model matching operations actually used |
| Non-streaming MCP tools | `mcp_http` | Input schemas and real result structure; fixture or stateful behavior |
| Workload/delegated identity | Synthetic identity | Actual token flow and intended grant boundary |
| Input or mutable files | Seeds and narrow mutable roots | Restart semantics and bounded injection namespaces |
| Attacker-observable HTTP | `http_sink` | Capture limits; static response unless dynamic behavior is intended |

Harness-driven record creation needs an existing compatible create route/tool and
a bounded opted-in collection. Harness-driven file creation needs an existing safe
parent and explicit injection namespace limits. Ordinary application writes use
the declared writable filesystem and do not require an injection namespace. A model tool-result injection is distinct from a
native MCP-result or service-response injection; record the boundary the target
actually traverses.

Inspect the application's trust mechanism before selecting TLS `auto`, `bundle`,
or `application-managed`. For Python, identify each interpreter used for HTTPS,
including subprocesses, and whether its client uses Certifi or a custom/vendored
store. Follow [Python CA trust](python-ca-trust.md): HTTPX with `trust_env=False`
needs the declared Certifi bundle integration, not a target-code or invocation
adapter change. Certificate pinning that cannot accept sandbox trust is a gap,
not permission to disable verification.

For each dependency, conclude: modeled, deliberately out of scope, unsupported,
or unresolved. Report the latter two with their effect on legitimate execution.
The output is a source-backed authoring plan, not a separate mandatory approval
stage. Continue drafting everything supported by available evidence.
