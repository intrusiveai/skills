---
name: scenario-bundle-generation
description: Create or revise Operator Sandbox scenario bundles from user-directed objectives, scenarios, and public target capabilities. Structure records, bind capability references, package supporting artifacts, and validate offline. Use for campaign input authoring; this skill does not prescribe test objectives, scenario catalogs, or attack techniques, and does not run campaigns.
---

# Scenario Bundle Generation

Produce an Operator-compatible bundle expressing the user's chosen objectives and
scenarios, with any supporting artifacts and an honest validation result.

## Content belongs to the user

This skill governs structure and functional compatibility, not the testing agenda.
Derive content from the user's request, existing bundle, and supplied material.
When the user requests new content, develop it within their stated goals and
context; this skill supplies no preferred topics or techniques.
Do not add objectives or scenarios because a capability exists, an example includes
them, or a testing taxonomy recommends them. Do not introduce technique catalogs,
payload recipes, technique-specific advice, or mandatory coverage categories.

Preserve user-supplied subject matter and technical detail while expressing it in
the supported format. Do not remove it merely because this skill contains no
technique guidance. If the desired content is missing or a consequential choice
cannot be inferred, ask for that input while completing independent structural work.

## Load guidance as needed

| Task | Read |
| --- | --- |
| Turn supplied goals/scenarios into records; revise descriptions, links, or coverage | [Objective and scenario authoring](references/objective-and-scenario-authoring.md) |
| Bind a target export; check references, delivery contracts, feedback, or matching mode | [Capability and evidence mapping](references/capability-and-evidence-mapping.md) |
| Package files; check integrity and bounds; validate and hand off | [Artifact packaging and validation](references/artifact-packaging-and-validation.md) |

A complete bundle needs the applicable checks from all three guides. For a narrow
edit, load only the affected guidance and validate the changed bundle; do not
revisit its testing agenda. Do not load unrelated sandbox installation procedures.

## Establish the contract and inputs

Identify the selected Operator contract, supplied public capability export and
its source companion, user-directed content, and requested output location.
Inspect an existing bundle and preserve its intended scope and identifiers.
Missing target facts or a capability digest must remain unresolved, not fabricated.

Use the [public Operator repository](https://github.com/intrusiveai/operator_sandbox),
[ScenarioBundle contract](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/SCENARIO_BUNDLE_CONTRACT.md),
and [closed schema](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/scenario-bundle.schema.json)
matching the installed version. Guides use `main` as a discovery link and were
checked against [revision fabce279](https://github.com/intrusiveai/operator_sandbox/tree/fabce2791b03d6ce7f8b54ad02923541d152f385).
Local source is valid evidence; generated instructions must not depend on a
developer-specific filesystem path.

## Deliver and preserve boundaries

Deliver `scenario-bundle.json`, a supporting-file directory only when needed, and
validation results identifying unresolved inputs and optional gaps. Use the user's
requested paths. Keep validation notes separate from the closed JSON contract.

Objectives-only and scenario-guided bundles are both supported. Do not manufacture
scenarios for an objectives-only request. Attack Harness chooses concrete experiments
within the admitted configuration; descriptive guidance does not grant permissions.

Use existing Operator export/submission tooling. Do not add a generator registry,
signature scheme, custom validator, or service. Capability export and installation
work belong to Operator management; target Blueprint work belongs to Interceptor
management. Offline validation is part of this authoring workflow, but preparing or
starting a campaign and generating results reports are separate requested work.

State whether the output is a draft, structurally checked, or validated offline.
None of those statuses establishes live readiness, execution, or objective achievement.
