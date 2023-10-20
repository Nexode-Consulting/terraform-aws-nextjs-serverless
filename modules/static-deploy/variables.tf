variable "deployment_name" {
  type = string
}

variable "base_dir" {
  type = string
}

variable "dynamic_origin_domain_name" {
  type = string
}

variable "cloudfront_acm_certificate_arn" {
  type    = string
  default = null
}

variable "cloudfront_price_class" {
  type = string
}

variable "cloudfront_aliases" {
  type = list(string)
}

variable "image_optimization_qualified_arn" {
  type = string
}

variable "image_redirection_qualified_arn" {
  type = string
}
