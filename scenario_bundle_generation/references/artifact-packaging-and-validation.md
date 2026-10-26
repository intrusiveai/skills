# Artifact packaging and validation

Deliver exact bundle bytes and supporting files that the matching Operator can
validate offline. Reuse its installed contract and validator; do not introduce a
parallel schema implementation or infer execution from a validation receipt.

## Package supporting material only when needed

Use only supplied or requested supporting material relevant to the selected
content. With no supporting files, write `artifacts: []` and omit the artifact
directory. Citations and metadata do not cause Operator to download anything.

For each file:

1. Finalize its permitted bytes and media type before hashing.
2. Compute raw SHA-256 and exact byte length. Store a regular copy directly in the
   artifact directory as `sha256-<64-lowercase-hex>`, without an extension.
3. Add its descriptor with `artifact_id`, `digest` (`sha256:<hex>`),
   `size_bytes`, `media_type`, `purpose`, `visibility: operator-engine`,
   and `required`.
4. Add `artifact_refs` only to records that use it. All references must resolve.
   A reference essential to understanding a required item must itself be required.
5. If `schema_id` is supplied, use an actual schema from the installed offline
   catalog. Otherwise preserve the bytes without inventing a schema identity.

The directory must contain exactly the supplied inventory, with no extra notes,
links, subdirectories, special files, or cross-device entries. Duplicate artifact
IDs are invalid. Different IDs may reuse one file only when their size, media,
visibility, and schema claims agree.

An optional absent artifact needs an explicit `omission_reason` and its known
descriptor. Do not invent its digest/size or create an empty substitute. A required
artifact cannot carry an omission reason; a required objective/scenario cannot
reference an omitted artifact. Do not mark essential material optional to pass
validation.

Bundle and artifact contents are harness-visible. Keep real credentials, private
configuration, protected fixtures, and native provenance companions out of them.
If content must change, recompute its identity and dependent descriptors; never
silently redact bytes while retaining their old digest. Supporting references
cannot install skills, add tools, or override the system prompt.

## Check structure, semantics, and bounds

Use strict UTF-8 JSON. Reject duplicate keys, unknown fields, trailing values,
non-finite numbers, and unsupported versions. Check IDs and references, every
required field, exact objective coverage, and descriptor consistency.

For the reviewed contract, important ceilings are:

- 4 MiB encoded bundle; nesting depth at most 32;
- 100 objectives, 256 scenarios, 4,000 artifact descriptors;
- local IDs at most 128 ASCII characters, starting with an alphanumeric and using
  letters/digits or `._:-`; public references at most 256 characters;
- narrative strings at most 4,096 UTF-8 bytes, with top-level context at most
  16 KiB; count bytes, not just Unicode characters;
- ordinary supporting files at most 1 MiB each, within the shared 4,096-file /
  64 MiB input budget, including other launch inputs.

Consult the selected
[bundle contract](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/SCENARIO_BUNDLE_CONTRACT.md)
and [schema](https://github.com/intrusiveai/operator_sandbox/blob/main/schemas/scenario-bundle.schema.json)
for exact per-field array and value limits. Do not truncate user content or
silently split objectives/scenarios to fit limits; explain the conflict and
resolve the affected content with the user.

Priorities are 1–100. Supplied requested-limit values are positive integers within
the contract bounds; omission uses installed defaults. In particular, zero is
not a valid bundle snapshot request, even though host configuration can disable
snapshots with zero. Do not add a self-digest or signature field to the bundle.

## Validate with Operator's existing workflow

Use an already selected private configuration and verified installed contract.
Read [offline submission](https://github.com/intrusiveai/operator_sandbox/blob/main/docs/SUBMISSION.md)
for the version-matched command contract. An offline validation submission is a
useful authoring check; it does not prepare or launch execution.

With the public export and its companion together, choose a new validation output
whose parent exists:

```sh
mkdir -p ./validation
operatorctl submit --config /absolute/private/config.yaml \
  --bundle ./scenario-bundle.json --capabilities ./capabilities.json \
  --output ./validation/bundle-check
operatorctl validate --config /absolute/private/config.yaml \
  --run ./validation/bundle-check
```

Add `--artifacts ./bundle-artifacts` to `submit` when files are supplied.
If the user already selected an Operator environment directory, replace
`--capabilities` with `--environment DIR`; do not combine those selectors.
An explicit `--target-profile FILE` can accompany `--capabilities`. Do not
copy the private profile into the supporting-file inventory.

Submission verifies the package, bundle semantics, authoring export/companion,
and exact supporting bytes. Success reports `validated-offline`, including
optional gaps. The subsequent `validate` rechecks retained copies rather than
trusting a status label. These commands do not contact Docker, the target, model
providers, or secret stores and do not allocate execution authority.

Use a new output for each changed bundle. Submitted files are immutable; do not
edit them or overwrite an incomplete submission. A reused `bundle_id` does not
overwrite old content. A raw file digest and a canonical object digest are different
identities; use Operator's emitted provenance rather than adding either as a
self-field.

Read optional gaps as well as exit status. Fix structural errors without changing
the user's objective, making a required item optional, guessing a capability,
or lowering its evidence criteria. If an environment/profile selection is changed,
follow Operator's new-submission requirements.

If the CLI, exact package, export companion, or private configuration is unavailable,
complete the useful authoring work and record which checks could not run. A JSON
schema check alone is not verified capability binding, artifact integrity, live
policy approval, or campaign readiness. Do not bootstrap an entire installation
just to label a draft validated.

## Handoff

Deliver the bundle path, artifact directory if present, selected contract/target
provenance, validation status, and material unresolved inputs or optional gaps.
Keep notes beside the JSON and outside the artifact inventory. Do not claim that
any supplied scenario was exercised or any objective achieved.

Confirm that the validated retained bundle and supporting bytes match the delivered
files and preserve the user's selected records and their meaning. Validation proves
structure and packaging, not that the chosen testing agenda is sufficient.

Hand off execution to Operator management only when requested. Report generation
belongs to the results reporting skill.
