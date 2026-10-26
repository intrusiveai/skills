# Objective and scenario authoring

Express the user's selected content clearly enough for Attack Harness to interpret
it and for Operator to validate its structure. Do not decide which tests the user
should run or supply technique-specific guidance.

## Preserve the requested content

Inspect the user's goals, existing records, and supplied context before writing.
Retain distinctions, priorities, and required/optional choices that affect meaning.
Rephrase or develop requested content without expanding the testing agenda.
If the user's goals or a supplied scenario's intended meaning cannot be established
from the available context, identify that missing information. A target export
alone is not a source of objectives.

For objectives-only work, use `scenarios: []`. For scenario-guided work, include
the scenarios specified or requested within the user's scope. Neither format is
inherently preferable. Upstream example files illustrate serialization, not a
recommended test catalog; do not inherit their subject matter.

## Assemble the bundle envelope

The current contract requires all of these top-level fields, including arrays
that may be empty:

| Field | Structural purpose |
| --- | --- |
| `schema_version` | Exact supported ScenarioBundle version |
| `bundle_id` | Descriptive input identifier, not a campaign ID |
| `producer` | Required descriptive `kind`; optional `name` and `version` |
| `target_requirements` | Exported target identity and source digest, with optional explicit requirements/exact projection pin |
| `objectives` | At least one objective record |
| `scenarios` | Scenario records or an empty array |
| `feedback` | Requested feedback profile |
| `evidence` | Requested evidence-class references and limitations |
| `artifacts` | Supporting-file descriptors or an empty array |
| `coverage` | Every objective ID exactly once and completion guidance |

Optional `context` holds supplied factual background. Optional `metadata` uses
bounded namespace/key/value entries, not arbitrary fields. `requested_limits`
expresses user constraints using the supported fields; omission uses installed
defaults. Do not choose campaign budgets as a side effect of authoring.

Use the matching
[bundle contract](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/SCENARIO_BUNDLE_CONTRACT.md)
for exact field types. Unknown fields are rejected. Producer labels describe
provenance and confer no registration, trust, or execution permission.

## Structure objective records

Each objective requires `objective_id`, `description`, and `required`.

- Give the record a stable unique ID, preserving existing IDs on ordinary edits.
- Describe the supplied question or intended outcome with enough context to
  distinguish it from the other supplied objectives.
- Interpret `required` as an obligation to address or explicitly account for
  the objective. It does not require success or override stopping conditions.
- Optional `success_criteria` states the user's evidence expectations. These are
  hypotheses or explanatory criteria, not executable predicates or proven results.
- Optional `required_capability_refs` names actual dependencies, and
  `artifact_refs` links relevant inventoried supporting material.
- Optional `priority` is 1–100, with 1 highest. Omit it if no ranking is needed.

Do not infer importance from a technique, threat category, or feature inventory.
Clarify a materially ambiguous required/optional choice without holding up
independent drafting.

## Structure scenario records

Every scenario requires the following fields:

| Field | What to express from the supplied scenario |
| --- | --- |
| `scenario_id` | Stable unique identity |
| `objective_refs` | One or more existing objectives this scenario addresses |
| `hypothesis` | The proposed relationship or outcome to investigate, stated as unproven |
| `priority`, `required` | Intended order and obligation to account for the scenario |
| `required_capability_refs` | Explicit functional dependencies; an empty list is allowed |
| `guidance.surfaces` | Supplied descriptions of relevant interaction/content boundaries |
| `guidance.action_refs` | Optional suggestions using actual public action references |
| `guidance.mutation_dimensions` | Supplied dimensions of variation, if any |
| `guidance.composition` | Supplied relationships between parts of the scenario, if any |
| `expected_observations` | What the user expects might be observable |
| `evidence_criteria` | How available observations would bear on the hypothesis, including uncertainty |
| `coverage_obligations` | What the scenario should account for or mark untested |
| `stopping_guidance` | When further work on this scenario should end or be reported incomplete |

The `guidance` object and all four of its arrays must be present. Arrays that
permit zero entries may remain empty; do not invent variations, combinations,
actions, or observations to fill them. Explain how to make supplied content
interpretable without adding technique advice. The schema permits empty
`stopping_guidance`; useful stopping detail should come from the requested scope.

Scenario priorities are required. Preserve the supplied ordering; where no ordering
is intended, equal priorities are valid. Disclose any formatting convention used.
Optional `artifact_refs` and `metadata` follow their published schemas.

A required scenario must be accounted for, not executed as a fixed payload sequence.
Required fields do not make every descriptive suggestion a mandatory capability.
Do not translate prose into hidden executable selectors or permissions.

## Account for coverage and revise coherently

List every objective exactly once in `coverage.objective_refs`, whether or not a
scenario references it. Do not add a placeholder scenario merely to link an objective.
Use `completion_guidance` to express how outcomes, evidence gaps, and untested work
should be accounted for within the user's requested scope.

When renaming/removing a record, update all internal references and coverage.
When substantive requirements are unavailable, retain the issue for resolution
rather than silently deleting, weakening, or replacing the requested test.
Capability feasibility and field completeness do not establish that a hypothesis
is sound, will succeed, or has been tested.
