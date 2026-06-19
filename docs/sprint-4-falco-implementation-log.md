# Sprint 4: Falco Runtime Security Implementation Log

Date: 2026-06-19

Goal:

Move forward after Sprint 3 by preparing Falco runtime security for the local Kind platform.

## Step 1: Confirm Helm Availability

Command used:

```bash
which helm
```

Result:

```text
/opt/homebrew/bin/helm
```

Decision:

- Use the official Falco Helm chart instead of hand-writing a large DaemonSet.
- This keeps the deployment closer to real-world platform engineering practice.

## Step 2: Add Official Falco Chart Repository

Command used:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
```

Result:

```text
"falcosecurity" has been added to your repositories
```

## Step 3: Update Chart Repository and Inspect Versions

Commands used:

```bash
helm repo update falcosecurity
helm search repo falcosecurity/falco --versions
```

Result:

- Latest available chart found: `falcosecurity/falco` chart `9.1.0`
- Falco app version: `0.44.1`

Decision:

- Pin Sprint 4 to chart version `9.1.0` for reproducibility.

## Step 4: Inspect Chart Values Before Writing Config

Commands used:

```bash
helm show values falcosecurity/falco --version 9.1.0
```

Focused sections inspected:

- `driver`
- `metrics`
- `serviceMonitor`
- `customRules`
- `falco.json_output`
- `falco.stdout_output`
- `falco.webserver`

What was learned:

- The chart supports `customRules`.
- The chart can create a ServiceMonitor.
- Falco can emit JSON alerts to stdout.
- Falco can expose Prometheus metrics through its webserver.
- The chart supports automatic driver selection with `driver.kind: auto`.

## Step 5: Create Local Kind Values File

File added:

- `security/falco/values-kind.yaml`

What was configured:

- Falco runs as a DaemonSet.
- Driver selection uses `auto`.
- JSON output is enabled.
- Stdout alert output is enabled.
- Syslog output is disabled for simpler local demos.
- Falco metrics are enabled.
- ServiceMonitor is enabled with `release: monitoring`.
- Custom platform runtime rules are added.

## Step 6: Add Custom Runtime Rules

Custom rule file inside Helm values:

- `platform-runtime-rules.yaml`

Rules added:

- `Platform Shell Spawned In Application Container`
- `Platform Sensitive File Read In Application Container`
- `Platform Package Manager Started In Application Container`

Why these rules were chosen:

- They are practical DevSecOps portfolio detections.
- They are safe to trigger locally.
- They demonstrate runtime security without needing a real attacker or AWS environment.

## Step 7: Add Sprint 4 Runbook

File added:

- `docs/runbooks/sprint-4-falco-runtime-security.md`

The runbook includes:

- Install commands
- Verification commands
- Safe demo triggers
- Expected output fields
- Cost-control note

## Current Sprint 4 Status

Completed:

- Official chart repository added.
- Chart version selected.
- Chart values inspected.
- Local Kind values file created.
- Custom runtime rules written.
- Runbook written.
- Helm template rendering verified.
- Falco installed into the local Kind cluster.
- Falco DaemonSet verified across all Kind nodes.
- Shell execution detection tested.
- Sensitive file read detection tested.

## Step 8: Render Helm Chart Locally

Command used:

```bash
helm template falco falcosecurity/falco \
  --namespace falco \
  --version 9.1.0 \
  -f security/falco/values-kind.yaml
```

Result:

- Helm rendered successfully.
- Generated resources included:
  - ServiceAccount
  - ConfigMaps
  - RBAC
  - Metrics Service
  - DaemonSet
  - ServiceMonitor

## Step 9: Install Falco Locally

Command used:

```bash
helm upgrade --install falco falcosecurity/falco \
  --namespace falco --create-namespace \
  --version 9.1.0 \
  -f security/falco/values-kind.yaml
```

Result:

```text
Release "falco" does not exist. Installing it now.
STATUS: deployed
REVISION: 1
```

## Step 10: First Status Check

Commands used:

```bash
kubectl get pods -n falco -o wide
kubectl get ds,svc,servicemonitor -n falco
helm status falco -n falco
```

Initial result:

```text
falco pods were in Init phase
daemonset.apps/falco desired=4 current=4 ready=0
```

Why it happened:

- This was the first Falco install on the Kind cluster.
- Kubernetes needed to pull these images:
  - `falcosecurity/falco-driver-loader:0.44.1`
  - `falcosecurity/falcoctl:0.13.0`
  - `falcosecurity/falco:0.44.1`

Action taken:

- Waited and checked again.
- No config change was required.

## Step 11: Verify Falco Readiness

Commands used:

```bash
kubectl get pods -n falco
kubectl get ds falco -n falco
kubectl get servicemonitor falco -n falco -o jsonpath='{.metadata.labels.release}{"\n"}'
```

Final result:

```text
falco pods: 4/4 Running
daemonset.apps/falco desired=4 current=4 ready=4
ServiceMonitor label: monitoring
```

Conclusion:

- Falco is running on all four Kind nodes.
- Prometheus can discover Falco metrics through the ServiceMonitor label.

## Step 12: Trigger Safe Runtime Security Events

Commands used:

```bash
kubectl exec -n dev deploy/auth-service -- sh -c 'echo sprint4-shell-demo'
kubectl exec -n dev deploy/auth-service -- sh -c 'cat /etc/passwd >/dev/null'
```

Result:

- The shell command completed successfully.
- The sensitive file read command completed successfully.
- Both actions were safe local demo events.

## Step 13: Verify Falco Alerts

Command used:

```bash
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco --since=5m | rg "Platform Shell Spawned|Platform Sensitive File|Platform Package Manager|sprint4|/etc/passwd"
```

Alerts captured:

```text
rule="Platform Shell Spawned In Application Container"
namespace="dev"
pod="auth-service-649b8849d5-dkshf"
command="sh -c echo sprint4-shell-demo"
priority="Warning"
```

```text
rule="Platform Sensitive File Read In Application Container"
namespace="dev"
pod="auth-service-649b8849d5-dkshf"
file="/etc/passwd"
command="cat /etc/passwd"
priority="Warning"
```

Conclusion:

- Sprint 4 runtime detection is working.
- Falco successfully detected container shell activity.
- Falco successfully detected sensitive file access inside an application container.

## Next:

- Add Grafana dashboard or screenshots for evidence.
- Add Falco alert forwarding later if a local webhook receiver is added.
- Continue to Sprint 5: OPA admission control and policy-as-code.

No AWS resources were created.
No AWS cost was generated.
