# Terraform AWS Design

This directory contains production-style AWS Terraform modules for the platform reference architecture.

Modules:

- `vpc`
- `eks`
- `guardduty`
- `security-hub`
- `cloudtrail`
- `waf`

Validation:

```bash
terraform -chdir=terraform/environments/prod-design init -backend=false
terraform -chdir=terraform/environments/prod-design validate
```
