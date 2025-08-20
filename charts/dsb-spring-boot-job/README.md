# dsb-spring-boot-job

Helm chart for running Spring Boot tasks as Kubernetes CronJobs.

What you get:
- CronJob with configurable schedule and suspend
- Env wiring via ConfigMap/Secret refs and Azure Key Vault CSI
- Resource limits and secure defaults

## Quick start

Minimal values:

```yaml
image: dsbacr.azurecr.io/dsb-norge/k8s-cron-api-caller
tag: "<version>"
schedule: "0 * * * *"   # hourly
```

Set Spring profile and env config:

```yaml
springProfiles: kubernetes
config:
  API_BASE_URL: https://service.example.com
  JOB_ENDPOINT: /maintenance
```

Reference secrets/configMaps via envFrom:

```yaml
secretRefs:
  - job-secrets
configMapRefs:
  - shared-config
```

## Advanced usage

### Azure Key Vault CSI
Mount secrets/keys/certs as env or files via `azureKeyVault.vaults` (supports default values for tenant/client/kvName).

### Suspend and deadlines

```yaml
suspend: false
activeDeadlineSeconds: 600
```

### Resources

```yaml
memory_request: "512Mi"
memory_limit: "1024Mi"
cpu_request: "100m"
cpu_limit: "2.5"
```

## Reference: values
See `values.yaml` for full schema of Key Vault integration and other features.

## Tests
Use helm-unittest; see root README for commands.
