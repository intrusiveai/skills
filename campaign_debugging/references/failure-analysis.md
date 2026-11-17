# Trace failures without confusing their consequences

## Establish the outcome first

Read the result manifest and corresponding completion/launch events. Separate
execution status, assessment acceptance, observed exit, cleanup, reporting and
evidence collection. A published report can describe a failed campaign. An accepted
finish and exit zero can still describe termination without an assessment.

Use a retained `failure_trigger` to locate the first known terminal diagnostic.
Follow its operation to the request, response and subsequent actions. Earlier
corrected tool errors are not automatically terminal causes. If no trigger exists,
reconstruct the sequence and state uncertainty rather than choosing the most
alarming message. A forced exit or closed transport after a provider/target error
is usually a consequence; exit 137 alone does not prove an out-of-memory kill.

## Choose the failing boundary

| Boundary | Required evidence and distinctions |
| --- | --- |
| Preparation / compatibility | Saved completion stage and native command diagnostics; installed product/contract/image identities. No journal may exist yet. Distinguish image absence, platform inspection, contract mismatch and target preparation. Do not compare an OCI index/manifest digest to an image config ID as if they were interchangeable. |
| Harness upstream model | Operator `model.intent`, `model.exchange`, `model.usage`; provider, codec, actual model, operation, HTTP status, structured diagnostic and retained request/response. This is distinct from target model traffic. |
| Harness tool call | Actual model-returned arguments, advertised tool definition from that request, matching result/correction, and next model turn. Separate provider rejection of a tool catalog from a model's invalid tool arguments, unknown handles, wrong handle categories and missing inspected citations. |
| Target operation | Operator attempt/native response and `target_failure`, then Interceptor turn/invocation and downstream activity. An outer failed turn does not prove a model-provider failure or timeout. |
| Target upstream model or embeddings | Interceptor model-exchange references, provider request/response, codec, stop reason, usage and application completion. Preserve embedding traffic separately from generation. An empty answer with an output-limit finish reason is different from HTTP rejection. |
| Snapshot / restore | Native lifecycle request/result, checkpoint readiness, source/replacement identities, managed-state/oracle observations and application retrieval. Count requested operations against the submitted scenario; distinguish missing from duplicate operations. |
| Evidence / reporting / cleanup | Selected sessions and collection outcomes, integrity/omission details and independent closure/stop/removal events. An export failure does not retroactively prove target failure; a complete archive does not prove cleanup. |

For HTTP errors, quote the bounded provider/native message and field path when
present. Inspect the actual submitted body, not a regenerated approximation.
An HTTP 400 is not proof of account lockout or policy refusal. An HTTP 200 followed
by local response-validation failure is not a provider HTTP rejection. Budget
reservations and local token-accounting failures are not cloud quota errors.

For timeouts, identify the interaction, operation, effective deadline and deadline
source. Compare nested model/attempt/turn/campaign limits only when retained.
Elapsed time alone does not establish which deadline expired. Do not recommend
increasing every timeout or token limit before locating the failing boundary.

## Interceptor-specific checks

- Read `logs/application.stderr.log` and `logs/application.stdout.log` when supplied.
  Stderr is a stream, not a severity classification: Python logging, driver logs
  and protocol-safe diagnostics often use it while stdout remains empty or reserved
  for protocol frames. The outer host CLI log need not contain application errors.
- For permission failures, identify the actor's UID/GID, exact path and operation,
  relevant parent-directory permissions, mount/storage boundary and lifecycle
  stage. Do not infer that a particular UID is inherently wrong or apply blanket
  chmod/chown. Private files can be legitimate application state.
- Correlate PostgreSQL shutdown notices or connection closure with lifecycle
  events. Expected cleanup is not itself an initiating application failure.
- For state verification, establish the particular mutation using stable keys and
  values; distinguish preexisting rows from the campaign's change. A target's
  narrative or a generic positive oracle is not automatically proof of exact rows.
  Read available predicate/row evidence and its assurance. If the objective requires
  target retrieval after restore, verify that fresh invocation as well as restored
  state; do not accept only one of them.
- Preserve injection provenance. Applied response rewriting, model-visible tool
  output, an application mutation and committed database state are different facts.
  Injection deletion does not undo committed writes. HTTPS targets without native
  Interceptor state evidence have correspondingly narrower assurance.

## When the diagnosis is incomplete

Report the narrowest established cause and the missing link: for example, an outer
target-operation error with no retained native body, or a provider rejection with
omitted response bytes. Never reconstruct missing detail from a later run or current
configuration. Recommend retaining the specific boundary's request/response,
correlation IDs and structured failure fields if that is the diagnostic gap.

When recommending implementation changes, identify the owning component and
separate observed facts from source-code inference. Prefer general corrections
derived from the relevant schema/rule over hard-coded messages for a single input.
Do not add external validation or bypass product checks to compensate for a product
defect. Read the matching [Operator model service](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/MODEL_SERVICE.md)
or [Interceptor troubleshooting](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/troubleshooting.md)
only as needed.
