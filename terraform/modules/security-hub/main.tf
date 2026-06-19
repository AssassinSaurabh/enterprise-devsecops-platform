resource "aws_securityhub_account" "this" {
  enable_default_standards = false
}

resource "aws_securityhub_standards_subscription" "standards" {
  for_each = toset(var.enabled_standards)

  standards_arn = each.value

  depends_on = [aws_securityhub_account.this]
}
