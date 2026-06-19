# Terraform AWS Design

This directory contains production-style AWS Terraform modules for the portfolio architecture.

Important:

- These modules are design-only by default.
- Do not run `terraform apply` unless you intentionally want to create AWS resources.
- Running `terraform apply` can create AWS costs.

Modules:

- `vpc`
- `eks`
- `guardduty`
- `security-hub`
- `cloudtrail`
- `waf`

Safe validation:

```bash
terraform -chdir=terraform/environments/prod-design init -backend=false
terraform -chdir=terraform/environments/prod-design validate
```
