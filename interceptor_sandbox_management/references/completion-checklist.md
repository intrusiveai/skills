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
- For remote embeddings, verify the selected executable supports the route;
  generation and embeddings have independent host configuration; the application
  uses the local endpoint and packaged SDK/tokenizer dependencies. A working
  integration claim covers the application's embedding calls (including startup
  when used), generation in the same session, model/error boundaries, and
  evidence/usage checks; see
  [embeddings verification](remote-embeddings.md#verify-and-troubleshoot).
- Synthetic services preserve the required request, response, mutation, identity,
  and error behavior. Unknown requests fail visibly rather than receiving success.
- File roots, injection namespaces, collection creation, sinks, feedback, and
  limits are intentional and bounded.
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
verify mutation and restore, not just checkpoint creation.

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
