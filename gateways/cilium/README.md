# Cilium Gateway Chart

Deploys a Gateway resource that uses Cilium's built-in Gateway API controller.

## Prerequisites

Cilium must be installed with Gateway API support enabled:

```yaml
# In cilium-appset.yaml or Helm values
gatewayAPI:
  enabled: true
  hostNetwork:
    enabled: true # Bind directly to node IPs (no LoadBalancer needed)
envoy:
  enabled: true
  securityContext:
    capabilities:
      keepCapNetBindService: true # Allow binding to ports 80/443
```

Gateway API CRDs must be installed before Cilium:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
```

## How It Works

1. **Cilium provides the GatewayClass** - When installed with `gatewayAPI.enabled=true`, Cilium automatically creates a `cilium` GatewayClass
2. **This chart creates a Gateway** - References the `cilium` GatewayClass to expose HTTP/HTTPS listeners
3. **Host Network Mode** - With `hostNetwork.enabled=true`, traffic goes directly to node IPs on ports 80/443 (no LoadBalancer or MetalLB needed)

## Installation

```bash
helm install cilium-gateway ./gateways/cilium \
  --namespace gateway-system \
  --create-namespace
```

## Configuration

| Parameter                  | Description            | Default                |
| -------------------------- | ---------------------- | ---------------------- |
| `gateway.name`             | Gateway resource name  | `cilium-gateway`       |
| `gateway.namespace`        | Gateway namespace      | Release namespace      |
| `gateway.gatewayClassName` | GatewayClass to use    | `cilium`               |
| `gateway.listeners`        | Listener configuration | HTTP (80), HTTPS (443) |

## Usage

Once deployed, create HTTPRoute resources to route traffic:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app-route
spec:
  parentRefs:
    - name: cilium-gateway
      namespace: gateway-system
  hostnames:
    - 'app.example.com'
  rules:
    - backendRefs:
        - name: my-app
          port: 8080
```

## References

- [Cilium Gateway API Documentation](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
- [Host Network Mode](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/#host-network-mode)
- [Bind to Privileged Ports](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/#bind-to-privileged-port)




