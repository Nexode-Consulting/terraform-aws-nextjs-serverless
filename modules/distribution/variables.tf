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

variable "lambda_forwarder_qualified_arn" {
  type = string
}

variable "static_assets_bucket" {
  type = map(any)
}

variable "static_assets_origin_id" {
  type = map(any)
}

variable "public_assets_bucket" {
  type = map(any)
}

variable "public_assets_bucket_region" {
  type = string
}

variable "public_assets_origin_id" {
  type = map(any)
}

variable "server_asssets_bucket_domain" {
  type = string
}
