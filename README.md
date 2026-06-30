# Impostor — Sample Workspaces

Ready-to-open example workspaces for [**Impostor**](https://impostor.uk/), a fast,
local, cross-platform API client (a lightweight, native alternative to Postman built on
Tauri v2 + SvelteKit, not Electron).

Clone this repo, open a workspace folder in Impostor (**File → Open folder**), and start
sending requests. The matching mock backend the requests target is bundled here too, in
[`mock-server/`](mock-server/) — so this repo is fully self-contained.

## `mock-workspace/`

A self-contained, **relocatable** workspace that demonstrates every protocol and feature
Impostor supports, all targeting the local mock API stack:

- **HTTP Basics** — GET/POST, JSON / form / multipart bodies, query + headers, cookies,
  gzip, redirects, delays, and non-2xx statuses.
- **Auth** — API key (header & query), Bearer, Basic, Digest, AWS SigV4, and OAuth2
  client credentials.
- **Inheritance Demo** — folder-level auth/headers/settings inherited (and overridden)
  by child requests.
- **TLS** — TLS and mutual-TLS (mTLS) using the bundled demo certs.
- **Realtime** — WebSocket, Server-Sent Events (SSE), and gRPC.
- **Scripting** — pre/post-request scripts via Impostor's native `im.*` API (with
  `pm.*` available as a Postman-compatible alias): setting variables, assertions
  (`im.test` / `im.expect`), and capturing a value in one request to reuse in another.

The folder contains no machine-specific paths — clone it anywhere and it just works.

### Prerequisites

The requests target the Impostor mock backend (`http://localhost:8080`,
`https://localhost:8443`, etc.), bundled in [`mock-server/`](mock-server/). Start it
before sending requests:

```sh
cd mock-server && docker compose up -d   # or: docker-compose up -d
docker compose ps                        # all services healthy?
```

Stop it with `docker compose down` (add `-v` to also drop the cert volume). See
[`mock-server/README.md`](mock-server/README.md) for the full endpoint → feature map.

### Usage

1. In Impostor, **Open folder** → select the `mock-workspace/` directory.
2. Pick the **Local** environment.
3. Send any request.

### How paths stay relocatable

Requests that reference on-disk files (TLS certs, the multipart upload payload) use the
built-in **`{{workspaceDir}}`** variable — the absolute path of the opened workspace — so
they resolve wherever the folder is cloned:

- `TLS/*` → `{{workspaceDir}}/.assets/certs/{ca.pem,client.p12}`
- `HTTP Basics → POST multipart` → `{{workspaceDir}}/.assets/sample.txt`

`{{workspaceDir}}` is injected automatically; you never define it in an environment.

### Bundled demo certs

`.assets/certs/` holds **throwaway** localhost certs for the TLS examples: `ca.pem` (the
mock CA to trust) and `client.p12` (the mTLS client identity, password **`impostor`**).
They are demo-only — never reuse them. These are the client side of the same committed
CA the bundled [`mock-server/`](mock-server/) stack serves, so the mTLS example works out
of the box. If the CA is ever re-rolled (`sh mock-server/certs/gen-certs.sh --force`),
copy the new `ca.pem`
+ `client.p12` into `.assets/certs/`; a mismatch shows up as a TLS/verify error on the
mTLS example.

## `mock-server/` — the mock API stack

A one-command Docker backend (`docker compose up -d`) that exercises every Impostor
feature the workspace touches: REST, the auth schemes, OAuth2/OIDC, mTLS, WebSocket, SSE,
and gRPC. Built from pinned upstream images plus a small nginx for the mTLS endpoint.

| URL | Service | What it's for |
|-----|---------|---------------|
| `http://localhost:8080` | go-httpbin | REST, auth (Basic/Bearer), WebSocket, SSE |
| `http://localhost:8081` | mock-oauth2-server | OAuth2 / OIDC flows |
| `localhost:9000` / `9001` | grpcbin | gRPC (plaintext / TLS), with reflection |
| `https://localhost:8443` | nginx (mTLS) | client-cert-required TLS → httpbin |
| `https://localhost:8444` | nginx (TLS only) | plain TLS w/ custom CA → httpbin |

Everything is throwaway and safe to run anywhere — no secrets or real data. See
[`mock-server/README.md`](mock-server/README.md) for the complete endpoint → feature map.

## Workspace layout

```
mock-server/                  # bundled Docker mock backend (docker compose up -d)
mock-workspace/               # the Impostor workspace — open this in the app
├── impostor.workspace.yaml   # workspace name + global variables
├── settings.yaml             # workspace-level headers/settings
├── .env/Local.env.yaml       # the "Local" environment (baseUrl, etc.)
├── .assets/                  # certs + sample upload payload
├── HTTP Basics/              # *.request.yaml files, one per request
├── Auth/
├── Inheritance Demo/
├── TLS/
├── Realtime/
└── Scripting/
```

Each `*.request.yaml` is a single request (method, URL, headers, body, auth, scripts).
Folders can carry their own `settings.yaml` for inherited auth/headers.
