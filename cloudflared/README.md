# Cloudflared Layout

Keep non-secret tunnel configs in git, and keep secrets on each machine.

## In Repo (safe)

- `cloudflared/configs/*.yml` (per-project tunnel configs)

## On Machine (do not commit)

- `~/.cloudflared/cert.pem` (account login cert)
- `~/.cloudflared/<tunnel-id>.json` (tunnel credentials)

## Quick Start

```bash
cfd-init <tunnel-name> <hostname> [service-url]
```

Example:

```bash
cfd-init my-tunnel api.example.com http://localhost:8080
```

Then:

```bash
CLOUDFLARED_CONFIG=./cloudflared/configs/my-tunnel.yml ./run cloudflared
```
