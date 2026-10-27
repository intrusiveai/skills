---
name: interceptor-sandbox-management
description: Install, configure, and operate Interceptor Sandbox, including generation and remote embeddings access; assess target applications and create or revise Environment Blueprints; validate and build environments, including separately supplied Python/Node invocation adapters; manage sessions, snapshots, and target evidence. Use for Interceptor targets and their Operator integration. Scenario bundle authoring, Operator campaign execution, and results report generation have separate skills.
---

# Interceptor Sandbox Management

Deliver the requested Interceptor installation, application environment, or session
operation, with evidence of what works and explicit remaining gaps.

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

The baseline guides were reconciled with
[source revision b93fd775](https://github.com/intrusiveai/interceptor_sandbox/tree/b93fd77545223909ff331c74516473e2986a0c0b).
The adapter guidance was checked against
[source revision 979458c](https://github.com/intrusiveai/interceptor_sandbox/tree/979458c256455b3ecae071570e9e0c4a18fae784).
The embeddings guidance is pinned to its verified implementation in
[remote embeddings](references/remote-embeddings.md#check-the-selected-executable).
Confirm the selected executable contains the required functionality; a rolling
candidate version alone is not evidence that the change is included.
Prefer matching implementation and executable tests when prose conflicts, and
state the discrepancy. Do not silently combine incompatible versions.

## Shared boundaries

- Keep real provider credentials and host authentication outside Blueprints and
  containers. Environment data and application-facing credentials are synthetic.
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
