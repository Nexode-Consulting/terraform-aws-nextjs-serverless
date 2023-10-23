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
  version = "6.0.1"

  function_name = "${var.deployment_name}-image-optimization"
  description   = "${var.deployment_name} Image Optimization"

  lambda_at_edge               = true
  publish                      = true
  runtime                      = var.runtime
  memory_size                  = 10240
  ephemeral_storage_size       = 512
  timeout                      = 30
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "${var.base_dir}deployments/image-optimization/source.zip"
  handler                = "index.handler"

  attach_network_policy             = false
  cloudwatch_logs_retention_in_days = var.logs_retention

  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
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
  version = "6.0.1"

  function_name = "${var.deployment_name}-image-redirection"
  description   = "${var.deployment_name} Image Redirection"

  lambda_at_edge               = true
  publish                      = true
  runtime                      = var.runtime
  memory_size                  = 128
  ephemeral_storage_size       = 512
  timeout                      = 5
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "${var.base_dir}deployments/image-redirection/source.zip"
  handler                = "index.handler"

  attach_network_policy             = false
  cloudwatch_logs_retention_in_days = var.logs_retention

  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
  }
}
