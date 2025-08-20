# dsb-spring-boot

Helm chart for Spring Boot applications (web/API), with batteries included for common needs.

What you get:
- Deployment + Service (+ optional Ingress)
- Probes targeting actuator liveness/readiness
- Azure Key Vault CSI helpers (env and file mount)
- Optional Redis cache and development database container
- Mounted configuration and certificates
- Optional ServiceMonitor for Prometheus scraping
- PDB and secure defaults

## Quick start

Minimal values:

```yaml
image: dsbacr.azurecr.io/dsb-norge/your-spring-app
tag: "1.0.0"
replicas: 2
application_web_port: 8080
application_actuator_port: 8180
```

Enable Ingress:

```yaml
ingress_host: api.example.com
ingress_path: /
```

## Advanced usage

### Spring profiles and JAVA options

```yaml
springProfiles: kubernetes
java_opts: "-Xms512m -Xmx1024m"
jvm_head_room: "10"   # percent headroom for Paketo JVM calculator
```

### Azure Key Vault via CSI driver
Define vaults and objects to mount as env/file using `azureKeyVault.vaults`.
You can set `global.azureKeyVaultDefaultValues` to avoid repetition (tenantId, clientId, kvName).

```yaml
azureKeyVault:
  defaultValues:
    tenantId: <GUID>
    clientId: <GUID>
    kvName: your-kv
  vaults:
    minimalDef:
      secrets:
        - nameInKv: my-secret
          mountAsEnv: APP__SECRET
```

The chart’s helpers render env vars and volume mounts/files for keys, secrets, and certs with optional path/encoding controls. See `values.yaml` for full schema.

### Mounted configuration
Mount an existing ConfigMap of Spring config files and set `SPRING_CONFIG_ADDITIONAL_LOCATION` automatically:

```yaml
configurationConfigMap: my-spring-config
```

### Development database and cache

```yaml
database_container:
  enabled: true
  image: dsbacr.azurecr.io/dsb-norge/dsb-mssql-server:2019-latest
  database: emptydb
  user: sa
  password: DoN0tUse1Production

cache:
  enabled: true
  image: dsbacr.azurecr.io/cache/docker-io/library/redis
  tag: alpine
```

### Workload Identity

```yaml
azureWorkloadIdentity:
  clientId: <managed-identity-client-id>
```

This adds the label `azure.workload.identity/use: true` and uses the identity in CSI mounts.

### Graceful shutdown

```yaml
shutdown:
  graceful: true
  timeoutPerShutdownPhase: 30s
  terminationGracePeriodSeconds: 45
```

### Resources and security
Set `memory_*` and `cpu_*` values, default securityContext is non-root with readOnlyRootFilesystem.

### Prometheus
Set `prometheus_enabled: "true"` and optionally `prometheus_path` for actuator metrics.

## Reference: values
See `values.yaml` for exhaustive options including RBAC roles, websockets, labels, and persistent storage via BlobFuse CSI.

## Tests
Use helm-unittest; see root README for commands.
