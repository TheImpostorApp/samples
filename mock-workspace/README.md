# Impostor — Mock API Samples

A ready-to-open Impostor **workspace** demonstrating every protocol and feature
against the local mock API stack: HTTP basics, auth (API key / Bearer / Basic /
OAuth2), folder inheritance, TLS / mTLS, WebSocket, gRPC, raw / form / multipart
request bodies, and pre/post-request scripting (`im.*`).

This folder is a self-contained, **relocatable** workspace — clone it anywhere and
open it in Impostor (File → Open folder). It contains no machine-specific paths.

## Prerequisites

The requests target the mock backend (`http://localhost:8080`, `https://localhost:8443`,
etc.). Start it first — see the [`mock/`](../../mock/README.md) stack:

```sh
cd mock && docker compose up -d
```

Then in Impostor: **Open folder** → select this `mock-workspace` directory, pick the
**Local** environment, and send any request.

## Scripting (pre/post-request `im.*`)

The **`Scripting/`** folder shows Impostor's scripting. Scripts use the Impostor-native
`im.*` API; the Postman-style `pm.*` is also available as an alias for compatibility. Open
a request and look at its **Pre-request** / **Post-request** script tabs; the Tests tab shows
`im.test(...)` results after sending.

- **Pre-request — set variables** — a pre-request script computes a timestamp + nonce and
  `im.variables.set(...)`s them, so the request templates them in via `{{ts}}` / `{{nonce}}`.
- **Post-request — tests** — `im.test(...)` + `im.expect(...)` assertions on status, timing,
  JSON body, and response headers.
- **Chain 1 — capture a value** → **Chain 2 — reuse the captured value** — Chain 1 extracts a
  value from the response and `im.environment.set("requestId", …)`; Chain 2 reads it back as
  `{{requestId}}` (run them in order). Chain 2's pre-request script fails fast if it's run
  first.

## How file paths stay relocatable

Requests that reference on-disk files (TLS certs, the multipart upload payload) use the
built-in **`{{workspaceDir}}`** variable — the absolute path of the opened workspace —
so they resolve correctly wherever the folder is cloned:

- `TLS/*` → `{{workspaceDir}}/.assets/certs/{ca.pem,client.p12}`
- `HTTP Basics/POST multipart` → `{{workspaceDir}}/.assets/sample.txt`

`{{workspaceDir}}` is injected automatically; you don't define it in any environment.

## Bundled demo certs

`.assets/certs/` holds **throwaway** localhost certs used by the TLS examples:
`ca.pem` (the mock CA to trust) and `client.p12` (the mTLS client identity,
password **`impostor`**). They are demo-only — never reuse them.

These certs must match the CA the mock stack serves. That CA is **committed and
stable**: the mock's `certinit` reuses the committed `mock/certs/{ca.pem,server.pem,
server.key}` instead of regenerating, and the `ca.pem`/`client.p12` here are the
matching client side — so the mTLS example works out of the box, no sync needed.

> **Divergence note (standalone repo):** when this bundle lives in its own public
> repo, it carries its own copy of `ca.pem`/`client.p12`, decoupled from the mock
> repo's `mock/certs/`. They stay valid as long as neither side re-rolls the CA. If
> you ever re-roll (`sh certs/gen-certs.sh --force` in the mock repo), the two repos
> diverge — copy the new `ca.pem` + `client.p12` into this bundle's `.assets/certs/`
> and commit. Symptom of a mismatch: the mTLS example fails with a TLS/verify error.
