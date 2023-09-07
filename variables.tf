variable "deployment_name" {
  description = "the name that will be used in the resources"
  type        = string
  default     = "nextjs-serverless"
}

variable "region" {
  description = "The aws region you wish to deploy your resources"
  type        = string
  default     = "eu-central-1"
}

variable "global_region" {
  description = "The aws global region, must be us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "base_dir" {
  description = "The base directory of the next.js app"
  type        = string
  default     = "./"
}

# CloudFront works only with certs stored in us-east-1
variable "cloudfront_acm_certificate_arn" {
  description = "The certificate ARN for the cloudfront_aliases"
  type        = string
  default     = null
}

variable "cloudfront_aliases" {
  description = "A list of custom domain for the cloudfront distribution, e.g. www.my-nextjs-app.com"
  type        = list(string)
  default     = []
}

variable "next_lambda_env_vars" {
  type    = map(string)
  default = {}
}
