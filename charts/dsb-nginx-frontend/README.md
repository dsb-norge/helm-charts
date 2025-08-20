# dsb-nginx-frontend

Helm chart for NGINX-based frontend containers. Designed for static sites or reverse-proxy frontends.

What you get:
- Deployment + Service (+ optional Ingress)
- Optional Prometheus nginx exporter sidecar and ServiceMonitor
- Config via ConfigMap (envify) and envFrom refs (Secrets/ConfigMaps)
- PDB with sensible defaults

## Quick start

Minimal values:

```yaml
image: dsbacr.azurecr.io/cache/docker-io/nginxinc/nginx-unprivileged
tag: "1.25-alpine"
resourceName: frontend
replicas: 2
port: 8080
```

Install/upgrade:

```bash
helm upgrade --install my-frontend charts/dsb-nginx-frontend -f my-values.yaml -n your-namespace
```

## Simple usage examples

Enable Ingress for one host:

```yaml
ingress_host: www.example.com
ingress_path: /
```

Inject configuration into ConfigMap (envify flattens YAML):

```yaml
config:
  LOC_API_PROXY_PASS_HOST: https://api.example.com
  CLIENT_MAX_BODY_SIZE: 20M
```

## Advanced usage

### Multiple Ingress hosts

```yaml
ingress:
  - host: example.com
  - host: www.example.com
    path: /app
```

### Prometheus exporter sidecar
Enabled by default. Configure with:

```yaml
prometheus_enabled: "true"
mgmt_image: dsbacr.azurecr.io/cache/docker-io/nginx/nginx-prometheus-exporter
mgmt_tag: "1.3"
```

### Volumes and mounts

```yaml
extraVolumes:
  - name: my-empty-dir
    emptyDir: {}
extraVolumeMounts:
  - name: my-empty-dir
    mountPath: /tmp
```

### Annotations
- Deployment annotations via `deploymentAnnotations`.
- Pod annotations via `podAnnotations` (protected checksum cannot be overridden).

## Reference: values
See `values.yaml` for all options including timeouts, websocket, and dashboard labels.

## Tests
Use helm-unittest; see root README for commands.
