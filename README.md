# [CNAP.tech](https://cnap.tech) Helm Charts

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
