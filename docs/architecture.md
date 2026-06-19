# Architecture: Enterprise Secure Kubernetes Platform

## Executive Summary

This project is a local-first DevSecOps platform that demonstrates how a production-grade cloud security platform would be designed, validated, monitored, and governed without creating real AWS resources.

The runnable environment uses Docker, Kind, Kubernetes, GitHub Actions, ArgoCD, Prometheus, Grafana, Alertmanager, Falco, Trivy, and OPA Gatekeeper. The AWS layer is represented as validated Terraform design modules for VPC, EKS, GuardDuty, Security Hub, CloudTrail, and WAF.

In simple terms:

- The application runs as three microservices on Kubernetes.
- GitHub Actions validates code, manifests, Terraform, Docker builds, and security scans.
- ArgoCD represents GitOps deployment.
- Prometheus and Alertmanager monitor application and workload health.
- Falco detects suspicious runtime behavior inside containers.
- OPA Gatekeeper blocks unsafe Kubernetes workloads before they enter the cluster.
- Terraform models the AWS production architecture but is not applied.

## System Context

```mermaid
flowchart TB
  User["Developer / Reviewer"] --> Repo["GitHub Repository"]
  Repo --> Actions["GitHub Actions CI"]
  Repo --> Argo["ArgoCD GitOps Controller"]

  Actions --> Validate["Validate Kubernetes, Terraform, Docker, Security"]
  Argo --> Cluster["Local Kind Kubernetes Cluster"]

  Cluster --> Apps["Application Microservices"]
  Cluster --> Monitoring["Prometheus, Grafana, Alertmanager"]
  Cluster --> RuntimeSecurity["Falco Runtime Security"]
  Cluster --> Admission["OPA Gatekeeper Admission Control"]

  Repo --> Terraform["AWS Terraform Design Modules"]
  Terraform -. "validate only, no apply" .-> AWSDesign["AWS Reference Architecture"]
```

## Local Kubernetes Runtime

```mermaid
flowchart LR
  Browser["Client / Tester"] --> Ingress["NGINX Ingress"]

  subgraph DevNamespace["Kubernetes namespace: dev"]
    Ingress --> Auth["auth-service :5001"]
    Ingress --> Order["order-service :5002"]
    Ingress --> Payment["payment-service :5003"]
  end

  Auth --> AuthMetrics["/metrics"]
  Order --> OrderMetrics["/metrics"]
  Payment --> PaymentMetrics["/metrics"]

  AuthMetrics --> Prometheus["Prometheus"]
  OrderMetrics --> Prometheus
  PaymentMetrics --> Prometheus
```

The application layer is intentionally simple so the platform engineering and security controls are easy to inspect. Each service exposes Prometheus metrics and runs with CPU and memory requests/limits so resource-based alerts and admission policies have meaningful data.

## CI/CD and GitOps Flow

```mermaid
sequenceDiagram
  participant Dev as Developer
  participant Git as GitHub Repository
  participant CI as GitHub Actions
  participant Argo as ArgoCD
  participant K8s as Kind Kubernetes

  Dev->>Git: Push code and platform configuration
  Git->>CI: Trigger Platform CI and Security Scan
  CI->>CI: Render Kubernetes manifests
  CI->>CI: Validate Terraform design
  CI->>CI: Build Docker images
  CI->>CI: Run Trivy filesystem scan
  Git->>Argo: Desired state is available from Git
  Argo->>K8s: Sync Kubernetes manifests
  K8s->>K8s: Run services in dev namespace
```

The project uses GitHub Actions as the quality gate. The pipeline does not deploy to AWS. It proves that the repository is buildable, scannable, and structurally valid before any deployment workflow would be considered.

## Security Architecture

```mermaid
flowchart TB
  subgraph Prevent["Prevent"]
    Gatekeeper["OPA Gatekeeper"]
    Policies["Policy as Code"]
    Gatekeeper --> Policies
    Policies --> Deny["Deny unsafe pods"]
  end

  subgraph Detect["Detect"]
    Falco["Falco"]
    Prometheus["Prometheus Rules"]
    Trivy["Trivy Scan"]
    Falco --> RuntimeAlerts["Runtime alerts"]
    Prometheus --> HealthAlerts["Health and resource alerts"]
    Trivy --> VulnerabilityFindings["Repository scan findings"]
  end

  subgraph Respond["Respond"]
    Alertmanager["Alertmanager"]
    Engineer["DevSecOps Engineer"]
    GitFix["Git-based fix"]
    Alertmanager --> Engineer
    RuntimeAlerts --> Engineer
    Engineer --> GitFix
  end

  Deny --> Engineer
  HealthAlerts --> Alertmanager
```

Security controls are layered:

- CI security: Trivy scans the repository.
- Admission security: OPA Gatekeeper blocks noncompliant pods in the `dev` namespace.
- Runtime security: Falco detects shell execution, sensitive file reads, and package manager execution inside application containers.
- Monitoring security: PrometheusRule resources detect CPU pressure, memory pressure, crash loops, and frequent restarts.

