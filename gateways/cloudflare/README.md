# Cloudflare Gateway Chart

Deploys a Cloudflare Tunnel Gateway for Kubernetes Gateway API.

This chart installs the [cloudflare-kubernetes-gateway](https://github.com/pl4nty/cloudflare-kubernetes-gateway) controller and creates a Gateway resource for routing traffic through Cloudflare Tunnels.

## Features

- **Zero-trust access**: Traffic goes through Cloudflare's edge, no public IPs needed
- **Automatic tunnels**: Controller manages Cloudflare Tunnels automatically
- **DDoS protection**: Cloudflare's edge provides built-in protection
- **SSL at edge**: Cloudflare handles TLS termination

## Prerequisites

- Kubernetes 1.24+
- Gateway API CRDs v1.0+
- Cloudflare account with:
  - Account ID
  - API token with "Account Cloudflare Tunnel Edit" and "Zone DNS Edit" permissions

### Install Gateway API CRDs

```bash
kubectl apply -k github.com/kubernetes-sigs/gateway-api//config/crd?ref=v1.0.0
```

## Installation

### Quick Start

```bash
helm install cloudflare-gateway . \
  --set cloudflare.accountId=your-account-id \
  --set cloudflare.apiToken=your-api-token
```

### With values file

```yaml
# values.yaml
cloudflare:
  accountId: 'your-account-id'
  apiToken: 'your-api-token'

gateway:
  name: my-gateway
  listeners:
    - name: http
      protocol: HTTP
      port: 80
```

```bash
helm install cloudflare-gateway . -f values.yaml
```

## Using the Fork with Improvements

The [lwijnsma/cloudflare-kubernetes-gateway](https://github.com/lwijnsma/cloudflare-kubernetes-gateway) fork includes improvements over the original. To use it:

```yaml
controller:
  image:
    repository: ghcr.io/lwijnsma/cloudflare-kubernetes-gateway
    tag: 'latest'  # Or specific version
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `cloudflare.accountId` | string | `""` | Cloudflare account ID |
| `cloudflare.apiToken` | string | `""` | Cloudflare API token |
| `cloudflare.existingSecret` | string | `""` | Use existing secret for credentials |
| `controller.enabled` | bool | `true` | Deploy the controller |
| `controller.image.repository` | string | `ghcr.io/pl4nty/cloudflare-kubernetes-gateway` | Controller image |
| `controller.image.tag` | string | `""` | Image tag (defaults to appVersion) |
| `controller.namespace` | string | `cloudflare-gateway` | Controller namespace |
| `controller.replicas` | int | `1` | Controller replicas |
| `controller.resources` | object | See values.yaml | Resource limits |
| `gatewayClass.name` | string | `cloudflare` | GatewayClass name |
| `gateway.enabled` | bool | `true` | Create Gateway resource |
| `gateway.name` | string | `cloudflare-gateway` | Gateway name |
| `gateway.namespace` | string | `""` | Gateway namespace (defaults to release namespace) |
| `gateway.listeners` | list | `[{name: http, protocol: HTTP, port: 80}]` | Gateway listeners |
| `gateway.infrastructure.disableDeployment` | bool | `false` | Disable per-gateway cloudflared |

## Creating HTTPRoutes

After installing, create HTTPRoutes to expose services:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app
spec:
  parentRefs:
    - name: cloudflare-gateway
      namespace: cloudflare-gateway  # Or your gateway namespace
  hostnames:
    - myapp.example.com
  rules:
    - backendRefs:
        - name: my-service
          port: 8080
```

Or use the CNAP `httproute` chart:

```bash
helm install my-route ../httproute \
  --set parentRef.name=cloudflare-gateway \
  --set parentRef.namespace=cloudflare-gateway \
  --set 'hostnames[0]=myapp.example.com' \
  --set backendRef.name=my-service \
  --set backendRef.port=8080
```

## DNS Configuration

The controller automatically creates DNS records in Cloudflare when HTTPRoutes are created. Ensure your API token has "Zone DNS Edit" permission for the zones you want to use.

## Troubleshooting

### Check controller logs

```bash
kubectl logs -n cloudflare-gateway deployment/cloudflare-gateway-controller
```

### Check Gateway status

```bash
kubectl get gateway -n cloudflare-gateway
kubectl describe gateway cloudflare-gateway -n cloudflare-gateway
```

### Check HTTPRoute status

```bash
kubectl get httproute
kubectl describe httproute my-app
```

## Integration with CNAP

When using this chart through CNAP:

1. Add this chart as a helm source to your product/template
2. Configure Cloudflare credentials via CNAP's secrets management
3. CNAP will discover the Gateway for use with the "Expose externally" feature

## References

- [pl4nty/cloudflare-kubernetes-gateway](https://github.com/pl4nty/cloudflare-kubernetes-gateway)
- [lwijnsma/cloudflare-kubernetes-gateway](https://github.com/lwijnsma/cloudflare-kubernetes-gateway) (fork with improvements)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)
- [Cloudflare Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)

