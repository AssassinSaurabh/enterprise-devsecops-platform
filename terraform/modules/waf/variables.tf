variable "name" {
  type = string
}

variable "scope" {
  type    = string
  default = "REGIONAL"
}

variable "managed_rule_groups" {
  type = list(object({
    name        = string
    vendor_name = string
    priority    = number
  }))
  default = [
    {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
      priority    = 10
    },
    {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name = "AWS"
      priority    = 20
    }
  ]
}

variable "tags" {
  type    = map(string)
  default = {}
}
