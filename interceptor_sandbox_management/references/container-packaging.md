# Container packaging and writable storage

Use this guide when onboarding source without a suitable container image, mapping
application writes, or diagnosing read-only filesystem and permission failures.
Use Interceptor's existing image build, Blueprint launch settings, mutable roots,
and filesystem seeds. These capabilities support normal evidence and cache writes;
no new storage service, symlink mapping, or disposable-volume mechanism is needed.
Retaining caches with the session is acceptable.

## Package a runnable target image

When containerization is part of the requested onboarding, reuse the application's
build process and Dockerfile if suitable. If none exists, create a small Dockerfile
and `.dockerignore` from the inspected source and dependency lockfile rather than
stopping at the missing image. Package the application for native Linux with the
same architecture as the Docker runtime; do not silently rely on emulation.

- Pin build inputs and use the project's locked dependency installation. Record
  the source revision, build command, and inspected image digest. A mutable tag or
  source commit alone is not the resulting image identity.
- Install the runtime, application, dependencies, and required offline resources
  during image preparation. Runtime launch must not perform package installation,
  dependency synchronization, or model/tokenizer downloads. A writable cache does
  not provide internet access.
- Keep application code, virtual environments, dependencies, and immutable model
  or tokenizer data readable/executable by Interceptor's application identity.
  Avoid root-private installation paths. Inspect permissions rather than assuming
  the image's default user will be the application user.
- Exclude real `.env` files, credentials, host caches, local evidence, and unrelated
  checkout content from the build context. Supply synthetic runtime configuration
  through the Blueprint and retain real provider credentials on the host.
- Keep invocation adapters as separately supplied Blueprint assets when needed;
  `app build` installs them. Do not add the Interceptor supervisor or `sandboxd`
  startup to the application's Dockerfile.

Image construction and wrapper construction are separate steps. Inspect the built
image and reference its exact digest in the Blueprint before sealing and running
`interceptor app build`. See [Blueprint creation](blueprint-creation.md).

For [managed PostgreSQL](postgresql.md), install only the application's normal
driver dependencies in the target image. `app build` packages PostgreSQL/pgvector
and their runtime libraries and notices. Declare schema/populated seed SQL in the
Blueprint; do not bundle a running database, mount its data as an application
mutable root, or copy a host database into the image.

## Declare launch behavior explicitly

Interceptor launches the application from `application.launch.command`, `workdir`,
and `environment` plus the selected invocation interface. The image's `ENTRYPOINT`,
`CMD`, `USER`, and undeclared Dockerfile `ENV` do not supply that launch contract.
Trace any entrypoint setup the application actually needs and provide it through
image preparation or the explicit launch configuration; do not assume it ran.

Use the installed interpreter or executable directly. Set required PATH, HOME,
library-specific cache variables, and other runtime configuration explicitly when
the application needs them. A variable such as `XDG_CACHE_HOME` is not a universal
redirect: inspect each dependency's supported configuration and actual writes.
For Python, `PYTHONDONTWRITEBYTECODE: '1'` can avoid runtime `__pycache__` writes;
it does not control other library files or caches.

## Provide writable paths with mutable roots

The container root filesystem is read-only. Declare narrow, absolute,
non-overlapping directories in `application.persistence.mutable_roots` for writes.
Interceptor creates separate storage under its session data and mounts it at each
exact container path. No image symlink is necessary. Dockerfile permissions alone
cannot make a directory writable on the read-only root filesystem.

For an application that expects `/app/evidence` and `/app/.cache`, this persistence
fragment preserves those paths:

```yaml
application:
  persistence:
    mutable_roots: [/app/evidence, /app/.cache]
    snapshot_capable: false
    quiesce: {kind: none}
```

Mutable roots work even when snapshots are disabled. They are managed session
state, not automatically discarded scratch volumes. Enabling snapshots requires
an actual state/flush assessment. A [state adapter](application-state-adapters.md)
can serialize conversation/session data into a managed file, using a dedicated
checkpoint path outside the application workdir, seeded targets, and injection
namespaces. Filesystem mounts do not capture process memory or unsupported
external database state. Use the existing stop/export/purge
lifecycle; do not add automatic cache deletion as an onboarding prerequisite.

