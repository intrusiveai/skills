---
name: operator-sandbox-management
description: Install and configure Operator Sandbox and its compatible Attack Harness; prepare target profiles, capability exports, and campaign inputs; start, inspect, and terminate campaigns; retain evidence for reporting. Use for Interceptor or configured HTTPS targets. Interceptor environment management, scenario bundle authoring, and results report generation have separate skills.
---

# Operator Sandbox Management

Deliver the requested Operator installation, validated campaign inputs, or campaign
operation, with evidence of the resulting state and explicit remaining gaps.

## Choose the relevant workflow

Read only the guide for the current task and its relevant upstream references.

| Request | Read |
| --- | --- |
| Install or upgrade; select Harness image; configure model access, authentication, host paths, or limits | [Setup and configuration](references/setup-and-configuration.md) |
| Select a target; export capabilities; assemble and validate inputs; save a prepared campaign | [Campaign preparation](references/campaign-preparation.md) |
| Run, inspect, wait, terminate, diagnose interruptions, or locate retained evidence | [Campaign operation](references/campaign-operation.md) |

For incomplete Interceptor evidence during a campaign, use
[campaign failure handling](references/campaign-operation.md#interceptor-evidence-storage-failures).
Use Interceptor management for target storage repair and fresh-session setup.

For a combined request, move between guides as the work reaches each phase.
An inspection or termination request does not require reloading installation,
target authoring, or scenario-generation instructions.

## Establish context once

Inspect existing artifacts and reuse configuration, destinations, and authorization
already established. Identify the selected executable, private configuration,
installed contract, target, and run directory only as needed.
`operatorctl version` exposes product/source and supported contract identities.
A raw development build is not evidence of a complete release installation.

Use the [public Operator repository](https://github.com/intrusiveai/operator_sandbox)
and [Attack Harness repository](https://github.com/intrusiveai/attack_harness).
The guides link to `main` for discovery; resolve exact commands and contracts to
the selected release or commit. Local checkouts are valid evidence, but generated
instructions must not depend on a particular developer's filesystem layout.

These guides were reconciled with
[Operator revision fabce279](https://github.com/intrusiveai/operator_sandbox/tree/fabce2791b03d6ce7f8b54ad02923541d152f385)
and [Harness revision e75a051c](https://github.com/intrusiveai/attack_harness/tree/e75a051c024a436646d5651265d9a983d37bbf81).
When prose conflicts with matching implementation and executable tests, follow
the latter and state the discrepancy. Do not mix incompatible package versions.

## Shared boundaries

- Attack Harness runs through Operator in its managed container. It has no
  standalone campaign service or user-facing CLI.
- Keep host credentials, provider endpoints, private target mappings, and Docker
  configuration outside harness-visible inputs. Capabilities describe available
  behavior; only host policy and limits authorize its use.
- Submission and offline preparation do not launch a campaign. Live start checks
  compatibility and current target state before execution.
- Use Interceptor management for target Blueprints and sessions, scenario bundle
  generation for objective/scenario authoring, and results reporting for analysis.
  These are task boundaries, not compulsory stages when usable artifacts exist.
- Carry out the requested workflow and necessary verification within existing
  authorization. Do not add approvals for routine steps or silently broaden the
  target, limits, credentials, or cleanup scope.
- Interrupted or claimed campaigns do not resume. Retain unknown effects and
  inspect their saved records before deciding on a separate new campaign.

Report the result, run/campaign identifiers, useful artifact locations, verification,
and material gaps. Separate input validity, execution, target outcomes, cleanup,
evidence completeness, and report availability.
