# OpenClaw Helm Chart

Deploy [OpenClaw](https://cnap.tech/selfhost/openclaw) AI agents on Kubernetes with production-ready defaults.

## What this chart handles

Things you'd otherwise have to figure out manually:

- **Bind address** — `--bind lan` so the pod is reachable via Service (OpenClaw defaults to loopback)
- **Reverse proxy trust** — `trustedProxies` pre-configured for all RFC1918 ranges so Cloudflare Tunnels, nginx, etc. work out of the box
- **Device auth bypass** — `controlUi.dangerouslyDisableDeviceAuth` enabled so browser connections through a reverse proxy don't require interactive pairing
- **Gateway token** — auto-generated 64-char secret, injected via `OPENCLAW_GATEWAY_TOKEN`
- **Bonjour disabled** — multicast doesn't work in Kubernetes
- **Persistent storage** — PVC mounted at `/home/node/.openclaw` with proper subPaths for state and workspace
- **Config management** — `openclaw.json` rendered from values, synced to PVC via init container with sha256-based idempotency
- **Security** — non-root (UID 1000), dropped capabilities, seccomp, no privilege escalation

## Quick start

```bash
helm install my-agent cnap-tech/openclaw \
  --set auth.providers={anthropic} \
  --set secrets.data.anthropicApiKey=sk-ant-xxx
```

## Values

### Gateway

| Key | Default | Description |
|-----|---------|-------------|
| `gateway.bind` | `lan` | Bind mode (`lan` or `loopback`) |
| `gateway.port` | `18789` | Gateway HTTP/WS port |
| `gateway.allowUnconfigured` | `true` | Allow startup without complete config |

### Auth providers

| Key | Default | Description |
|-----|---------|-------------|
| `auth.providers` | `[]` | List of providers: `anthropic`, `openai`, `openrouter`, `gemini` |

Each provider injects the corresponding API key env var from the Secret and creates an auth profile in `openclaw.json`.

### Secrets

| Key | Default | Description |
|-----|---------|-------------|
| `secrets.create` | `true` | Create Secret from values |
| `secrets.existingSecret` | `''` | Use an existing Secret instead |
| `secrets.data.gatewayToken` | `''` | Gateway token (auto-generated if empty) |
| `secrets.data.anthropicApiKey` | `''` | Anthropic API key |
| `secrets.data.openaiApiKey` | `''` | OpenAI API key |

### Config

| Key | Default | Description |
|-----|---------|-------------|
| `config.create` | `true` | Create ConfigMap from `config.data` |
| `config.existingConfigMap` | `''` | Use an existing ConfigMap instead |
| `config.data` | See `values.yaml` | OpenClaw configuration (rendered to `openclaw.json`) |

### Persistence

| Key | Default | Description |
|-----|---------|-------------|
| `persistence.enabled` | `true` | Enable PVC for state persistence |
| `persistence.size` | `10Gi` | Storage size |
| `persistence.storageClass` | `''` | Storage class (empty = cluster default) |

### Service

| Key | Default | Description |
|-----|---------|-------------|
| `service.type` | `ClusterIP` | Service type |
| `service.port` | `18789` | Service port |

See `values.yaml` for the full list of configurable values.
