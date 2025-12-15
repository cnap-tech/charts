# Generic App Chart

Generic Helm chart for deploying any Docker container to Kubernetes.

## Usage

```bash
helm install myapp . \
  --set image.repository=myregistry/myapp \
  --set image.tag=1.0.0 \
  --set container.port=8080
```

Or with a values file:

```yaml
image:
  repository: myregistry/myapp
  tag: '1.0.0'

container:
  port: 8080
  env:
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: db-creds
          key: url
    - name: NODE_ENV
      value: production

service:
  type: ClusterIP
  port: 80

httpRoute:
  enabled: true
  hostnames:
    - myapp.example.com
  # Rules are optional - defaults to routing all traffic to service

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
```

## Key Features

- Any Docker container deployment
- Service types: ClusterIP, NodePort, LoadBalancer
- Gateway API (HTTPRoute) support
- Cloudflare Tunnels integration
- Configurable health checks (HTTP, TCP, exec)
- HPA support
- Persistent volumes
- Init containers & sidecars
- Security contexts

## Gateway API

The HTTPRoute can use `useDefaultGateways: All` (default) to automatically bind to all default Gateways in the cluster, or use `parentRefs` to reference specific Gateways.

Basic HTTPRoute with default gateways:

```yaml
httpRoute:
  enabled: true
  useDefaultGateways: All  # Default - binds to all Gateways with defaultScope: All
  hostnames:
    - myapp.example.com
  # Rules are optional - defaults to routing all traffic to service
```

Using specific parent gateways:

```yaml
httpRoute:
  enabled: true
  # useDefaultGateways: null  # Leave empty to use parentRefs instead
  parentRefs:
    - name: gateway
      namespace: gateway-system
      sectionName: http
  hostnames:
    - myapp.example.com
```

Multiple paths:

```yaml
httpRoute:
  enabled: true
  hostnames:
    - myapp.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
    - matches:
        - path:
            type: Exact
            value: /health
```

Header-based routing:

```yaml
httpRoute:
  enabled: true
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
          headers:
            - name: x-version
              value: v2
```

## Cloudflare Tunnels

To use [Cloudflare Tunnels](https://github.com/pl4nty/cloudflare-kubernetes-gateway):

1. Install Gateway API CRDs:

```bash
kubectl apply -k github.com/kubernetes-sigs/gateway-api//config/crd?ref=v1.0.0
```

2. Install Cloudflare Gateway controller:

```bash
kubectl apply -k github.com/pl4nty/cloudflare-kubernetes-gateway//config/default?ref=v0.8.1
```

3. Create Cloudflare credentials secret:

```bash
kubectl create secret generic cloudflare \
  --from-literal=ACCOUNT_ID=your-account-id \
  --from-literal=TOKEN=your-api-token \
  -n cloudflare-gateway
```

4. Create GatewayClass:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: cloudflare
spec:
  controllerName: github.com/pl4nty/cloudflare-kubernetes-gateway
  parametersRef:
    group: ''
    kind: Secret
    namespace: cloudflare-gateway
    name: cloudflare
```

5. Create Gateway:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
  namespace: gateway-system
spec:
  gatewayClassName: cloudflare
  listeners:
    - protocol: HTTP
      port: 80
      name: http
```

6. Deploy your app with HTTPRoute enabled:

```yaml
httpRoute:
  enabled: true
  hostnames:
    - myapp.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
```

## Health Checks

HTTP:

```yaml
healthChecks:
  liveness:
    type: httpGet
    httpGet:
      path: /health
      port: http
```

TCP:

```yaml
healthChecks:
  liveness:
    type: tcpSocket
    tcpSocket:
      port: http
```

Disable:

```yaml
healthChecks:
  liveness:
    enabled: false
  readiness:
    enabled: false
```

## Storage

```yaml
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: myapp-data

volumeMounts:
  - name: data
    mountPath: /app/data
```

## Advanced

Init containers:

```yaml
initContainers:
  - name: migrations
    image: myapp:1.0.0
    command: ['python', 'manage.py', 'migrate']
```

Sidecars:

```yaml
sidecars:
  - name: logs
    image: fluent/fluent-bit:2.0
    volumeMounts:
      - name: logs
        mountPath: /var/log
```

## Private Registry

```bash
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.io \
  --docker-username=user \
  --docker-password=pass

# Then:
imagePullSecrets:
  - name: regcred
```
