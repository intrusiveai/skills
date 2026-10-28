# Blueprint verification and handoff

Read when finishing authoring or an environment change. Apply only checks relevant
to the requested scope; do not require a full campaign to deliver a draft.

## Authoring checks

- The image, launch configuration, interface, model path, and included dependencies
  are grounded in source or an explicit user decision.
- Every referenced asset exists inside the Blueprint boundary; no real credentials,
  production data, host credential configuration, or generated private TLS keys
  were copied into it.
- If an invocation adapter is required, its directory and entry module are declared,
  sealed, and supported by the selected CLI. The image supplies the runtime and
  dependencies, and the installed path does not overlap writable roots or mounts.
  A working-adapter claim includes repeated calls proving state retention, an
  application-error case, and orderly cleanup; see [adapter verification](invocation-adapters.md#verify-and-troubleshoot).
- For application context snapshots, the state inventory covers messages, tool
  history, summaries, logical identity, safeguards, and required relationships.
  Save/restore hooks are packaged with the adapter, concurrency is one, and the
  dedicated mutable checkpoint path is outside code, seeds, and injection targets.
  Existing application persistence can satisfy the contract without new hooks;
  a framework name alone cannot. See [state adapters](application-state-adapters.md).
- For remote embeddings, verify the selected executable supports the route;
  generation and embeddings have independent host configuration; the application
  uses the local endpoint and packaged SDK/tokenizer dependencies. A working
  integration claim covers the application's embedding calls (including startup
  when used), generation in the same session, model/error boundaries, and
  evidence/usage checks; see
  [embeddings verification](remote-embeddings.md#verify-and-troubleshoot).
- For PostgreSQL/pgvector, verify populated schema/seeds, application grants,
  driver-specific TLS with verification enabled, and representative pooled queries
  and writes. Check vector/model compatibility. Injection and restore claims need
  native delivery/committed-state evidence and actual restored database/application
  state; use [database verification](postgresql.md#verify-committed-state-and-restoration).
- For Python HTTPS, declare the actual Certifi-backed image interpreters under
  automatic TLS trust. Verify the application's HTTPS request and service evidence
  with certificate verification enabled, plus controlled rejection cases. Record
  unresolved custom-store, vendored-bundle, or pinning gaps; see
  [Python trust verification](python-ca-trust.md#verify-the-application-path).
- Synthetic services preserve the required request, response, mutation, identity,
  and error behavior. Unknown requests fail visibly rather than receiving success.
- Where the working integration claims turn-level evidence, inspect native model
  and service records across representative turns. Report observed-window
  association, ambiguity/background limits, and capture completeness separately
  from hash integrity. Application log correlation is unnecessary. Use independent
  service state for committed effects; cumulative oracle results do not prove a
  new turn caused them. See [native observations](environment-operation.md#interpret-native-observations).
- The image includes the installed runtime, dependencies, and required offline
  resources. Launch argv/workdir/environment are explicit in the Blueprint.
  Actual evidence/cache writes use narrow mutable roots with suitable permissions
  and required seed contents; see [packaging verification](container-packaging.md#verify-through-interceptor).
  Verify startup and representative writes under Interceptor's application identity
  and read-only root filesystem before claiming the packaged application works.
- File roots, injection namespaces, collection creation, sinks, feedback, and
  limits are intentional and bounded. Ordinary application writes do not require
  harness file-injection permissions or a new disposable-storage mechanism.
- Public delivery contracts/examples do not expose protected fixture bodies or
  seed values. Output shapes and unsupported capabilities are not guessed.
- The selected CLI validates the directory. Record its version, command outcome,
  warnings, and unresolved fidelity gaps. A syntactically valid placeholder image
  is still unresolved.
- Review metadata is genuine before sealing. Changed assets require review,
  resealing, and a new matching wrapper build before execution.

## Verification levels

Report each completed level separately:

| Level | Evidence |
| --- | --- |
| Source assessed | Relevant behavior and gaps traced to source |
| Schema validated | Matching CLI accepted document and assets |
| Sealed | Actual review recorded; seal written and inspection succeeds |
| Wrapper verified | Build completed and `app verify` accepts its bindings |
| Capabilities inspected | Generated manifest exposes intended operations and surfaces |
| Behavior exercised | Representative invocation and its dependencies succeeded |

For a requested working environment, use
[environment operation](environment-operation.md) to exercise a legitimate
application task, its model call, and relevant synthetic dependencies. Include
a controlled failure case for the boundary under test. For snapshot claims,
verify mutation and restore, not just checkpoint creation. For full-context claims,
compare model-request context and relevant application state against uninterrupted
continuation, verify identity and service/file rollback without replayed actions,
then exercise further turns and a relevant failure. Record uncovered state rather
than treating a fresh session or matching answer as successful restoration.

Choose additional tests to match the environment: TLS trust, delegated identity,
native MCP result delivery, or file/service injection should be exercised when
the deliverable claims those features work. Do not run an exhaustive attack
campaign merely to validate onboarding.

## Handoff

State the environment location, selected source/release and image, completed
verification levels, host prerequisites, and remaining gaps. Link the assessment
and generated artifacts. Use clear statuses such as draft, schema-valid,
wrapper-verified, or smoke-tested; do not call unsupported behavior complete.

Keep source evidence and validation notes outside the sealed environment unless
the user deliberately included them as assets. Give the smallest concrete next
step for any incomplete part without treating missing runtime evidence as success.
