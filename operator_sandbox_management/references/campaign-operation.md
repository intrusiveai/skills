# Campaign operation

Use existing validated inputs and the selected installation to execute or observe
a campaign. Do not reauthor scenarios or change target policy just to make a run
proceed. Substitute inspected paths and identifiers in these examples.

## Start a new run or a submitted campaign

For supplied inputs that have not been submitted, use the combined workflow:

```sh
mkdir -p ./runs
operatorctl run --config /absolute/private/config.yaml \
  --bundle ./scenario-bundle.json --environment ./operator-environment \
  --output ./runs/example
```

Add `--artifacts` and explicit instruction selections only when needed.
For an existing submitted run:

```sh
operatorctl campaign start --config /absolute/private/config.yaml --run ./runs/example
```

Start prepares the request if no saved start exists. Both commands default to
foreground execution, inherit caller authentication, and remain attached through
execution and finalization. Use a managed terminal/process session that can remain
open; do not invent a background launcher.

Live preparation checks the exact installed contract, local Harness image,
embedded instructions/compatibility, frozen inputs, model configuration, target
policy, and current target binding. Operator supports one execution worker per
installed state root. Do not make another state root to bypass that constraint.
For Interceptor, keep the intended instance running through finalization.

Prefer a fresh output for a new submission. The combined `run` can reuse an
existing output only if its captured inputs and explicit selection match exactly;
it cannot overwrite or repair it. Repeating an already claimed start observes
the saved request and does not launch another worker.

Read [campaign start](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/CAMPAIGN_START.md)
for lifecycle details and
[administrator workflows](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/ADMIN_WORKFLOWS.md)
for combined-run behavior.

## Optional independent service execution

Use `--service` only when requested and the intended account/service manager is
configured. Foreground use needs no service manager. A service uses independently
configured authentication, does not inherit terminal secrets automatically, and
must not restart at boot, login, or after failure.

The execution mode is frozen in the start request. Service submission is not
campaign acceptance. A timeout or uncertain reply retains the same lookup key;
inspect it rather than allocating a replacement start.

With `--service --wait`, waiting is observation only. Canceling that observer
does not stop the worker. Canceling the foreground execution command does request
terminal cleanup. `--wait` is redundant for a newly started foreground run.
Read the service section of the upstream start guide only for this mode.

## Observe progress and outcomes

Capture the returned absolute run directory, campaign ID, and start-request ID.
Use the saved run link for normal observation:

```sh
operatorctl inspect --run ./runs/example
operatorctl campaign status --run ./runs/example
operatorctl campaign logs --run ./runs/example --after 0 --limit 1000
operatorctl campaign wait --run ./runs/example
```

These observers resolve the saved state root without current configuration.
Do not combine `--run` with `--config`, `--campaign`, or `--state-root`.
If only the campaign identity is available, use:

```sh
operatorctl inspect --campaign CAMPAIGN_ID --state-root /absolute/private/operator-state
```

A submission with no start link should be checked with `validate --run`, not
`inspect`. A failed preparation may have a saved start but no campaign journal;
prefer `--run` so its completion diagnostic remains accessible.

Distinguish the recorded facts:

- submitted/prepared, accepted, actually dispatched, and execution closed;
- Harness assessment acceptance and observed Harness exit;
- target closure, injection cleanup, optional target stop, and container cleanup;
- evidence completeness and report-generation status.

An accepted start or assessment does not prove a successful experiment. A retained
status is not itself a live health probe. Preserve uncertain operations and missing
evidence rather than converting them to success or confirmed absence.

