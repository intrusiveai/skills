# Remote embeddings alongside generation

Read this when assessing, configuring, or troubleshooting an application that calls
a remote embeddings model. Generation, embedding computation, and vector-database
access are distinct dependencies. This transport does not emulate PostgreSQL or
pgvector, migrate a corpus, or install a local embedding model.

## Check the selected executable

This guide describes the implementation verified at
[5b255f9](https://github.com/intrusiveai/interceptor_sandbox/tree/5b255f904b0f4bf2026ac20b06e282143e098807).
Use its [provider documentation](https://github.com/intrusiveai/interceptor_sandbox/blob/5b255f904b0f4bf2026ac20b06e282143e098807/docs/model-providers.md#remote-embeddings)
and [executable example](https://github.com/intrusiveai/interceptor_sandbox/tree/5b255f904b0f4bf2026ac20b06e282143e098807/examples/remote-embeddings),
or the equivalents for the selected release. Check `interceptor version`, the
archive's `release.json` source revision, and matching CLI options/implementation.
A rolling `0.1.3` candidate version or an existing candidate branch does not prove
that this feature is included. Report a mismatch and follow the user's authorized
upgrade choice rather than silently selecting another release.

## Configure independent host access

Keep the existing generation provider, authentication, and model allowlist. Add the
optional embeddings group only when the application uses the supported remote API.
For example, extend the normal `interceptor run` command with:

```sh
--embeddings-provider openai-compatible \
--embeddings-base-url https://api.openai.com/v1 \
--embeddings-auth secret-store \
--embeddings-credential-config /absolute/private/credentials.yaml \
--embeddings-credential-id embeddings-key \
--allow-embedding-model APPROVED_EMBEDDING_MODEL
```

Use the selected endpoint, credential reference, and exact model/deployment ID.
`--allow-embedding-model` is repeatable and requires at least one nonempty value.
Generation's `--allow-model`, base URL, and credentials are never inherited. The
two groups may explicitly select the same endpoint/key, or use different providers.
Generation workload identity can coexist with a separately stored embeddings key.

Embeddings authentication choices:

- `secret-store`: supply both embeddings credential flags. They use the existing
  host credential-store format and audited resolver, including AWS Secrets Manager.
  Authentication defaults to this mode only when an embeddings credential ID is
  supplied; the credential file is still required.
- `api-key-env`: select `--embeddings-auth api-key-env` and supply
  `--embeddings-api-key-env NAME` without stored-credential options. This explicit mode is supported with `--production`; do not assume
  `OPENAI_API_KEY` is implicitly selected.
- `none`: explicitly select an intentionally unauthenticated compatible gateway;
  supply no credential options. It is not a fallback for failed authentication.

Partial groups, missing keys, and conflicting credential choices fail. With no
embeddings group, requests fail explicitly instead of using the generation provider.
Keep real keys on the host, out of Blueprints, adapters, containers, logs, and command
arguments. Reuse existing access authorization; configuring a client is not evidence
of a successful live provider call.

## Configure the application and its image

Trace how the application actually constructs both SDK clients. Point the embeddings
client at `http://127.0.0.1:18080/v1`; retain the generation protocol's appropriate
local endpoint (OpenAI-compatible generation can use the same base). Configure each
model name and declared synthetic SDK credentials (`accepted_by: model-proxy`). There is no universal embeddings
environment variable: set constructor options or variables the application reads.
A separately supplied invocation adapter can apply these settings when its normal
application API supports that. An initializer can embed documents before readiness;
later invocations can embed queries. Set bounded SDK and startup/turn timeouts.

The target image supplies SDK dependencies. LangChain's embeddings client may
submit token arrays and request base64 vectors; these do not require a local
embedding model. If the client uses a tokenizer, package its data in the image
with readable permissions before isolated execution. Declare the cache path in
the Blueprint's launch environment: arbitrary Dockerfile `ENV` values are not
inherited by the application. The pinned example uses the SDK-supported
`DATA_GYM_CACHE_DIR: /app/tokenizer-cache`; use the actual selected client's cache
mechanism. Do not depend on a first-use download inside the network-isolated target.

Document and query vectors must use compatible models, dimensions, and preprocessing.
Changing a model can require re-embedding the corpus and adjusting the vector schema.
Equal dimensions alone do not establish compatibility. Keep that application/data
work separate from configuring Interceptor's remote model transport.

## Supported requests and limits

The supported operation is exactly `POST /v1/embeddings`, with `model`, `input`,
optional positive integer `dimensions`, `encoding_format` (`float` or `base64`),
and `user`. Input can be nonempty text, a text batch, integer tokens, or a batch
of integer-token arrays. Query overrides, unsupported fields, malformed shapes,
and unauthorized models fail before provider contact. Native Bedrock/Gemini
embedding APIs, multimodal inputs, and asynchronous provider batch jobs are outside
this route; an OpenAI-compatible endpoint must actually match its contract.

Use at most **128 inputs** per request and **4 MiB** per request/response body,
or the smaller Blueprint blob limit. Configure SDK chunk sizes accordingly and
reduce them further for wide vectors. The caps allow evidence duplication and
base64 expansion inside the existing 32 MiB bridge frame; do not raise global
limits to hide oversized batches. Provider-specific token limits still apply.
Vector values, dimensions, and index associations are checked without substituting,
resizing, or regenerating vectors. A reported model can differ from a deployment alias.

Provider errors preserve bounded bodies, HTTP status, and allowlisted retry headers.
Interceptor adds no retries; account for the selected SDK's retry behavior and
timeouts. Evidence storage failures are visible. Host configuration survives managed
target replacement; application memory and remote provider state are not snapshotted.

## Verify and troubleshoot

For a requested working integration, run the normal validate/seal/build/verify/run
workflow and exercise a representative application operation. Check:

- Exercise embeddings at the phases the application uses, including document
  embedding during initialization when applicable and query embedding during later
  turns. Verify generation in the same session and independent provider credentials.
- Actual SDK decoding produces the expected vector count, dimensions, input
  associations, and usable values. Exercise a disallowed model and a controlled
  provider error or timeout; rejected models must not reach the upstream.
- Protected `model_exchange` evidence uses codec `openai_embeddings`, records
  requested/reported model, input count, dimensions, status, latency, usage, and
  body references. Input tokens count once toward the session budget, including
  completed provider calls whose evidence storage fails. Startup calls without a
  turn ID remain session activity.
- Embeddings do not consume generation injections or confirm their delivery, even
  when embedding input contains injected text. Do not interpret an embedding
  exchange as proof that the generation model received an instruction.

For archive qualification, use the pinned example's full
`scripts/qualify_release.py --adapter-language python --embeddings` command with
the required archive, source/version, image, client, and fresh output directory.
It exercises pinned OpenAI/LangChain SDKs against separate deterministic host
fixtures, outside the checkout with Go unavailable to the CLI, and checks the
packaged companion on macOS. It creates and cleans up its own resources; use a
dedicated test session. Building the qualification client is developer tooling,
not a Go requirement for released Interceptor users.

Fixture success proves transport/client interoperability, not commercial model
quality or account access. Use a live provider only with the selected authorized
endpoint/model/credential, and report whether it was exercised. Report the actual
SDK versions and host/container architectures tested. Python SDK qualification
does not establish Node SDK interoperability; test that client's real requests
when a Node application's integration is in scope. Distinguish CI-produced archives
from local builds and configuration checks from actual managed-restore execution.

Diagnose missing flags as a version mismatch, initialization cache downloads as an
image/launch configuration issue, and model-denied errors against the embeddings
allowlist. Check endpoint/authentication independently of generation, and reduce
batch size for body limits. Database connectivity failures remain a separate gap.
