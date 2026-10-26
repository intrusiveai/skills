# Evidence interpretation

## Select and verify sources

Prefer a completed native report/export and its accepted inputs. When starting
from retained state and a compatible installed Operator, use its existing commands
as needed:

```sh
operatorctl report --run ./runs/example
operatorctl export --run ./runs/example --output ./exports/example
```

The export destination must be new, outside managed state, with an existing parent.
An alternative selector is `--campaign ID --state-root /absolute/private/state`;
do not combine it or `--config` with `--run`. Active writers block native reporting.
Report/export uses retained files without Docker, provider, secret-store, or target
contact. Successful publication does not mean campaign success or complete evidence.
Do not terminate a campaign to make reporting possible unless separately requested.

Use the matching [report/export contract](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/REPORTING.md).
Check campaign identity, generation, document bindings, sizes, and digests before
using content. Reuse matching tools for canonical JSON verification; ordinary
sorted JSON is not a substitute for JCS canonicalization.

| Source | What it establishes |
| --- | --- |
| `export.json` | Final portable-export marker and copied-file inventory, including generation and verified native archives |
| `generation.json` | Derived file inventory; its canonical digest identifies the native generation |
| `execution-bundle.json` | RunManifest, verified journal prefix, ordered event parts, visibility and claims authority |
| `result-manifest.json` | Independent execution/cleanup facts, attempts, coverage, usage, claims, and gaps |
| `report.json`, `report.md` | Native summary bound to the result manifest; a starting point, not the full scenario narrative |
| `target-evidence-set.json` | Selected native session lineage, collection outcomes, and archive records |
| `input/scenario-bundle.json` | Accepted scenario/objective definitions and supplied context |
| Retained launch inputs and content | Effective context, prompt, skills, references, requests, responses, feedback, and assessments, when retained |

Document bindings use canonical JSON SHA-256; file inventories, copied content, and
JSONL parts use raw-byte SHA-256. Generation/export inventories exclude themselves.
Verify report-to-result, result-to-execution/evidence-set, and campaign/manifest
bindings, not just file hashes. Export inventories include native archives while
generation inventories need not. Follow only selected inventoried paths within the
evidence root; reject escaping paths and links. Do not recursively trust unrelated
files or extract archives into the report without safe bounded handling.

An export missing its final marker is incomplete. Corrupt or unverified sources
cannot support findings; retain the limitation and use only independently verified
material. Incomplete journals expose only the verified prefix and leave execution
unknown. Do not repair sources, overwrite immutable generations, or silently mix
generations. If the accepted bundle is unavailable, complete scenario totals and
coverage cannot be established; label the report partial rather than inventing them.

## Attribute evidence and coverage

Begin with every objective and scenario in the accepted bundle. Match attempts
using retained scenario provenance and stable IDs, not similar prose. Preserve
request/attempt/receipt IDs, revision, operation, dispatch and invocation states,
and request/result/feedback links. Count each scenario once even with many attempts.
Rejected/non-dispatched attempts do not establish coverage. Exploratory attempts
do not retroactively acquire scenario/objective associations. Unknown origins remain
unknown. Explain discrepancies with native summaries without changing artifacts.

Keep two separate conclusions per scenario:

- **Execution coverage:** associated dispatched attempt(s), no associated dispatched
  attempt, or unknown because provenance/evidence is incomplete. Explain rejected
  submissions without calling them target observations.
- **Evidence assessment:** hypothesis supported, hypothesis not supported in the
  observed test, inconclusive, or not tested. These are authored report labels,
  not replacements for native contract values. State the criterion, observations,
  counterevidence, and limits. A negative result is not proof of general application
  security. Missing evidence is not a negative result.

A hypothesis can describe expected safe behavior; "supported" does not inherently
mean a vulnerability. Explain security significance in words. Treat Harness
assessments as attributed claims, checking actual receipt references and observations.
Missing assessments do not prevent reporting execution facts. Successful invocation,
accepted finish, complete archives, and claimed success do not demonstrate exploitation.
Preserve native `oracle_verdict: unknown`. Scoped oracle observations may support
a separately explained, narrow conclusion. Injection arming is not observed delivery.

## Preserve visibility and uncertainty

Use retained feedback availability, visibility, assurance, and truncation labels.
Native target-output excerpts require adopted same-campaign publications, matching
receipts, verified chunks and complete object digests, and eligible
`target_visible`/`harness_visible` `target_output` entries. Prefer the native verified
observations; keep excerpts within 2 KiB each and 64 per report, link retained
objects, and label excerpt/source truncation separately. A complete retained object
can still be a truncated original response. Present other administrator evidence
as separately attributed sources, not as feedback the Harness observed.

Native archives require verified campaign/application/environment/capability
bindings and recorded source/replacement lineage. Integrity is not completeness or
experimental success. Missing or corrupt archives remain unavailable. Late collection
and import are separate explicitly requested workflows; see
[late evidence](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/LATE_EVIDENCE.md)
and [evidence import](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/EVIDENCE_IMPORT.md).

For [HTTPS targets](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/HTTPS_TARGETS.md),
state `declared-observer` assurance. Selected responses do not prove remote side
effects, native oracle results, reset, or remote closure. Failure after possible
transmission can leave effects unknown.

Report execution, accepted finish, Harness exit, container cleanup, target closure,
injection cleanup, target stop, and reporting status independently where relevant.
Historical termination is not proof of current container removal. Corrected early
rejections need not make a later accepted completion a failure; preserve terminal
workflow/model diagnostics and the recorded outcome.

If reporting usage, separate confirmed model tokens, budget-charged tokens, and
unconfirmed reservations. Zero confirmed tokens cannot establish zero consumption.
Credential audit summaries may use documented bounded identifiers, backend, outcome,
code, cache status, and timestamps with event citations; never include values,
locators, headers, or raw backend responses. Do not reconstruct omitted private
settings from current configuration.
