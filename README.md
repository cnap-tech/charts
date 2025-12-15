# [CNAP.tech](https://cnap.tech) Helm Charts

This repository contains Helm charts published as a Helm repository via GitHub Pages.

## Helm Repository

Add this repository to Helm:

```bash
helm repo add cnap-tech https://cnap-tech.github.io/charts
helm repo update
```

Then install charts:

```bash
helm install myapp cnap-tech/app
helm install cloudflare-gateway cnap-tech/gateway-cloudflare
```

## Charts

| Chart | Description | Use Case |
|-------|-------------|----------|
| [`app/`](app/) | Generic app deployment | Deploy any container image with optional HTTPRoute |
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
- Gateway API (HTTPRoute) support with `useDefaultGateways: All`
- Cloudflare Tunnels integration
- Configurable health checks
- HPA support
- Persistent storage
- Init containers & sidecars
- Security contexts

### HTTPRoute Configuration

The app chart includes optional HTTPRoute support. By default, it uses `useDefaultGateways: All` to automatically bind to all default Gateways in the cluster (following Gateway API v1.4 best practices), but this can be configured via values.

```bash
helm template myapp app \
  --set image.repository=myregistry/myapp \
  --set image.tag=1.0.0 \
  --set container.port=8080 \
  --set httpRoute.enabled=true \
  --set httpRoute.hostnames[0]=myapp.example.com
```

See [app/README.md](app/README.md) for full documentation.

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
