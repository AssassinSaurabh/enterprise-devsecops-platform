variable "name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_subnet_ids" {
  type = list(string)
}

variable "enable_public_endpoint" {
  type    = bool
  default = false
}

variable "public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "tags" {
  type    = map(string)
  default = {}
}
