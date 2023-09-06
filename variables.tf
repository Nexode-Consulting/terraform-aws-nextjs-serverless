variable "deployment_name" {
  type    = string
  default = "nextjs-serverless"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "global_region" {
  type    = string
  default = "us-east-1"
}

variable "base_dir" {
  type    = string
  default = "./"
}

# CloudFront works only with certs stored in us-east-1
variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "cloudfront_aliases" {
  description = "Your custom domain"
  type        = list(string)
  default     = []
}
