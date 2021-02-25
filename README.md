## Helm 3 chart for Spring Boot Applications

Create a new release by creating a tag prefixed with 'v' (like v1.0.0):

https://github.com/dsb-norge/spring-boot-chart/releases/new

To debug locally (requires a kubeconfig setup to a live cluster):

    helm upgrade --install --debug --dry-run --atomic -f example.yaml test-application dsb-spring-boot
    
The file `example.yaml` could be like this:

    ---
    replicas: 2
    
    image: "ghcr.io/dsb-norge/test-application"
    tag: "latest"
    
    application_traefik_rule: "Host(`dev-api.eksplosiver.no`) && PathPrefix(`/test`)" 
