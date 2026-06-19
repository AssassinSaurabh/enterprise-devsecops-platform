# Enterprise Secure Kubernetes Platform Roadmap

Portfolio title:

**Enterprise Secure Kubernetes Platform on AWS with Automated Threat Detection and Incident Response**

## Build Strategy

This project is built local-first to avoid AWS charges while still showing production-grade cloud, security, and DevOps design.

Local execution cost: Rs. 0

- Docker
- Kind
- Kubernetes
- GitHub Actions
- ArgoCD
- Prometheus
- Grafana
- Trivy
- Alertmanager
- Falco
- OPA

AWS design cost: Rs. 0

- Terraform modules are written for production-style AWS architecture.
- Terraform modules are not applied from this project by default.
- No real AWS infrastructure is created unless explicitly chosen later.

## Sprint Plan

### Sprint 2: Local Kubernetes Platform

Status: Done

- Multi-service application manifests
- Kind-compatible image pull policy
- Kubernetes services and ingress
- Prometheus ServiceMonitor resources
- ArgoCD application definition

### Sprint 3: Alertmanager and Workload Alerts

Status: Done

- Alertmanager routing configuration
- CPU usage alerts
- Memory usage alerts
- Pod crash and restart alerts
- Resource requests and limits for alert baselines

### Sprint 4: Runtime Security

Status: Done

- Falco deployment
- Runtime security rules
- Container threat detection
- Suspicious shell, file, and network activity alerts

### Sprint 5: Policy as Code

Status: Done

- OPA Gatekeeper or Kyverno admission control
- Policy-as-code guardrails
- Image, privilege, namespace, and resource policies
- Policy test cases

### Sprint 6: AWS Terraform Design

Status: Done

- VPC module
- EKS module
- GuardDuty module
- Security Hub module
- CloudTrail module
- WAF module
- Example environment composition
- Documentation only unless AWS deployment is explicitly enabled

## Architecture Documentation Backlog

- Network diagram
- Security diagram
- CI/CD diagram
- Incident response diagram
