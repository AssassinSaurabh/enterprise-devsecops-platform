# Sprint 3: Alertmanager and Workload Alerts Implementation Log

Date: 2026-06-19

Goal:

Build Sprint 3 locally with zero AWS cost by adding Alertmanager routing and Kubernetes workload alerts for CPU, memory, pod crashes, and frequent restarts.

## Step 1: Confirm Repository State

Command used:

```bash
rg --files -g '!*node_modules*' -g '!target'
git status --short
```

What was found:

- The project already had Sprint 2 Kubernetes manifests for auth, order, and payment services.
- The repo already had uncommitted Sprint 2 work.
- Existing monitoring resources included ServiceMonitor manifests for the application services.

Decision:

- Keep Sprint 3 changes additive.
- Do not remove or revert any existing user/Sprint 2 work.

## Step 2: Add Resource Requests and Limits

Files updated:

- `kubernetes/auth/deployment.yaml`
- `kubernetes/order/deployment.yaml`
- `kubernetes/payment/deployment.yaml`

What was added:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

Why this was needed:

- CPU alerts are more meaningful when compared against CPU requests.
- Memory alerts are more meaningful when compared against memory limits.
- This also makes the Kubernetes workloads more production-like.

## Step 3: Add Prometheus Alert Rules

File added:

- `kubernetes/monitoring/platform-alerts.yaml`

Alerts added:

- `PlatformPodCrashLooping`
- `PlatformPodRestartingFrequently`
- `PlatformHighCPUUsage`
- `PlatformHighMemoryUsage`

Important design choices:

- CrashLoopBackOff is marked `critical`.
- Frequent restarts, high CPU, and high memory are marked `warning`.
- Alerts are scoped to the local `dev` namespace.
- Labels include `team: platform` for routing and ownership.

## Step 4: Add Alertmanager Routing

File added:

- `kubernetes/monitoring/alertmanager-config.yaml`

What was configured:

- Alert grouping by namespace, alert name, and severity.
- Critical alerts repeat every 1 hour.
- Warning alerts repeat every 4 hours.
- Receiver is currently `local-null`.

Why `local-null` was used:

- This project avoids external paid services.
- No Slack, PagerDuty, email SMTP, or cloud notification integration is required for the local portfolio build.
- The routing structure is ready for a real receiver later.

## Step 5: Wire Sprint 3 Into Kustomize

File updated:

- `kubernetes/kustomization.yaml`

Resources added:

```yaml
- monitoring/alertmanager-config.yaml
- monitoring/platform-alerts.yaml
```

Validation command:

```bash
kubectl kustomize kubernetes
```

Result:

- Kustomize rendered successfully.

## Step 6: First Rule Validation Error

Command used:

```bash
promtool check rules kubernetes/monitoring/platform-alerts.yaml
```

Error:

```text
yaml: unmarshal errors:
  line 1: field apiVersion not found in type rulefmt.RuleGroups
  line 2: field kind not found in type rulefmt.RuleGroups
  line 3: field metadata not found in type rulefmt.RuleGroups
  line 8: field spec not found in type rulefmt.RuleGroups
```

Why it happened:

- `platform-alerts.yaml` is a Kubernetes `PrometheusRule` custom resource.
- `promtool check rules` expects native Prometheus rule YAML that starts with `groups`.
- The alert rules were not wrong; the file format was different from what `promtool` expects.

Fix:

- Extract only `.spec.groups` into a temporary Prometheus-native rules file.

Command used:

```bash
ruby -e 'require "yaml"; doc=YAML.load_file("kubernetes/monitoring/platform-alerts.yaml"); File.write("/private/tmp/platform-alert-rules.yaml", {"groups"=>doc.fetch("spec").fetch("groups")}.to_yaml)'
promtool check rules /private/tmp/platform-alert-rules.yaml
```

Result:

```text
SUCCESS: 4 rules found
```

## Step 7: Kubernetes API Sandbox Error

Command used:

```bash
kubectl get ns
```

Error:

```text
Unable to connect to the server: dial tcp 127.0.0.1:62344: connect: operation not permitted
```

Why it happened:

- The local Kind cluster was running.
- The Codex sandbox blocked direct access to the local Kubernetes API port.

Fix:

- Re-ran the Kubernetes commands with approved local cluster access.

Result:

- The Kind context `kind-enterprise` was reachable.
- The cluster namespaces were visible.

## Step 8: Verify Monitoring Stack Exists

Commands used:

```bash
kubectl get crd prometheusrules.monitoring.coreos.com alertmanagerconfigs.monitoring.coreos.com servicemonitors.monitoring.coreos.com
kubectl get pods -n monitoring
```

Result:

