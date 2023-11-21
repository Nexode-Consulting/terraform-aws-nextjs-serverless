provider "aws" {
  alias  = "global_region"
  region = "us-east-1"
}

module "lambda_forwarder" {
  providers = {
    aws = aws.global_region
  }

  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.1"

  function_name = "${var.deployment_name}-lambda-forwarder"
  description   = "${var.deployment_name} Lambda Forwarder"

  lambda_at_edge               = true
  publish                      = true
  runtime                      = "python3.10"
  memory_size                  = 128
  ephemeral_storage_size       = 512
  timeout                      = 10
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "${var.base_dir}deployments/lambda-forwarder/source.zip"
  handler                = "main.lambda_handler"

  attach_network_policy             = false
  cloudwatch_logs_retention_in_days = var.logs_retention

  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
  }
}