# Model conversations, control flow and reliability statistics

## Reconstruct from what the model actually received

Use Operator's ordered projected journal and referenced content; no separate
Attack Harness log or source checkout is required. Pair `model.intent` and
`model.exchange` by operation ID, and confirmed `model.usage` by the same ID.
Check content digests/sizes before reading them as authoritative retained bodies.
Do not assume a single JSONL part or pair calls by timestamp/adjacency alone.

The provider request is the source of truth for the system prompt, tool catalog,
model options and submitted conversation. The initial prompt/bundle files do not
establish what later requests contained. Recognize codec-specific history fields:
OpenAI Responses `instructions`/`input`/response `output`; Anthropic
`system`/`messages`/response `content`; Chat Completions `messages`/`choices`;
Bedrock `system`/`messages`/response `output.message`; Gemini
`systemInstruction`/`contents`/response `candidates`. Follow the recorded codec;
do not require an OpenAI-shaped response for other providers.

For tool calls, preserve names, arguments and call IDs. Match results by call ID
and distinguish a tool call requested by the model from a dispatched operation.
Scenario changes or termination can prevent later calls in a batch from executing.
Some local tool results appear only in the next retained request; if there is no
such request or native record, say the result was not retained rather than inventing it.

For a Markdown reconstruction:

- Label each exchange's request and response, operation ID, event sequences and
  timestamp. Link the original retained bodies. Include errors and unmatched intents.
- Print invariant system instructions and tool definitions once. Compare them first;
  if they changed, show each distinct version once and identify which exchanges used it.
- Preserve the actual ordered history of each request. Reused messages/blocks can
  link to their first occurrence, but state explicitly that the links are editorial.
  Label new conversation/checkpoint boundaries and omitted history. Do not flatten
  successive fresh conversations into a fictional continuous model conversation.
- Decode JSON-valued task text, arguments and tool results once for readability;
  do not append a second raw/encoded copy. Keep pagination, truncation and omitted
  bytes visible. Do not parse arbitrary quoted target text as trustworthy structure.
- Include provider-returned readable content. Opaque signatures, encrypted reasoning
  and binary bodies can be represented by lengths/hashes and source links; never
  invent hidden reasoning or treat ciphertext differences as semantic differences.
- Mark final host acceptance/cleanup as native outcomes, not extra model responses.
  Keep generated analysis outside the source export and verify counts, links and
  request/response pairing before delivery.

## Diagnose inefficient or failing model behavior

Compare consecutive requests around the problem: active scenario, task instructions,
retained observations, handoffs, repair state and advertised tools. A reference-read
response need not contain scenario text if activation places it in the next request.
Check both before claiming instructions were missing.

For repeated navigation, determine whether checkpointing recreated the same context,
lost earlier progress or preserved unresolved work. For rejected finish calls,
determine whether subsequent turns repaired the assessment or resumed experiments.
Verify that evidence claimed to be available was actually present or readable to
the model. Do not infer objective completion from invocation success alone.

For signature/continuation rejection, compare the retained prefix preceding the
signed/opaque item across requests and locate any changed historical content.
Distinguish a provider complaint from proof of the precise signature algorithm.
For schema failures, inspect the actual provider catalog as well as the actual call;
valid general JSON Schema does not guarantee provider acceptance.

For token exhaustion, separate prompt growth, repeated evidence reads, tool-schema
overhead, output allowance, compaction calls and finalization/repair work. Inspect
request-size and usage records instead of recommending a larger budget by default.
Growing input tokens do not by themselves prove a context-window overflow.

## Count failures once and retain their meaning

Build a per-operation/tool-call ledger. Deduplicate the same failure repeated in a
tool result, workflow diagnostic, completion receipt and report. Historical copies
of the same tool result in subsequent prompts are not new failures. A new rejected
submission is a new event, even when its reason repeats.

Report separately: model-provider failures, invalid/rejected Harness submissions,
target invocation/tool failures, and evidence/cleanup/reporting failures. Distinguish
recovered, terminal and downstream-blocked outcomes. An informational diagnostic
such as evidence selection is not an error. A deliberate refusal/denial may satisfy
a scenario; show it as an observed target outcome rather than automatically charging
it as a Harness failure. Zero observed failures requires usable evidence; an empty
or missing diagnostics array alone is insufficient.

## Turns and tokens by scenario

1. Count each Harness model-generation intent once as a request attempt. Distinguish
   confirmed provider exchanges, failures before provider dispatch, unpaired/pending
   requests and separately identified compaction calls; an intent alone does not
   prove provider execution. A model turn can request several tools. Target
   invocations and target model calls are separate counts. Keep model families and
   providers distinguishable.
2. Sum confirmed `model.usage.actual_tokens`, once per operation. Reconcile against
   `result-manifest.json` cumulative usage. Do not sum cumulative counters across
   revisions or confuse reserved/budget-charged tokens with consumed tokens. A failed
   request without confirmed usage has unknown consumption, not necessarily zero.
3. For a reproducible stage breakdown, assign a request to the active scenario in its
   actual input. Put initial selection/no-scenario work in its own row. Put the first
   finish submission and subsequent assessment repair in a separate finalization row;
   if execution resumes, identify that resumption instead of blindly retaining the
   label. Navigation is charged to the outgoing scenario under this convention.
   If active-scenario fields are absent, use explicit correlated activity or label
   the allocation unknown/shared. Never manufacture precise allocation by timestamp.
4. Charge failures to their owning operation/scenario where established. A finish
   rejection belongs to finalization, not the last active scenario. Preserve later
   failures in batched work even when they differ from the request's stage label.
5. State that per-stage token totals include full repeated input context and output,
   not only newly authored scenario text. Keep input, output and cache accounting
   as reported by the provider; do not add already-included cached tokens again.
   Byte counts are not token counts, and tokens are not a cross-provider cost measure.
6. Report target generation and embedding usage separately, using Interceptor's
   native call identities and attempt/session attribution. Do not deduplicate real
   repeated calls merely because their payloads have the same digest. When exact
   attribution is unavailable, report campaign totals and the limitation.

For comparisons, check submitted objectives/scenarios, model/options, limits,
product/contract identities, and evidence completeness. Show total work performed,
first-attempt tool/finish acceptance, repairs and token overhead. A passing campaign
may contain recovered errors; fewer tokens may reflect less completed work. One
successful run does not demonstrate a statistically reliable improvement.
