variable "name" {
  type = string
}

variable "log_bucket_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
