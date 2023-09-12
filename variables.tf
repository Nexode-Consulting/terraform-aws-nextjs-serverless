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

# If you need a wildcard domain(ex: *.example.com), you can add it like this:
# aliases = [var.custom_domain, "*.${var.custom_domain}"]
variable "cloudfront_aliases" {
  description = "A list of custom domain for the cloudfront distribution, e.g. www.my-nextjs-app.com"
  type        = list(string)
  default     = []
}

# Example:
# next_lambda_env_vars = {
#   BACKEND_VIRTUAL_DOMAIN    = "backend.example.com"
#   NEXT_PUBLIC_RECAPTCHA_KEY = "recaptcha-key" 
# }
variable "next_lambda_env_vars" {
  description = "Map of environment variables that you want to pass to the lambda"
  type        = map(string)
  default     = {}
}

variable "next_lambda_policy_statements" {
  description = "Map of dynamic policy statements to attach to Lambda Function role"
  type        = map(string)
  default     = {}
}
