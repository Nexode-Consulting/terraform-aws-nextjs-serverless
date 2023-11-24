variable "deployment_name" {
  description = "The name that will be used in the resources, must be unique. We recommend to use up to 20 characters"
  type        = string
}

variable "region" {
  description = "The AWS region you wish to deploy your resources (ex. eu-central-1)"
  type        = string
}

variable "base_dir" {
  description = "The base directory of the next.js app"
  type        = string
  default     = "./"
}

variable "cloudfront_acm_certificate_arn" {
  description = "The certificate ARN for the cloudfront_aliases (CloudFront works only with certs stored in us-east-1)"
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

variable "next_lambda_memory_size" {
  description = "The memory size for the server side rendering Lambda (Set memory to between 128 MB and 10240 MB)"
  type        = number
  default     = 4096
}

variable "next_lambda_runtime" {
  description = "The runtime for the next lambda (nodejs16.x or nodejs18.x)"
  type        = string
  default     = "nodejs16.x"
}

variable "next_lambda_logs_retention" {
  description = "The number of days that cloudwatch logs of next lambda should be retained (Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653)"
  type        = number
  default     = 30
}

variable "next_lambda_ephemeral_storage_size" {
  description = "Amount of ephemeral storage (/tmp) in MB the next lambda can use at runtime. Valid value between 512 MB to 10240 MB"
  type        = number
  default     = 512
}

variable "api_gateway_log_format" {
  description = "Default stage's single line format of the access logs of data, as specified by selected $context variables"
  type        = string
  default     = "sourceIp: $context.identity.sourceIp, $context.domainName $context.requestTime \"$context.httpMethod $context.path $context.routeKey $context.protocol\" path: $context.customDomain.basePathMatched resp_status: $context.status integrationLatency: $context.integrationLatency responseLatency: $context.responseLatency requestId: $context.requestId Error: $context.integrationErrorMessage rawRequestPayloadSize: $input.body.size() rawRequestPayload: $input.body" # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging-variables.html
}

variable "image_optimization_runtime" {
  description = "The runtime for the image optimization Lambdas (nodejs16.x or nodejs18.x)"
  type        = string
  default     = "nodejs16.x"
}

variable "image_optimization_lambda_memory_size" {
  description = "The memory size for the image optimization Lambda (Set memory to between 128 MB and 10240 MB)"
  type        = number
  default     = 2048
}

variable "image_optimization_logs_retention" {
  description = "The number of days that cloudwatch logs of image optimization lambdas should be retained (Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653)"
  type        = number
  default     = 30
}

variable "image_optimization_ephemeral_storage_size" {
  description = "Amount of ephemeral storage (/tmp) in MB the image optimization lambdas can use at runtime. Valid value between 512 MB to 10240 MB"
  type        = number
  default     = 512
}

variable "cloudfront_cache_default_ttl" {
  description = "Default TTL in seconds for ordered cache behaviors"
  type        = number
  default     = 600
}

variable "cloudfront_cache_max_ttl" {
  description = "Default TTL in seconds for ordered cache behaviors"
  type        = number
  default     = 2592000
}

variable "cloudfront_cache_min_ttl" {
  description = "Default TTL in seconds for ordered cache behaviors"
  type        = number
  default     = 0
}