When the application already offers configurable paths, a dedicated data root is
also convenient. This partial example uses the support agent's existing setting;
merge it with the real launch command, interface, and other required fields:

```yaml
application:
  launch:
    environment:
      SUPPORT_EVIDENCE_PATH: /state/support/evidence
      PYTHONDONTWRITEBYTECODE: '1'
  persistence:
    mutable_roots: [/state/support]
    snapshot_capable: false
    quiesce: {kind: none}
```

Distinguish write permission from ownership. Interceptor runs the application as
UID 20000 with its configured application group (currently the host user's GID),
not the image's Dockerfile user. Mutable mounts are provisioned by Interceptor;
image-side `chown` does not determine the owner of a replacement mount. If an
application creates a directory and calls `chmod(0700)`, prefer an unseeded child
such as `/state/support/evidence` under the writable parent `/state/support`.
The application can create and own that child; it may not be allowed to chmod the
mount root itself. Seeded files/directories may also be writable without being
application-owned. Test the operations the target actually performs.

If the target has a fixed path requiring ownership changes, inspect its existing
configuration or startup options before claiming a mount alone solves it. Do not
respond by running the application as root or making the entire image writable.

## Preserve required initial contents

A mutable mount hides image files already at that path. Interceptor does not
automatically copy those files into the new storage. Avoid mounting over `/app`,
an interpreter, virtual environment, installed adapter, or Certifi bundle just
to permit one cache directory to change.

If writable storage needs known initial contents, use existing sealed
`filesystem.seed` assets with `read_only: false`; the target must lie inside a
declared mutable root. For example, alongside `/app/.cache` above:

```yaml
filesystem:
  seed:
    - source: assets/cache-seed
      target: /app/.cache
      read_only: false
```

The seed directory must actually exist inside the Blueprint and contain the
reviewed initial files. Do not assume pointing at an image path extracts its
contents. Prefer leaving immutable resources in the image outside writable mounts
and configuring separate write locations where the dependency supports it.
Use a read-only seed only for content the application will not modify.

Interceptor already supplies `/tmp` for disposable scratch space (currently a
64 MiB, non-executable tmpfs). Do not place required retained evidence there or
assume large caches and extracted executables will work there. Ordinary cache
writes can use declared mutable roots and remain with the session.

## Verify through Interceptor

Follow [environment operation](environment-operation.md) to validate, seal, build,
verify, and start the target. A successful Docker build or ordinary `docker run`
is not proof of compatibility with Interceptor's read-only filesystem, explicit
launch environment, and application identity.

Exercise initialization and a representative application operation through the
normal local API or Operator. Check the writes actually needed by the target:
evidence creation, file permissions, flush/fsync, cache creation or reuse, and
subprocess behavior. Confirm required seed data is present after mounting and
that code/dependencies remain available without downloads. Confirm writes outside
the allowed roots remain blocked. Do not invent cache directories for libraries
that do not write them.

Inspect application diagnostics and Interceptor evidence. Application-generated
evidence files are distinct from Interceptor's own event journals; do not assume
writing files automatically records their contents as observations or exports.
Writable agent logs are needed only if the application itself requires them;
they are not prerequisites for Interceptor collection. Do not add an agent logging
subsystem or private-ID correlation as an onboarding requirement.
Report how any explicitly required application artifacts can be inspected or collected,
including permission limitations. If claiming snapshot support, test restore with
the target's real state instead of inferring it from successful writes.

Keep new evidence outputs separate from source and Blueprint assets. Diagnose
read-only failures by the actual path/mount, permission failures by the actual
UID/GID and operation, and missing files by mount masking or incomplete packaging.
Fix the image/configuration and rebuild; do not patch a running sandbox or weaken
containment. Report exercised paths and remaining dependency gaps, including
unsupported database types or driver features, without treating containerization
alone as a database integration. Use the managed PostgreSQL guide for its supported
path and native database verification.
