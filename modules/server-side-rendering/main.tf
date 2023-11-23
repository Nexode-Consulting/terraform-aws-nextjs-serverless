####################################
########### next_lambda ############
####################################

locals {
  lambda_source_object_s3_key = "source-${filemd5("${var.base_dir}deployments/source.zip")}.zip"
  lambda_layer_object_s3_key  = "layer-${filemd5("${var.base_dir}deployments/layer.zip")}.zip"
}

module "next_lambda_zips_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket                   = "${var.deployment_name}-next-lambda-zips"
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "lambda_source_object" {
  bucket = module.next_lambda_zips_bucket.s3_bucket_id
  key    = local.lambda_source_object_s3_key
  source = "${var.base_dir}deployments/source.zip"
}

resource "aws_s3_object" "lambda_layer_object" {
  bucket = module.next_lambda_zips_bucket.s3_bucket_id
  key    = local.lambda_layer_object_s3_key
  source = "${var.base_dir}deployments/layer.zip"
}

resource "aws_lambda_layer_version" "server_layer" {
  depends_on = [aws_s3_object.lambda_layer_object]

  layer_name          = "${var.deployment_name}-layer"
  compatible_runtimes = [var.next_lambda_runtime]

  s3_bucket = module.next_lambda_zips_bucket.s3_bucket_id
  s3_key    = local.lambda_layer_object_s3_key
}

module "next_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "${var.deployment_name}-server-lambda"
  description   = "${var.deployment_name} Server"

  lambda_at_edge               = false
  runtime                      = var.next_lambda_runtime
  memory_size                  = var.next_lambda_memory_size
  ephemeral_storage_size       = var.next_lambda_ephemeral_storage_size
  timeout                      = 30
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package = false
  handler        = "server.handler"
  s3_existing_package = {
    bucket = module.next_lambda_zips_bucket.s3_bucket_id
    key    = local.lambda_source_object_s3_key
  }

  publish = true
  layers  = [aws_lambda_layer_version.server_layer.arn]

  cloudwatch_logs_retention_in_days = var.next_lambda_logs_retention

  attach_network_policy = false

  cors = {
    allow_credentials = true
    allow_origins     = ["*"] #TODO: update
    allow_methods     = ["*"]
  }

  environment_variables = var.next_lambda_env_vars

  allowed_triggers = {
    api_gateway = {
      action     = "lambda:InvokeFunction"
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }

  attach_policy_statements = length(keys(var.next_lambda_policy_statements)) != 0
  policy_statements        = var.next_lambda_policy_statements
}

####################################
########### api_gateway ############
####################################

module "api_gateway_cloudwatch_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "4.3.0"

  name              = "${var.deployment_name}-api-gateway-logs"
  retention_in_days = var.next_lambda_logs_retention
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name        = "${var.deployment_name}-api"
  description = "${var.deployment_name} API"

  create_vpc_link        = false
  create_api_domain_name = false

  default_stage_access_log_destination_arn = module.api_gateway_cloudwatch_log_group.cloudwatch_log_group_arn
  default_stage_access_log_format          = var.api_gateway_log_format

  cors_configuration = {
    allow_headers = ["*"]
    allow_origins = ["*"]
    allow_methods = ["*"]
  }

  integrations = {
    "$default" = {
      lambda_arn             = module.next_lambda.lambda_function_arn
      payload_format_version = "2.0"
    }
  }
}
