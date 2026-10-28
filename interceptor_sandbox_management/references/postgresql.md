# Managed PostgreSQL and pgvector

Use this guide for an application that uses PostgreSQL through its normal driver,
including a pgvector-backed retrieval store. Interceptor packages and manages the
native engine inside its wrapper, with a TLS proxy for observation and response
injection. Do not add a separately managed database, host PostgreSQL installation,
or a database process to the target application's Dockerfile.

Use the [database reference](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/postgresql.md)
for exact fields, limits and compatibility, and the
[Python/Node examples](https://github.com/intrusiveai/interceptor_sandbox/tree/main/examples/postgresql)
for runnable configuration. PostgreSQL support does not imply MySQL, SQL Server,
Oracle, or arbitrary database protocol support.

## Assess and configure the application's actual database path

Identify connection construction, driver/pool settings, schemas and grants,
startup checks, migrations, queries and writes, vector codecs, and TLS options.
Use supported connection configuration to point the unchanged application at the
declared endpoint. A connection pool keeps independent backend connections; size
it within the service's `max_connections` allowance.

Declare `kind: postgresql`, its local listener and hostname, database, synthetic
roles, ordered `schema`/`seeds` SQL assets, and any table injection policies. Enable
Blueprint DNS and TLS. For example, this service fragment belongs in a complete
application Blueprint:

```yaml
network:
  dns: {enabled: true}
  tls: {enabled: true, trust_mode: auto}
services:
  - id: database
    kind: postgresql
    listen: 127.0.0.1:15432
    hostnames: [database.sandbox.test]
    postgresql:
      database: support
      roles:
        - {name: agent, password: synthetic-password}
      schema: [assets/schema.sql]
      seeds: [assets/seed.sql]
      tables:
        - id: documents
          schema: public
          name: documents
          keys: [id]
          fields: [body, metadata]
          allow_create: false
credentials:
  - id: database-password
    environment_variable: PGPASSWORD
    value: synthetic-password
    accepted_by: database
```

The referenced SQL files must exist inside the Blueprint and be sealed with it.
Schema SQL creates tables, constraints, indexes, and the application's required
table/sequence grants. pgvector is enabled before dependent schema SQL runs.
Seed SQL inserts actual initial records, including related rows and supplied
embedding vectors. Loading completes before application readiness; invalid SQL,
constraints or vector dimensions fail startup. Use SQL assets, not shell commands,
psql metacommands, production data, or a manual post-start import.

Define vector dimensions in the schema. Keep document and query vectors compatible
in model, representation and dimensions; matching dimensions alone are insufficient.
Seeds preserve supplied vectors without calling a provider. Configure
[remote embeddings](remote-embeddings.md) separately when the application computes
embeddings. Changing the embedding model may require rebuilding the seed corpus.

For libpq/Psycopg, set the application's normal connection options or launch
environment: `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, the declared synthetic
`PGPASSWORD`, `PGSSLMODE=verify-full`, and
`PGSSLROOTCERT=/opt/interceptor/tls/ca.pem`. Certifi injection does not configure
libpq. For Node `pg`, use the application's existing way to configure `ssl.ca`
with that public PEM and certificate/hostname verification enabled. Inspect its
connection-string precedence instead of assuming Node's extra-CA environment
variable overrides an explicit SSL configuration. If it exposes no suitable trust
configuration, report that integration gap; do not disable verification.

Authentication uses SCRAM-SHA-256. Required channel binding, COPY, and replication
are unsupported; report their use explicitly. Use the declared proxy endpoint,
never the private backend socket, database files, management roles or TLS keys.

## Build and operate

Follow the normal validate/seal/`app build`/verify/run flow. The target image
supplies its ordinary database drivers; Interceptor supplies the pinned engine,
pgvector, libraries and backup tools during wrapper construction. The first build
needs access to pinned build inputs; sandbox execution needs no downloads, host
database, source checkout, or Go toolchain. macOS uses the packaged Linux companion
matching its architecture. Keep the release archive layout intact.

Do not mount a live PostgreSQL data directory as an application mutable root.
Interceptor owns isolated database storage and private sockets. Each fresh session
loads the sealed starting records; restore uses checkpoint contents instead.
Database wrappers record the supervisor UID: rebuild under the intended host
account if it changes. Preserve packaged notices under
`/opt/interceptor/postgresql/licenses/` when distributing wrappers.

Set connection, query/lock/idle-transaction, result and storage limits for the
actual workload, allowing for database/WAL and snapshot overhead. Diagnose the
reported limit before increasing it. Storage monitoring permits brief overshoot;
it is not an exact filesystem quota. Oversized results are failures, not successful
truncated answers. Keep application roles limited to the required grants.

## Distinguish the injection boundaries

| Intent | Native mechanism | Meaning |
| --- | --- | --- |
| Change what one query returns | `database_response`, `simulation`, `once` or `standing` | Changes eligible returned values after execution; stored records and native transaction outcomes stay unchanged by the rewrite |
| Change a stored record | `environment_state`, `fidelity` | Commits an allowed update or explicitly permitted creation; ordinary subsequent reads see it |

Response selectors use service, call ordinal and request-body predicates over
`query`, typed `parameters`, and zero-based `result`. Place values at
`/rows/<row ordinal>/<column ordinal>`, continuing with JSON keys for JSON/JSONB.
Use column ordinals for duplicate aliases; do not assume row order without
`ORDER BY`. Call ordinals count matching nonempty results, including separate
fetches. Observed-turn attribution does not make response selection turn-scoped.
Text/varchar and JSON/JSONB support rewriting in text/binary formats; numeric and
vector values pass unchanged. Preserve row/column shape, type metadata and NULL
semantics; invalid placement is a failure, not successful delivery.

Persistent selectors use `service`, a declared table policy ID as `collection`,
and a JSON object in `key` containing all unique key columns, including composite
keys. Only declared fields can change. Creation requires `allow_create`, bounded
`max_records`, root `replace`, and a record matching the declared keys and allowed
fields. It never silently upserts. Unlike HTTP/MCP creation, it needs no create
route or tool. Native constraints and triggers remain active. Disabling, deleting
or consuming an injection does not undo a committed write; use an intended
checkpoint or a fresh seeded session when a reset is required.

Neither mode confirms model delivery until native evidence observes the payload
in the final outbound generation request. Preserve application filtering, document
digest checks and validation even when they prevent delivery. An embeddings call
is not generation-model delivery. Campaign route policy belongs to Operator;
scenario content belongs to the user, not this configuration guide.

## Verify committed state and restoration

Author `database_query_match` oracles with sealed, bounded read-only `match.query`
SQL and `match.equals` as an array of result rows. They read committed state through
a private path that bypasses response injection. A match requires a result changed
from the baseline and equal to the expected value. Harness mutations reset the
baseline, so an injected record alone does not establish an application outcome.
Native verdicts may remain cumulative; a matching observation is not proof that
the associated turn caused a change.

Database evidence distinguishes requests, original results, rewrites, errors,
statement outcomes, transaction status, harness mutations and independent oracle
reads. UPDATE completion inside a transaction, or COMMIT without the business
state check, does not prove the intended outcome. Required capture failures follow
[the existing failure policy](environment-operation.md#required-evidence-storage-failures).
Already forwarded SQL may have committed; retain uncertainty and do not retry it
to reconstruct evidence. Agent-authored logs are unnecessary.

Snapshots run application quiescence/save hooks before freezing database work,
drain execution, and reject unresolved transactions. Idle pools are allowed.
Native logical backups count against snapshot budgets and preserve database,
injection and oracle state at the checkpoint. Restore verifies integrity and
compatibility, restores a fresh backend without replaying seeds/writes, then
initializes the application so its pool reconnects. Conversation context still
needs sufficient application persistence or an [application state adapter](application-state-adapters.md);
do not serialize sockets, pools, prepared statements or open transactions.

For a working integration claim, exercise the actual driver with TLS verification:
initial seeded queries and vector retrieval, representative writes, and negative
credential/hostname cases. When claiming injections, verify response-only storage
invariance, persistent retrieval, model delivery, and committed versus rolled-back
oracle outcomes. When claiming restore, change state after a checkpoint and verify
both database and application continuation after restore. Check fresh-session
isolation and retain native evidence; sealing or connection success alone is
insufficient.

For dedicated qualification, use the upstream examples and
`scripts/qualify_release.py --postgresql --adapter-language python` (or `node`)
with its archive, version/source, image, client and fresh output arguments.
`--database-test` adds a matching prebuilt Linux native-protocol test binary;
`--evidence-failure` deliberately faults only the runner's disposable storage.
The optional customer-support runner exercises an unchanged agent with deterministic
model/embedding fixtures. These are developer qualification tools, not a Go
requirement for release users. Report actual drivers, architectures, artifact
origin, fixture/live-provider use, and unexercised paths.
