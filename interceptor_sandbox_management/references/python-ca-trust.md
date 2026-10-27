# Python HTTPS trust

Use this guide when a Python application needs simulated HTTPS origins or fails
certificate verification inside its wrapper. Keep the application's normal
client code and certificate verification enabled. For Certifi-backed clients,
configure the Blueprint and let `interceptor app build` install sandbox trust;
do not add a custom HTTP transport or SSL context to an invocation adapter solely
for that purpose.

## Assess the actual environments

Identify the Python interpreters used by the application and its subprocesses,
including virtual environments. Inspect which trust store each relevant client
uses. HTTPX normally uses Certifi; `trust_env=False` ignores CA environment
variables, so those variables alone cannot establish sandbox trust. Other
Certifi-backed clients can use the same installed bundle; an SDK name alone does
not prove that it uses that bundle.

Use absolute interpreter paths inside the target image, such as
`/app/.venv/bin/python`, not host Python paths, activation scripts, or environment
directory names. Each declared environment must already contain its interpreter
and Certifi in normal site-packages. Standard virtualenv interpreter and bundle
symlinks are supported. User-site packages, application-shadowed imports, and
temporary extracted bundles are unsupported. Interceptor does not scan every
Python installation or install missing dependencies.

## Declare and build

Extend the existing Blueprint's network configuration:

```yaml
network:
  dns:
    enabled: true
  tls:
    enabled: true
    trust_mode: auto
    python_environments:
      - /app/.venv/bin/python
      - /opt/worker-venv/bin/python
```

Declare the actual HTTPS hostnames and matching service fixtures separately.
Trust installation does not create destinations or permit internet access.
Use `network.tls.python_environments` only with TLS enabled and `trust_mode: auto`.
It applies to every supported invocation interface, including command and HTTP
applications; it is not limited to the Python code adapter. An omitted or empty
list retains existing behavior without requiring Python in the image.

Follow [environment operation](environment-operation.md#validate-seal-and-build)
to validate, seal, build, and verify. During wrapper construction, Interceptor
uses each declared interpreter to locate `certifi.where()`, appends the generated
public CA while retaining existing roots, and verifies the persistent bundle in
a fresh interpreter. Installation is offline and idempotent, including shared
bundles. All declared environments must succeed. Only the wrapper is modified;
the original target image and host Python installations are unchanged. No host
Python or Go installation is required for released wrapper builds.

Keep interpreters and bundles outside image volumes, mutable roots, and runtime
mounts that would hide or replace them. Known conflicts fail the build. The normal
application still runs unprivileged; build-time bundle writes do not grant it
extra privileges. Private TLS keys retain their existing protected host/runtime
handling and are not authored Blueprint assets.

Changes to declarations require review, resealing, and a matching wrapper
rebuild. After Python or dependency upgrades, rebuild the target image, update its
Blueprint image digest, reseal, and rebuild the wrapper. Do not install or upgrade
packages in a running sandbox or manually patch host trust stores as a workaround.

## Diagnose failures and limits

- Missing interpreter or Certifi: correct the declared image path or install the
  dependency in the target image, then rebuild. Do not substitute host Python.
- Invalid, unwritable, or temporary bundle: inspect the error's interpreter and
  bundle location; fix the image layout or permissions. Do not hide the failure
  by dropping an environment that the application actually uses.
- Mount conflict: place the environment in an immutable image directory outside
  the conflicting image volume, mutable root, or runtime mount.
- Build succeeds but HTTPS fails: confirm the application uses the declared
  interpreter and Certifi bundle, then check the declared hostname, DNS mapping,
  TLS port, fixture match, and certificate error. A successful build or startup
  does not prove the client's request path works.

Custom CA stores, privately vendored bundles, explicit client CA configuration,
and certificate pinning can bypass or reject the modified Certifi bundle. This
feature does not rewrite them or override pinning. Inspect the application's
existing configuration options: `bundle` exposes the public CA for applications
that already support consuming it; `application-managed` requires the existing
trust probe for a separately configured trust mechanism. Neither mode performs
this Python bundle injection. If the application cannot accept sandbox trust
through supported configuration, report the integration gap instead of disabling
verification or silently modifying application code.

Node retains its existing automatic `NODE_EXTRA_CA_CERTS` handling. This Python
feature needs no Node trust-store modification. Python's system-store clients
also retain the existing automatic system trust handling; do not describe Certifi
injection as a universal Python TLS override.

## Verify the application path

For a working-environment claim, invoke a representative application operation
through the normal local API or Operator, under its normal application identity.
Exercise each relevant declared environment and the sync/async client paths the
target actually uses. Keep certificate verification enabled; unchanged HTTPX
clients using `verify=True, trust_env=False` are a useful regression case.
Confirm the expected HTTPS fixture response and corresponding Interceptor service
evidence, plus continued rejection of undeclared destinations.

Include controlled certificate failure cases when verifying trust behavior:
untrusted issuer and hostname mismatch must fail certificate verification, not
merely fail DNS lookup or return an HTTP routing error. Retain existing roots and
confirm the original target image remains unchanged. Use dedicated test sessions
and clean up only resources created by the test.

The product's [Python HTTPS example](https://github.com/intrusiveai/interceptor_sandbox/tree/main/examples/python-ca)
provides two virtual environments, unchanged sync/async HTTPX clients, declared
fixtures, and the existing local API smoke client. For package qualification,
follow that example's complete arguments for `scripts/qualify_release.py` with
`--adapter-language python --python-ca`. It exercises an extracted native archive
outside the checkout with Go unavailable to the CLI, verifies roots, idempotence,
certificate rejection, application behavior, and evidence, then cleans up its
test resources. Building the developer qualification client is not a prerequisite
for ordinary released CLI users.

Report actual architectures and client environments exercised. Distinguish
locally built archives from CI-produced artifacts and unrun checks from successful
results; the example's success is not proof that another target uses the same
trust path. See the product's [Blueprint reference](https://github.com/intrusiveai/interceptor_sandbox/blob/main/docs/environment-blueprint.md#network)
for field semantics.
