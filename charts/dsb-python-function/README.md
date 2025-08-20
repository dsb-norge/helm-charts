# dsb-python-function

A simple Helm chart for deploying Python "function-style" HTTP containers to Kubernetes. focuses on fast, minimal setup with sensible defaults.

What you get:
- Deployment + Service (+ optional Ingress)
- PDB with sane defaults and automatic skip when replicas = 0
- Config via ConfigMap (envify) and envFrom refs (Secrets/ConfigMaps)
- Opt-in ServiceMonitor for Prometheus scraping
- Secure container defaults and rollout-on-change checksum

## Quick start

Minimal values:

```yaml
image: yourregistry/your-python-fn
tag: "1.0.0"
resourceName: my-python-fn   # optional; default: python-fn
replicas: 1
port: 8080                   # optional; default: 8080
```

Install/upgrade:

```bash
helm upgrade --install my-python-fn charts/dsb-python-function -f my-values.yaml -n your-namespace
```

## Simple usage examples

Expose over Ingress using a single host:

```yaml
ingress_host: api.example.com
ingress_path: /
```

Add health endpoints if they differ from defaults:

```yaml
health:
  livenessPath: /health
  readinessPath: /ready
```

Inject configuration via ConfigMap (envify flattens YAML to key=value):

```yaml
config:
  FEATURE_FLAG: true
  service:
    endpoint: https://backend.example.com
```

Reference existing secrets/configmaps via envFrom:

```yaml
secretRefs:
  - my-app-secrets
configMapRefs:
  - my-shared-config
```

## Advanced usage

### Ingress
- Set a single `ingress_host` + `ingress_path`, or provide multiple in `ingress`:

```yaml
ingress:
  - host: api.example.com
  - host: admin.example.com
    path: /v2
```

Note: This chart does not auto-add www hosts. Specify every host you need.

### PodDisruptionBudget (PDB)
- Enabled by default via `createPodDisruptionBudget: "true"`.
- Automatically not rendered if `replicas: 0`.
- Override minimum availability with `minAvailableReplicas` (defaults to replicas - 1).

### Resources

```yaml
memory_request: "128Mi"
memory_limit: "256Mi"
cpu_request: "50m"
cpu_limit: "200m"
```

### Volumes and mounts

```yaml
extraVolumes:
  - name: scratch
    emptyDir: {}
extraVolumeMounts:
  - name: scratch
    mountPath: /work
```

### Prometheus (ServiceMonitor)
Set `prometheus_enabled: "true"` if your app exposes metrics on the same HTTP port. This creates a ServiceMonitor scraping the Service port named `web`.

### Annotations and labels
- Add deployment annotations with `deploymentAnnotations`.
- Add/override pod annotations with `podAnnotations` (protected checksum cannot be overridden).
- `dashboard` values populate recommended Kubernetes labels.

## Reference: values

Key values available (see `values.yaml` for defaults):
- image, tag, imagePullPolicy
- replicas, createPodDisruptionBudget, minAvailableReplicas
- resourceName, port
- health.livenessPath, health.readinessPath
- ingress_host, ingress_path, ingress[]
- deploymentAnnotations, podAnnotations, dashboard, lang
- config (envify), secretRefs[], configMapRefs[]
- extraVolumes[], extraVolumeMounts[]
- memory/cpu request/limit
- prometheus_enabled

## Tips and troubleshooting
- Use `helm template` to inspect rendered manifests when debugging indentation or logic.
- The pod template includes a checksum annotation based on chart version and values, ensuring rollout on config changes.
- Security context defaults to non-root with read-only filesystem; relax only if your container requires writes.

## Tests
This repository uses helm-unittest. See the root README for lint/test commands and snapshot updates.
