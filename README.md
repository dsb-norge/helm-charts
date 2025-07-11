# Helm 3 charts for Spring Boot Applications

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

## DSB Spring Boot Chart

To debug locally (requires a kubeconfig setup to a live cluster):

```bash
helm upgrade --install --debug --dry-run -f example.yaml test-application dsb-spring-boot
```

The file `example.yaml` could be like this:

```yaml
    # ---
    replicas: 2

    image: "dsbacr.azurecr.io/dsb-norge/test-application"
    tag: "latest"

    application_traefik_rule: "Host(`dev-api.eksplosiver.no`) && PathPrefix(`/test`)"
```

To actually deploy, omit the --dry-run flag.

### Define a CronJob

If your application is only a spring boot application that should run as a cron job, use the chart 'dsb-spring-boot-job'.

Define a `jobs` entry like below:

```yaml
    jobs:
    - name: oauth-cron-example
      image_tag: 2abff46
      schedule: "*/1 * * * *"
      tokenURL: "https://devinternlogin.dsb.no/auth/realms/AD/protocol/openid-connect/token"
      apiPath: "/ping"
      method: "GET"
```

Required parameters:

* `name` - A name used to identify the given cron
* `image_tag` - the version of [k8s-cron-api-caller](https://github.com/dsb-norge/k8s-cron-api-caller) to use
* `schedule` - A given schedule to run on
* `tokenURL` - Path to get an oauth access token with `client_credentials` flow
* `apiPath` - The path to an endpoint on the current service/application to run

Optional parameters:

* `method` - The HTTP method to run GET/POST/PUT... Not specifying will make it a POST
* `clientId` - The clientID to use for access token. Default is: `<RELEASE_NAME>-cron-client`


You also require a client secret which is defined like the regular values.secrets only its from `values.job_secrets`
it needs to define a value called: `CLIENT_SECRET`

### Mount certificates from Azure Key Vault

Define `certificates` entry like below:

```yaml
    certificates:
      DSB_CERTIFICATE:
        key_vault:
          name: azure_key_vault_name
          keystore_ref: value_for_certificate
          keystore_password_ref: value_for_password
          keystore_alias_ref:  value_for_alias
        isBinary: true
        fileName: dsb-test-virksomhetssertifikat.pfx
        mountPath: /certificates
```

Note that the name of the Map itself. `DSB_CERTIFICATE` in the above example will be used for the resources
created. As well as environment variables inside the pod

Required parameters:

* `key_vault.name` - The name of the Azure Key Vault to get the values from
* `key_vault.keystore_ref` - The name of the certificate/keystore file in Azure Key Vault
* `key_vault.keystore_password_ref` - The name of the value containing the password to the certificate/keystore file
* `key_vault.keystore_alias_ref` - The name of the value containing the keystore alias for the given certificate
* `fileName` - What the file will be called inside the pod when mounted

Optional parameters:

* `isBinary` - Default: `true` whenever this file is in a binary format or not (PFX is binary, PEM is not)
* `mountPath` - Default: `/certificates` where the certificate/keystore will be mounted in the pod

Resulting environment variables in pods:

* `<name>_CERTIFICATE_PATH` - The path of where the certificate is located
* `<name>_CERTIFICATE_KEYSTORE` - The password to open the certificate/keystore
* `<name>_CERTIFICATE_ALIAS` - The alias of the key to use

### RBAC

To enable RBAC roles to be created set the value `rbac.enabled` to `true`.
then add any amount of entries like below. Note that the names `podPermission`, `nodePermission` is not
used for anything other than a way to document the given permissions below.

the api group `""` is the CoreApi of kubernetes.

These roles will be given to the deployment ServiceAccount which again is automatically mounted into the pods `/var/run/secrets/kubernetes.io/serviceaccount`
directory and can be used to authenticate against the kubernetes API

```yaml
rbac:
  enabled: true
  roles:
    podPermission:
      apiGroups:
        - ""
        - apps
      resources:
        - pods
        - deployments
      verbs:
        - list
        - watch
        - get
    nodePermissions:
      apiGroups:
        - ""
      resources:
        - nodes
      verbs:
        - list
        - get
```

## DSB Spring Boot Job Chart

Use this chart for creating a Spring Boot application that should run as a cron job. That is most often a console application.