- PrometheusRule CRD exists.
- AlertmanagerConfig CRD exists.
- ServiceMonitor CRD exists.
- Prometheus, Alertmanager, Grafana, kube-state-metrics, node-exporter, and Prometheus Operator were running.

Conclusion:

- The cluster was ready for Sprint 3 resources.

## Step 9: Inspect Current Application State

Commands used:

```bash
kubectl get deploy,svc,ingress -n dev
kubectl get servicemonitor,prometheusrule,alertmanagerconfig -n monitoring
```

What was found:

- `order-service` and `payment-service` were running.
- `auth-service` was missing from the active dev workloads.
- Existing ServiceMonitor resources were present.
- Sprint 3 PrometheusRule and AlertmanagerConfig were not yet applied.

Decision:

- Apply the full Kustomize bundle so the cluster matches the repo.

## Step 10: Apply Sprint 3 Manifests

Command used:

```bash
kubectl apply -k kubernetes
```

Result:

- `auth-service` service created.
- `auth-service` deployment created.
- `order-service` and `payment-service` deployments configured.
- `platform-workload-alerts` PrometheusRule created.
- `platform-alert-routing` AlertmanagerConfig created.
- Existing ingress and ServiceMonitors were unchanged or configured.

Warning encountered:

```text
resource namespaces/dev is missing the kubectl.kubernetes.io/last-applied-configuration annotation
resource namespaces/monitoring is missing the kubectl.kubernetes.io/last-applied-configuration annotation
```

Why it happened:

- The namespaces already existed but were not originally created with `kubectl apply`.
- Kubernetes patched the missing annotation automatically.

Action taken:

- No manual fix was required.
- This is normal when converting manually created resources into declarative resources.

## Step 11: Verify Application Rollouts

Commands used:

```bash
kubectl rollout status deployment/auth-service -n dev --timeout=120s
kubectl rollout status deployment/order-service -n dev --timeout=120s
kubectl rollout status deployment/payment-service -n dev --timeout=120s
kubectl get pods -n dev
```

Result:

- `auth-service` successfully rolled out.
- `order-service` successfully rolled out.
- `payment-service` successfully rolled out.
- All dev pods were `Running`.

Final dev pod state:

```text
auth-service     3/3 pods running
order-service    2/2 pods running
payment-service  2/2 pods running
```

## Step 12: Verify Prometheus Operator Accepted the Rule

Command used:

```bash
kubectl get prometheusrule platform-workload-alerts -n monitoring -o jsonpath='{.metadata.annotations.prometheus-operator-validated}{"\n"}'
```

Result:

```text
true
```

Conclusion:

- Prometheus Operator validated the Sprint 3 alert rule.
- The PrometheusRule is accepted by the monitoring stack.

## Step 13: Prometheus Container Debug Error

Command attempted:

```bash
kubectl exec -n monitoring prometheus-monitoring-kube-prometheus-prometheus-0 -c prometheus -- wget -qO- 'http://127.0.0.1:9090/api/v1/rules'
```

Error:

```text
exec: "wget": executable file not found in $PATH
```

Follow-up commands attempted:

```bash
kubectl exec -n monitoring prometheus-monitoring-kube-prometheus-prometheus-0 -c prometheus -- ls /bin
kubectl exec -n monitoring prometheus-monitoring-kube-prometheus-prometheus-0 -c prometheus -- ls /usr/bin
```

Error:

```text
exec: "ls": executable file not found in $PATH
```

Why it happened:

- The Prometheus container image is minimal.
- Common debug tools such as `wget` and `ls` are not available inside that container.

Decision:

- Do not modify the Prometheus pod just for debugging.
- Use Kubernetes resource state and Prometheus Operator validation as the reliable verification path.

## Current Sprint 3 Status

Completed:

- Alertmanager routing resource added.
- CPU alert added.
- Memory alert added.
- Pod crash alert added.
- Pod frequent restart alert added.
- Workload resource requests and limits added.
- Kustomize rendering verified.
- Prometheus rule syntax verified with `promtool`.
- Manifests applied to local Kind cluster.
- Application rollouts verified.
- Prometheus Operator validation verified.

Remaining optional improvements:

- Add a real local-only receiver later, such as a webhook receiver running inside the cluster.
- Add Grafana dashboard panels for alert status.
- Add a deliberate test workload to trigger CPU, memory, and crash alerts for demo screenshots.
- Add architecture diagrams for network, security, CI/CD, and incident response.

## Next Sprint Direction

Sprint 4 can now begin:

- Install Falco locally on Kind.
- Add runtime security detection.
- Detect suspicious shell execution inside containers.
- Detect sensitive file access.
- Send Falco events toward the monitoring/logging path.

No AWS resources were created.
No AWS cost was generated.
