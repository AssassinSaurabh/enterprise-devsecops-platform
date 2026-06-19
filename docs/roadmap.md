# Delivery Roadmap

## Project Name

Enterprise Secure Kubernetes Platform on AWS with Automated Threat Detection and Incident Response

## Delivery Model

The project was delivered as a local-first platform with an AWS production design layer.

Local implementation:

- Docker
- Kind
- Kubernetes
- GitHub Actions
- ArgoCD
- Prometheus
- Grafana
- Alertmanager
- Falco
- OPA Gatekeeper
- Trivy

AWS design layer:

- Terraform VPC module
- Terraform EKS module
- Terraform GuardDuty module
- Terraform Security Hub module
- Terraform CloudTrail module
- Terraform WAF module

The AWS layer is documented through Terraform modules and an example production composition.

## Completed Milestones

### Local Kubernetes Application Platform

Status: Complete

- Created three Flask microservices: auth, order, and payment.
- Containerized each service.
- Deployed services into the `dev` namespace.
- Added Kubernetes Services and Ingress.
- Added Prometheus metrics endpoints.

### Observability and Alerting

Status: Complete

- Added Prometheus ServiceMonitor resources.
- Added PrometheusRule alerts for CPU, memory, crash loops, and frequent restarts.
- Added AlertmanagerConfig routing.
- Added CPU and memory requests/limits to workloads.

### Runtime Security

Status: Complete

- Installed Falco locally with Helm.
- Added local Kind Falco values.
- Added custom runtime security rules.
- Verified detections for shell execution and sensitive file reads.

### Policy as Code

Status: Complete

- Installed OPA Gatekeeper.
- Added ConstraintTemplates and constraints.
- Enforced resource requests/limits in `dev`.
- Enforced privileged-container denial in `dev`.
- Added namespace label governance in dry-run mode.

### AWS Terraform Design

Status: Complete

- Added production-style Terraform modules.
- Added a `prod-design` example composition.
- Validated Terraform with `terraform validate`.
- Added a production-oriented Terraform composition.

### CI/CD

Status: Complete

- Added Platform CI workflow.
- Added Security Scan workflow.
- Verified GitHub Actions success on `main`.

## Future Enhancements

- Add container image publishing to GHCR or ECR.
- Add ArgoCD ApplicationSets for multiple environments.
- Add External Secrets or Vault integration.
- Add Grafana dashboards as code.
- Add local incident-response exercises.
- Add AWS deployment mode behind explicit safeguards.
