#!/bin/bash
set -euxo pipefail

# Pull needed images:
docker pull helmunittest/helm-unittest:4.2.1-1.1.2
docker pull quay.io/helmpack/chart-testing:latest

# Run Helm linting:
docker run -it --rm --name ct --volume "$( pwd )":/data quay.io/helmpack/chart-testing:latest sh -c "ct lint --charts data/charts/dsb-nginx-frontend data/charts/dsb-spring-boot data/charts/dsb-spring-boot-job --debug --chart-dirs data/"

# Run unit tests:
docker run -it --rm --name unittest --volume "$(pwd)":/apps helmunittest/helm-unittest:4.2.1-1.1.2 charts/dsb-nginx-frontend charts/dsb-spring-boot charts/dsb-spring-boot-job
# Update snapshots:
# docker run --user 1001:1001 -it --rm --name unittest --volume "$(pwd)":/apps helmunittest/helm-unittest:4.2.1-1.1.2 --update-snapshot charts/*

# Create Kubernetes cluster:
kind create cluster --config kind-cluster-config.yaml

# Fetch test application used to test the charts:
az acr login -n dsbacr
docker pull dsbacr.azurecr.io/dsb-norge/test-application:latest
docker pull dsbacr.azurecr.io/dsb-norge/dsb-mssql-server:2019-latest
kind load docker-image dsbacr.azurecr.io/dsb-norge/test-application:latest
kind load docker-image dsbacr.azurecr.io/dsb-norge/dsb-mssql-server:2019-latest

# Run Helm tests:
docker run -it --rm --name ct --volume "$( pwd )":/data quay.io/helmpack/chart-testing:latest sh -c "ct install --charts data/charts/dsb-nginx-frontend data/charts/dsb-spring-boot data/charts/dsb-spring-boot-job --debug --chart-dirs data/"

# Delete Kubernetes cluster:
kind delete cluster
