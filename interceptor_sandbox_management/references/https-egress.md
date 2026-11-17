# Declared HTTPS forwarding

Use this guide when an application needs an approved external HTTPS service,
such as a tracing collector or guardrail API. A declared HTTPS seam routes the
application's request through local DNS/TLS and the private bridge to a host
connector. The container retains `--network none`; the host contacts the configured
real origin. See the [upstream configuration guide](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/https-egress.md)
and [Python example](https://github.com/intrusiveai/interceptor_sandbox/tree/main/examples/https-egress/python).

## Configure both sides

In the Blueprint, enable `network.dns` and `network.tls`, configure the application's
verified CA trust, and declare `network.https_seams` entries with unique `id` and
`hostname`. Names/IDs cannot overlap simulated services or identity endpoints.
Use the application's existing endpoint settings, with synthetic credentials
declared as `accepted_by: SEAM_ID`. A declared hostname may preserve the real
service's hostname; it still resolves to the local TLS front door inside the target.
Seal, build, and verify after changes. Wrappers are bound to the supervisor's host
UID; rebuild when changing the execution account.

Create a separate host-only file. This fragment demonstrates one binding:

```yaml
seams:
  - id: guardrail
    origin: https://guardrails.internal.example:8443
    ca_file: private-service-ca.pem
    auth:
      kind: header
      header: Authorization
      credential: guardrail-api-key
      prefix: 'Bearer '
```

Select the actual authorized origin and existing credential reference. Every
declared seam requires exactly one host binding. `origin` must be HTTPS, with no
userinfo, query, fragment, or path other than `/`. Optional `ca_file` resolves
relative to this file and supplements system trust. Omit it when ordinary system
trust suffices. Application paths/queries are forwarded under the fixed origin.

`auth.kind` supports explicit `none`, `basic` with `username_credential` and
`password_credential`, or `header` with `header`, `credential`, and optional
`prefix`. References resolve through the host credential store; real values never
enter the Blueprint. The connector removes application credentials and adds host
authentication. Generation and embeddings retain their separate settings.

Add `--https-seam-config /absolute/private/https-seams.yaml` and the applicable
`--credential-config /absolute/private/credentials.yaml` to the normal run command.
Bindings/credentials load at startup; restart to change them. Restore requires
the same origins, references, and private CA bytes. Rotation behind an unchanged
reference is allowed when starting a new process.

## Bound behavior and diagnostics

Bodies use Blueprint `limits.max_blob_bytes`; exchange deadlines use the turn
timeout, capped at ten minutes, including background requests. The connector
returns redirects without following them and adds no retries. SDK retries remain
the application's choice. Streaming, gRPC, WebSockets, CONNECT, cookie-based
authentication, and mutual TLS are unsupported.

Snapshots drain admitted calls and temporarily reject new ones. External service
changes and traces are not rolled back, and pending requests are not replayed.
A failed response does not prove the external service performed no work.

For requested troubleshooting, set per-binding `debug.enabled: true`, optionally
`debug.max_exchange_bytes` (default 65536) and `debug.max_total_bytes` (default
16777216), then restart. Inspect the private session's
`logs/https-seam-<id>-debug.jsonl` and connection logs. Captured bodies are bounded,
base64-encoded diagnostics; truncation does not truncate forwarded traffic.
Managed credentials are redacted, but application-specific sensitive data may
remain. Disable debug and restart when finished; deletion follows the user's
requested retention scope.

Seams expose no injection surfaces, model/service exchanges, turn observations,
oracle inputs, or campaign feedback. Debug files are excluded from snapshots and
standard evidence exports. Operator/Harness need no seam-specific settings.
Evaluate the target through its ordinary operation and permitted observations.

Verify the full requested workflow with the actual SDK: startup/background calls,
a representative application operation, and shutdown flushing when applicable.
Confirm receipt in the intended external service before claiming successful
ingestion. Report fixture versus real-service verification; a local HTTP success
alone does not prove the remote service stored the data.
