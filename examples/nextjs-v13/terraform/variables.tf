variable "deployment_name" {
  type    = string
  default = "example-next-serverless"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "global_region" {
  type    = string
  default = "us-east-1"
}

variable "hosted_zone" {
  description = "Hosted Zone in Route53, e.g. my-dns-zone.de"
  type        = string
  default     = null
}

variable "deployment_domain" {
  type        = string
  description = "Url where the deployment should be availale at, e.g. website1.my-dns-zone.de"
  default     = null
}

variable "base_dir" {
  type    = string
  default = "../"
}