For Interceptor targets, a native turn association means **observed during** that
invocation, not caused by it. Do not infer a committed mutation from model text or
a rewritten tool result. Use Interceptor management for detailed observation
semantics; the [native evidence contract](https://github.com/intrusiveai/interceptor_sandbox/blob/65ddd10a9867fec75871bf8470f1521b0dc467de/specs/observed-turn-evidence.md)
defines the limits of timing-based association.

### Database state across attempts and restore

Deleting or disabling a persistent database injection does not undo its committed
write. Successful injection cleanup is therefore separate from restoring the
baseline. Follow the requested campaign's permitted checkpoint/fresh-session
strategy when attempts require isolation; do not add a reset to an intentionally
stateful sequence or issue ad hoc SQL to clean up the target.

Snapshots reject unresolved database transactions but allow idle connection pools.
Restore replaces the sandbox session and binding, restores database/injection/oracle
state, and reconnects the application normally. It still requires sufficient
application persistence for conversation continuity. Use Interceptor management
for target-side diagnostics rather than changing application transaction behavior
or discarding state to force capture.

A response rewrite, successful statement, and committed business outcome are
separate observations. Use the retained independent database oracle for the
business condition, preserve observed-during-turn attribution, and keep harness
writes distinct from application effects. A database COMMIT may have taken effect
before evidence storage fails: retain that uncertainty and apply the existing
no-replay failure handling below. Injection cleanup cannot resolve it.

## Terminate and verify cleanup

For an explicit stop request, use the campaign ID and its original state root:

```sh
operatorctl campaign terminate --campaign CAMPAIGN_ID \
  --state-root /absolute/private/operator-state
operatorctl inspect --run ./runs/example
```

An explicit state root without `--config` bypasses damaged/default configuration.
Add `--docker-bin /absolute/path/to/docker` if needed. The command uses the saved
Docker endpoint, daemon, and full container identity; changing the current Docker
context cannot redirect termination.

Termination stops the exact Harness container and records the outcome. It does
not by itself prove container removal, injection cleanup, Interceptor target stop,
or complete evidence. Worker finalization records those independently; target stop
depends on the original profile's opt-in. HTTPS has no native target-stop operation.
Read [termination](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/DOCKER_TERMINATION.md)
when stop or recording remains unconfirmed.

## Diagnose failures without replay

Inspect the saved completion and bounded diagnostics from a separate CLI process.
Use the reported stage to choose the narrow fix:

- image/contract/embedded-metadata failure: reconcile installation and Harness;
- target/profile/attachment failure: check the chosen target and original binding;
- model failure: check the recorded provider status/category, codec/options, model,
  and selected authentication without printing raw errors or secrets;
- invalid-call or conclusion failure: inspect the reported field/rule and matching
  Harness/contract versions; do not fabricate receipts or weaken validators;
- Interceptor `evidence_storage_error` or `evidence_incomplete`: follow
  [evidence failure handling](#interceptor-evidence-storage-failures); missing
  capture is not an ordinary model rejection or a resisted attack;
- cleanup/report failure: preserve the original execution outcome and address
  that separate failure.

A claimed start remains claimed after failure, even when no target attempt ran.
Do not delete claims, rewrite retained inputs, reattach a failed campaign, or
replay uncertain operations. After fixing the cause, start a separate campaign
only within the user's requested scope. `--new-campaign` deliberately changes
the run's current start link while preserving older records; it is not resume.
A previously bound Interceptor instance may require a fresh session/process,
which belongs to Interceptor management.

Sleep, logout, process loss, or Docker interruption is terminal for execution.
Startup reconciliation can clean up prior resources using saved identities, but
cannot resume them. Read
[startup recovery](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/STARTUP_RECOVERY.md)
only when unresolved resources block a new campaign. Never delete state or switch
targets to make that uncertainty disappear.

### Interceptor evidence-storage failures

Treat required native capture failure as a terminal campaign problem. Preserve
uncertain effects: the target may have completed a model call or service mutation
before its response evidence was lost. Do not turn missing evidence into success,
confirmed absence, or a resisted attack, and do not replay affected operations.
Previously established results remain facts within their original scope; they do
not make the affected turn's evidence complete.

Inspect the saved run/campaign completion and target status. Retain available
campaign and Interceptor evidence, including explicit partial/unavailable status.
A failed turn without a retained feedback receipt may report
`evidence_storage_error` rather than yield new feedback. Do not fabricate a receipt
or interpret its absence as an empty successful result.

Verify campaign closure, injection cleanup, optional target stop, and container
cleanup independently through the existing lifecycle. Do not assume storage
failure itself completed cleanup, bypass target-stop policy, or purge the records.
Hand off storage diagnosis/repair and fresh-session setup to Interceptor
management. Fixing the target does not resume the failed campaign; any separate
new campaign follows the existing authorization and no-replay guidance above.

## Retain results and hand off reporting

The worker attempts a native report after execution and durable completion.
Record `generated`, `report_failed`, or `not_started` separately from execution.
Use the saved run/campaign and retained report locations to hand off to results
reporting for generation, interpretation, or a requested portable export.

Native report/export commands operate on retained files after active writers close;
they do not restart the campaign or collect missing native evidence. See
[reports and exports](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/REPORTING.md).
Do not rerun an experiment merely to reconstruct missing historical details.

If the user requests recovery of missing Interceptor evidence, read
[late collection](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/LATE_EVIDENCE.md)
or [archive import](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/EVIDENCE_IMPORT.md).
These use saved provenance and are separate from report generation. Collection
does not stop targets, invoke applications, or resume work. Partial evidence
remains partial even when transport succeeds. Late collection can retrieve
records that were retained; it cannot recreate observations that were never
stored. Keep the original capture failure visible in the reporting handoff.

Only for requested deletion, use the narrowest campaign purge selector and follow
[purge](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/PURGE.md).
Stopping/exporting does not imply deletion permission. Purge removes retained
campaign evidence and report sources while preserving installation configuration,
submitted projects, independent exports, and Interceptor's own data.

## Verify the requested workflow

For a working campaign, follow one representative bounded objective through
submission, start, an actual target attempt and permitted observation, execution
closure, separate inspection, and retained evidence. Confirm the claimed cleanup
and report outcomes independently. A test that only submits inputs, checks an
image, or accepts a start is not a completed campaign.

Report observed results and gaps with the run/campaign lookup. If verification
used fixtures or stopped before live execution, state that limit explicitly.
