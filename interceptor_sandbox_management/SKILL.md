---
name: interceptor-sandbox-management
description: Manage INTRUSIVE.AI Interceptor Sandbox installation, configuration, Environment Blueprints, wrapper builds, sessions, snapshots, and native target evidence, including model, embeddings, and managed PostgreSQL integration. Use only for requests or established context involving this INTRUSIVE.AI component or onboarding an application into it. Not for general container, database, proxy/interceptor, model-provider, or application management.
---

# INTRUSIVE.AI Interceptor Sandbox Management

Deliver the requested Interceptor installation, application environment, or session
operation, with evidence of what works and explicit remaining gaps.

Apply this skill when the request or established context identifies INTRUSIVE.AI
Interceptor Sandbox, its repository, or native Blueprint/session artifacts.
Application sources alone, a generic sandbox, or a PostgreSQL/embeddings problem
do not establish that scope. Operator campaign execution, scenario authoring,
results reporting, and campaign evidence diagnosis have separate skills.

## Choose the relevant workflow

Read only the guide for the current task, then follow its conditional references.

| Request | Read |
| --- | --- |
| Install or upgrade; configure Docker, model access, credentials, or host execution | [Setup and configuration](references/setup-and-configuration.md) |
| Onboard an application; create or change its simulated world or Blueprint | [Blueprint creation](references/blueprint-creation.md) |
| Use an existing Blueprint; seal/build/start; inspect, snapshot, restore, stop, or export | [Environment operation](references/environment-operation.md) |

For Python/Node invocation glue supplied outside the target image, read
[invocation adapters](references/invocation-adapters.md) when assessing, building,
or troubleshooting that interface. For applications using a remote embeddings
model alongside generation, read [remote embeddings](references/remote-embeddings.md)
when assessing model access, configuring the host, or verifying runtime behavior.
For Python HTTPS clients, read [Python CA trust](references/python-ca-trust.md)
when declaring environments, building wrappers, or diagnosing certificate failures.
For source-to-image onboarding or filesystem write failures, read
[container packaging and writable storage](references/container-packaging.md).
For conversation/session restoration, read
[application state adapters](references/application-state-adapters.md) when assessing
snapshot compatibility, adding persistence hooks, or verifying continuation.

For PostgreSQL/pgvector dependencies, database injections, or database restore,
read [managed PostgreSQL](references/postgresql.md). It covers populated seeds,
driver-specific TLS, committed-state checks, and the wrapper-managed engine.
For approved external HTTPS services such as tracing or guardrails, read
[HTTPS forwarding](references/https-egress.md) for Blueprint declarations, host
bindings, credentials, and diagnostics.

For native turn attribution or incomplete capture, read the environment guide's
[observation semantics](references/environment-operation.md#interpret-native-observations)
and [storage failure handling](references/environment-operation.md#required-evidence-storage-failures)
as relevant. Campaign response belongs to Operator management; target storage
repair and session replacement belong here.

For a combined request, move between guides as the work reaches that phase.
Do not load the blueprint assessment and authoring references for an installation,
status lookup, or evidence export. Start troubleshooting in the guide for the
failing operation; do not reassess the application unless the failure calls for it.

## Establish context once

Inspect existing artifacts before replacing them. Determine the selected
Interceptor version, host OS/architecture, Blueprint path, and data root only as
needed. Identify the current session/campaign for runtime operations. Reuse
configuration and authorization already established in the conversation.

Use [the public repository](https://github.com/intrusiveai/interceptor_sandbox)
and documentation matching the selected release. The guides link to `main` for
discovery; resolve version-specific behavior to a release tag or commit. A local
checkout is valid evidence, but generated instructions must not require a
developer-specific source path. Check `interceptor version` and `interceptor help`
rather than assuming a checkout's existing binary matches its source.

The configuration guides were reconciled with
[source revision 9a90a892](https://github.com/intrusiveai/interceptor_sandbox/tree/9a90a8922245c4ab2c36aadd17d9b83d460378fa).
Feature-specific references retain their implementation/qualification provenance;
that is separate from product versions and the OpenAPI identity approved by Operator.
Confirm the selected executable contains the required functionality; a rolling
candidate version alone is not evidence that the change is included.
Prefer matching implementation and executable tests when prose conflicts, and
state the discrepancy. Do not silently combine incompatible versions.

## Shared boundaries

- Keep real provider credentials and host authentication outside Blueprints and
  containers. Environment data and application-facing credentials are synthetic.
- Declared HTTPS seams contact configured external services through the host;
  those services and their side effects are real and are not restored with a snapshot.
- Preserve the application's normal invocation and model protocol. Report
  unsupported dependencies instead of inventing fidelity or weakening containment.
- Current integration uses one foreground Interceptor process and its fixed
  same-host API at `127.0.0.1:8080`. Do not add a gateway, integration token, remote
  listener, or restart/resume service.
- An Interceptor Blueprint defines the application and simulated world.
  Operator's environment directory and public capability export are separate
  campaign inputs. Use Operator management for adaptive campaigns, scenario
  generation for bundles, and results reporting for report authoring.
- Carry out the requested workflow and its necessary verification within existing
  authorization. Ask only for missing decisions or permissions that actually block
  the next action; do not add approval stages for each routine step.

Report the result, artifact/session locations, verification performed, and material
limitations. Distinguish validation, sealing, wrapper verification, and runtime
success; none proves the next level automatically.
