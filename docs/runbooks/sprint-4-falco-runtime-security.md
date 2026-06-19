# Sprint 4: Falco Runtime Security Runbook

Goal:

Install Falco locally on Kind to detect runtime container threats without creating any AWS resources.

## Why Falco

Falco watches Linux runtime activity and Kubernetes/container metadata. It is useful for detecting behaviors such as:

- Shells spawned inside containers
- Sensitive file access
- Package manager execution inside application containers
- Unexpected process and network behavior

## Local Install

Add and update the official Falco chart repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update falcosecurity
```

Install or upgrade Falco:

```bash
helm upgrade --install falco falcosecurity/falco \
  --namespace falco --create-namespace \
  --version 9.1.0 \
  -f security/falco/values-kind.yaml
```

Verify pods:

```bash
kubectl get pods -n falco
```

Verify Prometheus discovery:

```bash
kubectl get servicemonitor -n falco
```

View Falco alerts:

```bash
kubectl logs -n falco -l app.kubernetes.io/name=falco -f
```

## Safe Demo Triggers

Trigger a shell alert:

```bash
kubectl exec -n dev deploy/auth-service -- sh -c 'echo sprint4-shell-demo'
```

Trigger a sensitive file read alert:

```bash
kubectl exec -n dev deploy/auth-service -- sh -c 'cat /etc/passwd >/dev/null'
```

## Expected Result

Falco should emit JSON alerts to stdout with fields such as:

- `rule`
- `priority`
- `output`
- `k8s.ns.name`
- `k8s.pod.name`
- `container.name`
- `proc.cmdline`

## Cost Control

This setup runs only on the local Kind cluster.

No AWS resources are created.
No AWS billing is generated.
