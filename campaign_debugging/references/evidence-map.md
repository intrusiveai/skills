# Native evidence map

## Discover, do not assume a wrapper layout

Use `rg --files` (including hidden paths when needed) to find reports, manifests,
JSONL parts, session metadata and logs beneath the supplied path. Match IDs before
combining records. Read relevant slices rather than dumping entire blob stores.

| Native source | What to inspect |
| --- | --- |
| Operator saved run and CLI receipts | Saved start/completion, preparation stage, campaign/state links, selected configuration identities. Receipt filenames may be chosen by the caller. |
| Operator report/export | `report.md`, `result-manifest.json`, `execution-bundle.json`, `target-evidence-set.json`; `generation.json`/`export.json` where present. |
| Operator projected journal | Ordered `events/<part>.jsonl`; each event's sequence, revision, kind, metadata and content descriptors. |
| Operator retained bodies | Follow descriptor `path`, `role`, digest and size into `content/`. Never assume every descriptor has copied bytes. |
| Operator accepted inputs | `input/scenario-bundle.json` and retained launch inputs. Compare the actual request's instructions/tools, not only input templates. |
| Operator native archives | Exported `evidence/<digest>.tar`, or state-root `campaigns/<id>/native-evidence/<session>/<digest>.tar`; follow the selected evidence set. |
| Interceptor session | `session.json`, `events.jsonl`, `state.jsonl`, `attempts.json`, `checkpoints/`, referenced `blobs/sha256/`, and application logs when retained. |
| Interceptor archive | `manifest.json`, `evidence-bundle.json`, optional `final-evaluation.json`, native journals, registries, file manifests, checkpoints and blobs. Discover any archive prefix before interpreting paths. |

Operator generations normally live under
`<state-root>/campaigns/<campaign>/reports/<generation>/`. Interceptor live data
normally uses `<data-root>/sessions/<session>/`. Do not assume a developer's home
directory, fixed session ID, model provider, target language, or source repository.
Native archives need not contain application stdout/stderr; missing logs do not
imply empty logs. Live mutable files may be in Docker volumes rather than host
staging directories.

## Read and export using native commands

Check the installed release's help before executing examples. Use the saved run
link when available; do not mix `--run` with campaign/config/state-root selectors.

```sh
operatorctl inspect --run /path/to/run
operatorctl campaign status --run /path/to/run
operatorctl campaign logs --run /path/to/run --after 0 --limit 1000
operatorctl report --run /path/to/run
operatorctl export --run /path/to/run --output /path/to/new-export
```

Report/export derive files from retained state; they do not collect new target
evidence, resume a campaign or establish cleanup. Active writers can prevent
generation. Preserve earlier generations and diagnose export failure separately
from execution. A missing campaign after failed preparation is not an empty success.

With the original Interceptor data root and session available:

```sh
INTERCEPTOR_DATA_DIR=/path/to/data interceptor logs verify SESSION_ID
INTERCEPTOR_DATA_DIR=/path/to/data interceptor logs tail SESSION_ID --channel control
INTERCEPTOR_DATA_DIR=/path/to/data interceptor logs tail SESSION_ID --channel evaluation
INTERCEPTOR_DATA_DIR=/path/to/data interceptor logs tail SESSION_ID --channel attack
```

`logs tail` reads existing events, not a continuous stream. Native session export
uses `interceptor logs export SESSION_ID --output /path/to/new-evidence.tar` for an
eligible stopped/error session. Do not stop a live session merely to export it.
Prefer Operator's already retained native archives. If new collection/import is
needed, explain the gap and use the matching release's native workflow within the
user's authorization; do not implement an alternate collector or copy private live
application files as a substitute for native evidence.

## Integrity and correlation

- Verify raw content and archive bytes against their recorded SHA-256 and length.
  Prefer native report/export/session verification for document bindings and
  journal chains. Operator canonical JSON and Interceptor native serialization
  have different hashing rules; do not apply JCS indiscriminately.
- Archives are untrusted inputs. Inspect members before extraction; reject path
  traversal, absolute paths and unsafe links, and extract only into a new analysis
  directory. Do not overwrite evidence or restore archived ownership onto the host.
- Correlate Operator campaign ID, operation/request ID, attempt ID, scenario
  attribution and run revision. Pair model requests/responses by operation ID;
  pair tool results by tool-call ID. Model-local handles are not native IDs.
- Correlate Interceptor session, turn/invocation, native operation and attempt
  context. Use recorded attribution, including `attribution.window` and
  `attribution.observed_attempt_id` where the schema supplies them, rather than
  assuming a top-level attempt ID. Observed during an attempt is not proof of
  causation. Never join sessions using timestamps or a model-quoted session ID alone.
- Restore can replace the native session. Follow `parent_session_id`,
  `parent_checkpoint` and Operator's binding/revision history; inspect every
  relevant source and replacement archive. Do not attribute an earlier session's
  receipt to a later invocation.
- Distinguish `host-only-omitted`, unavailable, partial, truncated and corrupt data.
  Missing legacy fields stay unknown. Internal hashes establish integrity, not
  independent truth or an external signature.

## Authoritative references

Use documentation matching the retained version; `main` links are discovery points.
This guide was checked against Operator `0596054f37969a15e8072127758f900d42ccda06`
and Interceptor `7d66f54347cad7c9880f122740be4b46776f360e`.

- [Operator reporting and export](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/REPORTING.md)
- [Operator campaign start](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/CAMPAIGN_START.md)
- [Operator native evidence service](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/EVIDENCE_SERVICE.md)
- [Late collection](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/LATE_EVIDENCE.md) and [evidence import](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/EVIDENCE_IMPORT.md)
- [Interceptor evidence/storage](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/evidence-and-storage.md), [CLI](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/cli-reference.md), and [snapshots](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/snapshots-and-restore.md)
