variable "finding_publishing_frequency" {
  type    = string
  default = "FIFTEEN_MINUTES"
}

variable "tags" {
  type    = map(string)
  default = {}
}
