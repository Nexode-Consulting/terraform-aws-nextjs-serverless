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

variable "cloudfront_price_class" {
  description = "Price class for the CloudFront distribution. Options: PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_100"
}

# Example:
# next_lambda_env_vars = {
#   BACKEND_VIRTUAL_DOMAIN    = "backend.example.com"
#   NEXT_PUBLIC_RECAPTCHA_KEY = "recaptcha-key" 
# }
variable "next_lambda_env_vars" {
  description = "Map of environment variables that you want to pass to the lambda"
  type        = map(any)
  default     = {}
}

variable "next_lambda_policy_statements" {
  description = "Map of dynamic policy statements to attach to Lambda Function role"
  type        = map(any)
  default     = {}
}

variable "lambda_memory_size" {
  description = "The memory size for the server side rendering Lambda"
  type        = number
  default     = 4096
}

variable "image_optimization_lambda_memory_size" {
  description = "The memory size for the image optimization Lambda"
  type        = number
  default     = 2048
}

variable "runtime" {
  description = "The runtime for the Lambdas"
  type        = string
  default     = "nodejs16.x"
}

variable "logs_retention" {
  description = "The number of days that cloudwatch logs should be retained"
  type        = number
  default     = 30
}
