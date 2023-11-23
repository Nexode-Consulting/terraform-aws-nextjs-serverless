provider "aws" {
  alias  = "global_region"
  region = "us-east-1"
}

####################################
######## image_optimization ########
####################################

module "image_optimization" {
  providers = {
    aws = aws.global_region
  }

  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "${var.deployment_name}-image-optimization"
  description   = "${var.deployment_name} Image Optimization"

  lambda_at_edge               = true
  publish                      = true
  runtime                      = var.image_optimization_runtime
  memory_size                  = var.image_optimization_lambda_memory_size
  ephemeral_storage_size       = var.image_optimization_ephemeral_storage_size
  timeout                      = 30
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "${var.base_dir}deployments/image-optimization/source.zip"
  handler                = "index.handler"

  attach_network_policy             = false
  cloudwatch_logs_retention_in_days = var.image_optimization_logs_retention

  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
  }

  attach_policy_statements = true
  policy_statements = {
    s3_public_assets_bucket = {
      effect    = "Allow",
      actions   = ["s3:GetObject"],
      resources = ["${var.public_assets_bucket.s3_bucket_arn}/*"]
    }
  }
}

####################################
######### image_redirection ########
####################################

module "image_redirection" {
  providers = {
    aws = aws.global_region
  }

  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "${var.deployment_name}-image-redirection"
  description   = "${var.deployment_name} Image Redirection"

  lambda_at_edge               = true
  publish                      = true
  runtime                      = var.image_optimization_runtime
  memory_size                  = 128
  ephemeral_storage_size       = 512
  timeout                      = 5
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "${var.base_dir}deployments/image-redirection/source.zip"
  handler                = "index.handler"

  attach_network_policy             = false
  cloudwatch_logs_retention_in_days = var.image_optimization_logs_retention

  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
  }
}
