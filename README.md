# [CNAP.tech](https://cnap.tech) Helm Charts

## Charts

| Chart | Description | Use Case |
|-------|-------------|----------|
| [`app/`](app/) | Generic app deployment | Deploy any container image |
| [`httproute/`](httproute/) | HTTPRoute resource | Route traffic to services via Gateway API |
| [`gateways/cloudflare/`](gateways/cloudflare/) | Cloudflare Tunnel Gateway | Zero-trust access via Cloudflare |

## Generic App Chart

Location: [`app/`](app/)

Generic Helm chart for deploying any container image to Kubernetes.

### Quick Start

```bash
git clone https://github.com/cnap-tech/charts.git
cd charts

helm template myapp app \
  --set image.repository=myregistry/myapp \
  --set image.tag=1.0.0 \
  --set container.port=8080
```

### Features

- Any Docker container deployment
- Service types: ClusterIP, NodePort, LoadBalancer
- Gateway API (HTTPRoute) support
- Cloudflare Tunnels integration
- Configurable health checks
- HPA support
- Persistent storage
- Init containers & sidecars
- Security contexts

See [app/README.md](app/README.md) for full documentation.

## HTTPRoute Chart

Location: [`httproute/`](httproute/)

Creates an HTTPRoute resource for Kubernetes Gateway API. Used to route external traffic to services through a Gateway.

### Quick Start

```bash
helm template my-route httproute \
  --set parentRef.name=my-gateway \
  --set parentRef.namespace=gateway-system \
  --set hostnames[0]=myapp.example.com \
  --set backendRef.name=my-service \
  --set backendRef.port=8080
```

### Features

- Gateway API HTTPRoute resource
- Path, header, and query parameter matching
- Traffic splitting (canary deployments)
- Request/response filters
- Multiple backend support

See [httproute/README.md](httproute/README.md) for full documentation.

## Cloudflare Gateway Chart

Location: [`gateways/cloudflare/`](gateways/cloudflare/)

Deploys a Cloudflare Tunnel Gateway for zero-trust access without public IPs.

### Quick Start

```bash
helm install cloudflare-gateway gateways/cloudflare \
  --set cloudflare.accountId=your-account-id \
  --set cloudflare.apiToken=your-api-token
```

### Features

- Zero-trust access via Cloudflare Tunnels
- No public IPs required
- Automatic DNS management
- DDoS protection at Cloudflare edge
- Supports [lwijnsma fork](https://github.com/lwijnsma/cloudflare-kubernetes-gateway) with improvements

See [gateways/cloudflare/README.md](gateways/cloudflare/README.md) for full documentation.

## More Gateway Charts (Coming Soon)

- NGINX Gateway Fabric
- Traefik
- Envoy Gateway
