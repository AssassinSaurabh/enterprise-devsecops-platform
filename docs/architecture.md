# Enterprise Secure Kubernetes Platform Architecture

Portfolio title:

**Enterprise Secure Kubernetes Platform on AWS with Automated Threat Detection and Incident Response**

## Network Diagram

```mermaid
flowchart LR
  Dev["Developer Laptop"] --> Docker["Docker"]
  Docker --> Kind["Kind Kubernetes Cluster"]
  Kind --> Ingress["NGINX Ingress"]
  Ingress --> Auth["auth-service"]
  Ingress --> Order["order-service"]
  Ingress --> Payment["payment-service"]
  Auth --> Metrics["/metrics"]
  Order --> Metrics
  Payment --> Metrics
  Metrics --> Prometheus["Prometheus"]
  Prometheus --> Grafana["Grafana"]
  Prometheus --> Alertmanager["Alertmanager"]
```

## Security Diagram

```mermaid
flowchart TB
  Code["Application and Kubernetes Code"] --> CI["GitHub Actions"]
  CI --> Trivy["Trivy Security Scan"]
  CI --> DockerBuild["Docker Build Validation"]
  DockerBuild --> Kind["Local Kind Cluster"]

  Kind --> Gatekeeper["OPA Gatekeeper Admission Control"]
  Gatekeeper --> PolicyDeny["Deny Bad Pods"]

  Kind --> Falco["Falco Runtime Security"]
  Falco --> RuntimeAlerts["Runtime Threat Alerts"]

  Kind --> Prometheus["Prometheus"]
  Prometheus --> AlertRules["CPU, Memory, CrashLoop, Restart Alerts"]
  AlertRules --> Alertmanager["Alertmanager Routing"]
```

## CI/CD Diagram

```mermaid
flowchart LR
  Dev["Developer"] --> Git["Git Repository"]
  Git --> Actions["GitHub Actions"]
  Actions --> Lint["Manifest and Terraform Validation"]
  Actions --> Scan["Trivy Filesystem Scan"]
  Actions --> Build["Docker Image Builds"]
  Build --> Registry["Image Registry or Local Kind Load"]
  Registry --> ArgoCD["ArgoCD"]
  ArgoCD --> K8s["Kubernetes dev Namespace"]
```

## Incident Response Diagram

```mermaid
sequenceDiagram
  participant Runtime as Container Runtime
  participant Falco as Falco
  participant Prom as Prometheus
  participant AM as Alertmanager
  participant Engineer as DevSecOps Engineer
  participant Git as GitOps Repo

  Runtime->>Falco: Suspicious shell or sensitive file access
  Falco->>Engineer: Runtime alert in logs
  Prom->>AM: CPU, memory, crash, or restart alert
  AM->>Engineer: Routed alert
  Engineer->>Prom: Inspect metrics and pod state
  Engineer->>Falco: Review runtime evidence
  Engineer->>Git: Commit policy or workload fix
  Git->>ArgoCD: Sync desired state
```

## AWS Design-Only Architecture

```mermaid
flowchart TB
  Users["Users"] --> WAF["AWS WAF"]
  WAF --> ALB["Application Load Balancer"]
  ALB --> EKS["Amazon EKS"]
  EKS --> PrivateSubnets["Private Subnets"]
  PrivateSubnets --> Nodes["Managed Node Groups"]

  VPC["VPC"] --> PublicSubnets["Public Subnets"]
  VPC --> PrivateSubnets
  PublicSubnets --> NAT["NAT Gateway"]

  CloudTrail["CloudTrail"] --> S3["Encrypted S3 Log Bucket"]
  GuardDuty["GuardDuty"] --> Findings["Security Findings"]
  SecurityHub["Security Hub"] --> Findings
```

## Cost Control

- Local implementation runs on Docker and Kind.
- AWS Terraform modules are design-only.
- Terraform validation is allowed.
- Terraform apply is not part of this project workflow.
- No AWS resources are created unless explicitly chosen later.
