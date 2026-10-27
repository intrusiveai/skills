# Blueprint contract decisions

Use this as a targeted authoring map, not a replacement schema. The selected
release's
[Environment Blueprint reference](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/environment-blueprint.md)
and validator define exact fields and bounds. Read only relevant sections and
feature guides.

## Core contract

A Blueprint contains one strict `environment.yaml` document and its referenced
assets. Unknown fields, missing files, unsafe paths, invalid references, and
ambiguous fixture rules fail validation. Keep assets below the Blueprint root;
do not use absolute source paths, parent escapes, hard links, or special files.
Only contained symlinks accepted by the validator are allowed. Invocation adapter
directories are stricter: they and their source-path components cannot contain
symlinks; hard links and unsupported file types are also rejected.

Use an exact application image digest, explicit launch argv and absolute workdir,
literal environment values, one matching interface block, and intended operations.
Host-variable interpolation is not supported. `MODEL_BASE_URL` must be HTTP
loopback; other base URLs must resolve within the declared simulated world.

Read [application integration](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/application-integration.md)
and [application interfaces](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/application-interfaces.md)
for launch and invocation details. Source review determines whether the image
and operation contract are real; schema validation cannot establish this.

## Select feature references

| Feature being authored | Read | Preserve |
| --- | --- | --- |
| Separately supplied Python/Node invocation glue | [Invocation adapters](invocation-adapters.md) | `code.adapter_asset` is a sealed directory copied by `app build`; the image supplies the runtime and dependencies |
| Delivery metadata for the harness | [Delivery contracts](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/delivery-contracts.md) | v1alpha2 for `delivery`/`delivery_asset`, service `export_contracts`, or MCP `implementation`; unknown output stays unknown |
| Remote embeddings alongside generation | [Remote embeddings](remote-embeddings.md) | Separate host credentials/allowlist; local SDK endpoint and packaged tokenizer dependencies |
| Native model endpoint | [Model providers](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/model-providers.md) | Like-for-like API, supported non-streaming subset, synthetic SDK credentials |
| DNS, HTTP/TLS, fixture and stateful services | [Blueprint field reference](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/environment-blueprint.md) | Exact local hostnames/routing; unknown requests fail with coverage gaps |
| Python Certifi-backed HTTPS | [Python CA trust](python-ca-trust.md) | Absolute image interpreter paths in `network.tls.python_environments`; TLS enabled with `auto`; preserve certificate verification |
| MCP tools | [MCP services](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/mcp-services.md) | Supported methods/results; no forwarding to a real server or arbitrary code in fixtures |
| Synthetic users and delegated access | [Identity](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/identity.md) | Real application token flow; least required grants; no production identity material |
| Injection surfaces, sinks, and deterministic checks | [Injections and evaluation](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/injections-and-evaluation.md) | Distinct placement boundaries; bounded creation; no campaign payloads in the Blueprint |
| Restorable state | [Snapshots](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/snapshots-and-restore.md) | Declared files and managed logical state, not memory or external resources |
| Feedback exposure | [Feedback](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/feedback.md) | Declared profiles and selected immutable session profile |
| Capability handoff | [Operator capabilities](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/operator-capabilities.md) | Native export differs from Operator's public projection |

## Non-obvious authoring decisions

- DNS is closed and never forwards to external resolvers. HTTPS uses declared
  hostnames and build-generated trust. Choose `auto` for supported common PEM
  stores and declared Python Certifi environments, `bundle` when the app explicitly consumes the CA, or
  `application-managed` with its required trust probe for a custom mechanism.
  Private TLS keys are generated host-side, not authored Blueprint assets.
- Writable seeds must lie in narrow non-overlapping mutable roots. Injection
  namespaces expose logical IDs, not arbitrary host paths. File creation requires
  an existing safe parent plus explicit count and byte bounds.
- HTTP/MCP state creation at injection time requires a sealed compatible create
  route/tool and an opted-in bounded collection. It cannot invent service semantics.
- Use a static HTTP sink for capture-only behavior; dynamic responses are an
  intentional bounded injection surface. Destination, status, headers, and request
  allowlists remain sealed.
- Synthetic credentials name a local accepting service or `model-proxy`.
  Credential-like launch variables need matching declarations. Keep host model
  keys, cloud identities, secret-store locators, scenarios, and campaign budgets
  outside the Blueprint.
- Prefer a small deterministic oracle tied to observable effects. A canary's
  declared file location must contain its value. Scope evidence to what the
  selected feedback profile actually exposes.
- Snapshot configuration needs a defensible quiescence mechanism. Memory,
  undeclared paths, external services, and open connections are not saved.
- Both supported Blueprint versions export native capability-manifest/v1alpha3
  in the reviewed source. Do not handwrite a manifest or substitute a raw file
  hash for its native digest. Operator produces its own public projection.

Use the version-matched
[reference environment](https://github.com/intrusiveai/interceptor_sandbox/tree/main/examples/reference-environment)
or [delivery example](https://github.com/intrusiveai/interceptor_sandbox/tree/main/examples/delivery-contract-environment)
for concrete syntax. Their example image digests and reviewer names must be
replaced before real use.
