# Report content

Write for security personnel deciding what evidence means and what should change
in the application. Lead with observed outcomes and consequential gaps. Keep detailed
identifiers and raw material accessible behind concise explanations. Counts alone
do not substitute for scenario results.

## Review overview

Identify the application as known to Operator, campaign ID, recorded execution
period, and native generation/result identities. Label the HTML authoring date
separately from source timestamps. Summarize supported security observations,
untested scope, and evidence limitations. Do not headline Harness execution success
as application safety or a successful attack.

If failures materially limit the assessment, state their effect on coverage and
confidence in one concise notice, with a source link and debugging handoff when
needed. For example: "Execution ended before the remaining scenarios could be
assessed; those results are inconclusive or untested." Use actual counts and
recorded reasons where available. Do not lead with an operational incident timeline.
If no meaningful security conclusions are possible, say so plainly.

## Campaign configuration

Summarize the configuration actually applied, using retained manifest, launch input,
effective context, and permitted policy records. Include relevant available facts:

- Operator/release and contract identities, Harness image identity, runtime mode.
- Harness model/provider identity and model settings exposed by retained records.
  Keep these separate from any known application-under-test model configuration.
  Include model allowances only where they materially constrain assessment scope;
  these are not claims about the provider's physical context window.
- Selected instructions, skills, and supporting inputs with references; summarize
  their purpose without reproducing the entire prompt.
- Target adapter, permitted operation scope, effective feedback profile/categories,
  timeouts and effective attempt/model/snapshot/resource limits where retained.
  Summarize relevant bounds; link the retained configuration for exact settings.
  Do not reproduce every request timeout, size limit, or per-call measurement.
- Execution, cleanup, evidence collection, and reporting outcomes affecting
  interpretation, stated briefly with links to the native records.

Distinguish requested bundle settings from effective admitted settings. A digest
identifies configuration but does not reveal its values. Use "not retained" or
"omitted from export" for unavailable fields. Never fill gaps from current settings.
Do not expose private HTTP/HTTPS mappings/endpoints, credentials, secret selectors, host
storage paths, or Docker endpoints. Attribute any user-supplied sanitized historical
configuration summary separately and state whether its campaign binding is verified.

Sources: [campaign preparation](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/CAMPAIGN_PREPARATION.md),
[retained launch inputs](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/INPUT_STAGING.md),
and the reporting contract's portable-data rules.

## Application context and assessment scope

Describe target identity, declared operations/interfaces and relevant capabilities,
feedback visibility, supplied application purpose, and known boundaries. Include
the accepted bundle's context, objectives, assumptions, and supporting references.
Label material statements as supplied context, declared capability, observed behavior,
or analysis. Published capability is not permission to exercise it.

Do not imply Operator inspected application internals, verified architecture, or
observed behavior beyond its evidence. State material unknowns and the limits of
Interceptor feedback or direct HTTP/HTTPS declared-observer assurance.

For database-backed targets, include the relevant retained service and injection
mode, declared creation bounds, reset/restore scope, and independent outcome-check
coverage when they affect interpretation. Keep observed model delivery, persistent
harness changes and application business outcomes separate. Do not expose private
schema/seed data, credentials or oracle SQL merely to explain the setup; report
only evidence permitted for the destination. Use the database distinctions in
[evidence interpretation](evidence-interpretation.md#interpret-native-database-evidence).

## Accepted bundle and coverage

Provide a working local link to the exact accepted bundle, bundle ID/version,
campaign-bound digest, and relevant supporting artifacts. Preserve original bytes;
a readable synopsis is additional. Link objective IDs to descriptions, required
flags, and supplied success criteria.

Display total scenarios, required/optional counts, unique scenarios with associated
dispatched attempts, scenarios without such attempts, and any unknown coverage.
Explain counting definitions. Counts must reconcile to the accepted bundle; with
incomplete evidence, distinguish known no-dispatch from unknown coverage. Show total
and exploratory attempts separately. Keep authored assessment counts separate from
execution coverage counts.

Objectives-only bundles are valid: show zero scenarios and provide objective results
and exploratory evidence without fabricating scenarios. If the bundle is missing
or unverified, do not present a native partial list as the complete inventory.

## Scenario index and detailed results

Include every accepted scenario exactly once in a searchable index, with stable
links to details. Retain original IDs; derive a concise label from scenario content
when no title exists. Every detail section must contain:

1. Hypothesis, linked objectives, required/optional status, and relevant scope.
2. Expected observations and evidence criteria from the bundle, not invented tests.
3. Execution coverage and associated attempts, including operation, receipt,
   relevant observed outcome, and significant uncertainty. Summarize an operational
   failure's effect on this result; keep diagnostic traces in linked sources.
4. Observations with evidence links, then separately labeled Harness interpretation
   and author assessment. Explain contradictory or missing evidence.
5. Security implications and justified improvement recommendations, if any.

Citations must resolve to exact artifacts and, where applicable, event sequence
numbers within the source part identified by the execution bundle. Use readable
labels with detailed IDs/digests available nearby. A general evidence-directory
link cannot support a specific finding.

For untested scenarios, explain the recorded reason if known; otherwise say it was
not recorded. Do not invent a result or call the application resistant.

## Operational limitations and debugging handoff

Report enough operational context to make the security assessment honest: which
scenarios are affected, whether evidence is missing or unreliable, and what cannot
be concluded. A campaign failure is not itself an application vulnerability.
Conversely, an application failure that directly supports a scenario's security
criterion remains relevant evidence; do not hide it as a tooling issue.

Direct the reader to `campaign-debugging` when repeated or widespread failures,
blocked execution, substantial evidence loss, or unresolved operational causes
require investigation. A single recovered error with no assessment impact does
not need a diagnostic narrative or referral. No fixed failure percentage is needed.

Place one concise handoff in the limitations section, also flagging it in the
overview when assessment validity is substantially affected. Include the campaign
identity, a portable link to the relevant retained export/native report, affected
scenario IDs or scope, and the question needing investigation. A copyable request
may read:

```text
Use the INTRUSIVE.AI campaign-debugging skill to investigate the operational
failures in [retained export], campaign [ID], that left [scope] unassessed.
Distinguish the initiating failure from later shutdown and cleanup events.
```

Replace placeholders with verified references; keep the handoff free of secrets.
Name the skill explicitly even if it is not installed in the report reader's
harness. It is an optional follow-up, not a dependency for reading the report.
Do not automatically invoke it or expand a reporting request into troubleshooting.
If a separate diagnosis already exists, link it rather than copying its details.

## Security improvements and evidence appendix

Group recommendations only where evidence supports the same improvement; retain
links to affected scenarios. Explain observed behavior, security impact, suggested
application change, and what follow-up validation should establish. State uncertain
root causes or severity. Do not infer severity from scenario priority, assume
source-code access, or add unrelated generic hardening lists. Further testing is
proposed work, not activity performed during reporting.

Keep application remediation separate from campaign-operation repair. Do not turn
provider authentication, Harness prompts, timeout tuning, or sandbox configuration
problems into application security recommendations without supporting application
evidence. Refer those operational questions through the debugging handoff.

Append source inventories, generation/result references, verification scope,
and evidence gaps. Preserve unknowns rather than inventing
an overall pass/fail score. Link authored findings and immutable native reports
separately for review.

Link native diagnostics for traceability; do not populate an appendix with failure
catalogs, full model conversations, credential audits, per-call size/token tables,
or cleanup histories merely because they exist. Include a brief material unresolved
condition when necessary, with its evidence link. Detailed operational analysis
belongs in the separate debugging deliverable.
