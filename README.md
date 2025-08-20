# Helm 3 charts for DSB applications

This repo contains multiple Helm charts used across DSB workloads. Each chart has its own README with usage and values.

Charts included:

- [dsb-nginx-frontend](charts/dsb-nginx-frontend/README.md): NGINX-based frontend container
- [dsb-spring-boot](charts/dsb-spring-boot/README.md): Spring Boot web/API service
- [dsb-spring-boot-job](charts/dsb-spring-boot-job/README.md): Spring Boot CronJob model
- [dsb-python-function](charts/dsb-python-function/README.md): Simple Python function/container (HTTP) service

Create a new release by committing a new version in `charts/*/Chart.yaml`.

## Linting

```bash
# Helm
helm lint charts/*

# Chart-testing
docker run --pull always -it --rm --name unittest --volume "$(pwd)":"$(pwd)" --workdir "$(pwd)" dsbacr.azurecr.io/cache/quay-io/helmpack/chart-testing ct lint --all --validate-maintainers=false
```

## Unit tests

### Run unit tests

```bash
docker run --pull always -it --rm --name unittest --volume "$(pwd)":/apps dsbacr.azurecr.io/cache/docker-io/helmunittest/helm-unittest charts/*
```

### Update the test snapshots

```bash
docker run --user 1001:1001 --pull always -it --rm --name unittest --volume "$(pwd)":/apps dsbacr.azurecr.io/cache/docker-io/helmunittest/helm-unittest --update-snapshot charts/*
```

### Debug errors like `error converting YAML to JSON: yaml: line X`

Running the command

```bash
helm template -f example.yaml test-application [CHART_NAME] > output.yaml
```

will produce an output structure in output.yaml making it easier to see indenting faults or similar

## Chart-specific docs

Each chart has its own README with values and examples:

- charts/dsb-nginx-frontend/README.md
- charts/dsb-spring-boot/README.md
- charts/dsb-spring-boot-job/README.md
- charts/dsb-python-function/README.md
