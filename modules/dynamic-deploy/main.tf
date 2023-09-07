resource "aws_lambda_layer_version" "server_layer" {
  filename   = "${var.base_dir}deployments/layer.zip"
  layer_name = "${var.deployment_name}-layer"

  source_code_hash    = filebase64sha256("${var.base_dir}deployments/layer.zip")
  compatible_runtimes = [var.runtime]
}

module "next_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.0"

  function_name = "${var.deployment_name}-server-lambda"
  description   = "${var.deployment_name} Server"

  lambda_at_edge               = true
  runtime                      = var.runtime
  memory_size                  = var.lambda_memory_size
  ephemeral_storage_size       = 512
  timeout                      = 30
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "${var.base_dir}deployments/source.zip"
  handler                = "server.handler"

  publish = true
  layers  = [aws_lambda_layer_version.server_layer.arn]

  cloudwatch_logs_retention_in_days = var.logs_retention

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
}

module "api_gateway_cloudwatch_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "4.3.0"

  name              = "${var.deployment_name}-api-gateway-logs"
  retention_in_days = var.logs_retention
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name        = "${var.deployment_name}-api"
  description = "${var.deployment_name} API"

  create_vpc_link        = false
  create_api_domain_name = false

  default_stage_access_log_destination_arn = module.api_gateway_cloudwatch_log_group.cloudwatch_log_group_arn
  default_stage_access_log_format          = "sourceIp: $context.identity.sourceIp, $context.domainName $context.requestTime \"$context.httpMethod $context.path $context.routeKey $context.protocol\" path: $context.customDomain.basePathMatched resp_status: $context.status integrationLatency: $context.integrationLatency responseLatency: $context.responseLatency requestId: $context.requestId Error: $context.integrationErrorMessage rawRequestPayloadSize: $input.body.size() rawRequestPayload: $input.body" # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging-variables.html

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