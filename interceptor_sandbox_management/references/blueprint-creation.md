# Blueprint creation

Create or revise the smallest faithful synthetic environment for the selected
application. Deliver `environment.yaml`, its referenced assets, a concise source
assessment, and validation results. Use existing fixtures and application interfaces
where they fit; do not introduce an adapter or service without a demonstrated gap.

## Establish the target

Identify the target source/revision, application entry point, requested output
directory, and Interceptor version. Inspect any existing Blueprint and retain
deliberate user choices. Default to an `interceptor-environment/` directory only
when no destination or established convention exists.

For a new application or changed dependency, read
[source assessment](source-assessment.md). For a narrow Blueprint edit, inspect the
affected source, assets, and cross-references instead of repeating the whole assessment.
Keep assessment and validation notes beside the Blueprint, outside its sealed assets.

Resolve the application image from an exact published digest or a locally inspected
image ID. A source commit or mutable tag is not an image digest. If the requested
onboarding includes building the application, use its existing build process and
inspect the resulting image. Otherwise finish the useful draft and identify the
missing image as a readiness gap; never invent a digest.

## Choose a schema and starting point

Read [blueprint contract decisions](blueprint-contract.md) for the relevant
features and upstream field references. Use the selected Interceptor version's
validator and examples as the executable contract.

For a new directory:

```sh
interceptor environment init ./interceptor-environment
```

The command refuses to overwrite an existing `environment.yaml`. Its HTTP starter
is not a requirement to convert the application into an HTTP server. Replace the
starter image, launch, interface, persistence, and synthetic assets with
source-derived values. Do not treat generated review metadata as a real review.

Use `interceptor.dev/v1alpha2` when adding operation `delivery`/`delivery_asset`,
service `export_contracts`, or MCP `implementation`. Existing v1alpha1
Blueprints remain supported. Do not confuse the Blueprint version with native
capability, lifecycle, or operation-request schema versions.

When request packaging needs to be understood by Operator/Attack Harness, author
a delivery contract from the actual application interface. Read
[delivery contracts](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/delivery-contracts.md).
Keep unknown output schemas unknown. Use separately authored synthetic public
examples; protected fixture bodies and seed records are not public examples.

## Model the application and its world

- Declare launch argv, working directory, every required application environment
  value, callable operations, readiness, and bounded startup/turn timeouts.
  Image `ENTRYPOINT`, `CMD`, `USER`, and undeclared Dockerfile `ENV` do not
  supply the child's launch configuration.
- Choose the existing HTTP, command, stdio, REPL, Python/Node code, or external
  adapter boundary that fits the source. Expose only intended application operations.
  If Python/Node needs invocation glue, follow [invocation adapters](invocation-adapters.md):
  put the code in a declared Blueprint asset directory and let `app build` install
  it. Use code for application/session construction rather than inventing a YAML
  object-construction scheme. Leave already compatible installed modules alone.
- Route the native model API to the loopback proxy and declare any SDK-required
  synthetic credential with `accepted_by: model-proxy`. Record real host model
  adapter/authentication requirements separately. For remote embeddings, follow
  [the embeddings guide](remote-embeddings.md) for independent host configuration,
  SDK endpoint selection, packaged tokenizer caches, and startup calls.
- Map immutable responses to exact fixtures, mutable JSON records to stateful
  services, and supported MCP tool calls to `mcp_http`. Cover the legitimate
  path first. Unsupported live dependencies remain visible gaps.
- Preserve relationships between synthetic users, records, grants, and protected
  data. Add identity only when it exercises an actual application path.
- Model the application's declared hostnames and HTTP/TLS trust behavior. Use
  generated sandbox trust rather than disabling certificate verification.
  For Certifi-backed Python clients, declare their image interpreter paths in
  `network.tls.python_environments` under `auto` trust and let the wrapper build
  install the CA. Follow [Python CA trust](python-ca-trust.md) for prerequisites,
  mount restrictions, and custom-store limits.
- Declare narrow filesystem seeds, mutable roots, and intended injection namespaces.
  Enable creation only with explicit bounds and compatible service/file semantics.
- Enable snapshots only when required state survives a restart from the image,
  seeds, declared files, and managed service state. Specify a real flush/readiness
  mechanism or justify `quiesce.kind: none` for safely captured state.
- Add synthetic canaries, bounded attacker sinks, deterministic oracles, and
  feedback/attempt/artifact limits needed by the test objective. Expose useful
  injection surfaces without embedding campaign scenarios or attack payloads.

Use [blueprint contract decisions](blueprint-contract.md) to load specialized
upstream documentation only for the features actually modeled. Do not copy the
entire upstream field catalog into the assessment or this skill.

## Validate and hand off

```sh
interceptor environment validate ./interceptor-environment --json
```

Inspect referenced files and resolve schema, containment, cross-reference, and
fixture-matching errors. Fix fidelity gaps from source evidence; do not add a
wildcard success response, weaken an authorization boundary, or guess an output
contract merely to pass validation.

The reviewed implementation checks `reviewed_by` and `reviewed_at` during
validation too, although its error says they are required before sealing. If
review has not happened, retain a structurally assessed draft and report that
validation blocker; do not fill in fictional review metadata to pass the CLI.

Read the short [completion checklist](completion-checklist.md) when preparing the
handoff. An unfinished starter or placeholder image may be retained as an explicit
draft. Even if its syntax validates, it is not ready to seal or run.

For requested sealing/building or a working target, continue in
[environment operation](environment-operation.md). Review metadata must describe
an actual review by the identified reviewer; ask for missing reviewer information
when it blocks requested validation or sealing, after completing the useful draft.
Do not ask again for steps already authorized by the user's requested workflow.

Report separately what was structurally checked, accepted by the CLI, sealed,
built/verified, and exercised. A functioning representative application invocation,
including its modeled dependencies, is necessary before claiming behavioral fidelity.