## Observability Flow

```mermaid
flowchart LR
  Apps["auth, order, payment services"] --> Metrics["Service /metrics endpoints"]
  Metrics --> ServiceMonitor["Prometheus ServiceMonitors"]
  ServiceMonitor --> Prometheus["Prometheus"]
  Prometheus --> Rules["PrometheusRule alerts"]
  Rules --> Alertmanager["Alertmanager routing"]
  Prometheus --> Grafana["Grafana dashboards"]
```

The monitoring stack is based on Prometheus Operator resources:

- `ServiceMonitor` discovers service metrics.
- `PrometheusRule` defines workload alerts.
- `AlertmanagerConfig` defines alert grouping and routing.

## Runtime Security Flow

```mermaid
sequenceDiagram
  participant Pod as Application Pod
  participant Runtime as Container Runtime
  participant Falco as Falco DaemonSet
  participant Logs as Falco JSON Logs
  participant Engineer as Security Engineer

  Pod->>Runtime: Process starts inside container
  Runtime->>Falco: System call event
  Falco->>Falco: Match custom runtime rule
  Falco->>Logs: Emit JSON alert
  Engineer->>Logs: Investigate command, user, pod, namespace
```

Falco runs as a DaemonSet so every node is monitored. The project includes custom rules for:

- Shell spawned inside application containers
- Sensitive file reads such as `/etc/passwd`
- Package manager execution inside application containers

## Admission Control Flow

```mermaid
sequenceDiagram
  participant User as User or Controller
  participant API as Kubernetes API Server
  participant GK as OPA Gatekeeper
  participant K8s as Kubernetes

  User->>API: Create or update Pod
  API->>GK: AdmissionReview
  GK->>GK: Evaluate Rego constraints
  alt Policy passes
    GK->>API: Allow
    API->>K8s: Persist workload
  else Policy fails
    GK->>API: Deny with violation message
    API->>User: Forbidden
  end
```

OPA Gatekeeper enforces two production-style controls in the `dev` namespace:

- Pods must define CPU and memory requests/limits.
- Pods must not run privileged containers.

Namespace labeling is configured in dry-run mode to show how audit-only governance can be introduced without breaking existing workloads.

## AWS Reference Architecture

```mermaid
flowchart TB
  Internet["Internet"] --> WAF["AWS WAF"]
  WAF --> ALB["Application Load Balancer"]

  subgraph AWS["AWS Account"]
    subgraph VPC["VPC"]
      subgraph Public["Public Subnets"]
        ALB
        NAT["NAT Gateway"]
      end

      subgraph Private["Private Subnets"]
        EKS["Amazon EKS Control Plane Integration"]
        Nodes["Managed Node Groups"]
        Pods["Application Pods"]
      end
    end

    CloudTrail["CloudTrail"] --> S3["Encrypted S3 Log Bucket"]
    GuardDuty["GuardDuty"] --> SecurityHub["Security Hub"]
    WAF --> CloudWatch["CloudWatch Metrics"]
  end

  ALB --> Nodes
  Nodes --> Pods
```

The AWS layer is intentionally design-only. Terraform modules are provided and validated, but not applied. This proves cloud architecture capability while avoiding accidental AWS charges.

Terraform modules:

- VPC networking
- EKS cluster and node group
- GuardDuty
- Security Hub
- CloudTrail
- WAFv2

## Incident Response Flow

```mermaid
flowchart LR
  Signal["Alert or Runtime Finding"] --> Triage["Triage"]
  Triage --> Evidence["Collect pod, logs, metrics, Falco event"]
  Evidence --> Scope["Identify affected namespace, pod, image, command"]
  Scope --> Contain["Contain via policy, scale, delete, or block"]
  Contain --> Fix["Commit manifest, image, or policy fix"]
  Fix --> CI["GitHub Actions validation"]
  CI --> GitOps["ArgoCD sync"]
  GitOps --> Review["Post-incident review"]
```

The platform is designed around Git-based remediation. Changes are made in code, validated in CI, and reconciled into the cluster through GitOps.

## What This Project Demonstrates

- Kubernetes platform engineering
- DevSecOps CI/CD design
- GitOps deployment patterns
- Prometheus-based monitoring and alerting
- Runtime threat detection with Falco
- Admission control with OPA Gatekeeper
- Secure AWS architecture design with Terraform
- Cost-aware cloud engineering discipline

## What This Project Does Not Do

- It does not create AWS infrastructure.
- It does not push container images to a public registry.
- It does not implement production identity, secrets management, or real incident paging.
- It does not claim the local Kind cluster is a substitute for production EKS.

Those choices are deliberate. The project focuses on demonstrating architecture, security controls, and DevSecOps workflows without creating cloud cost.
