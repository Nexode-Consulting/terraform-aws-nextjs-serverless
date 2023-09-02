resource "aws_lambda_layer_version" "server_layer" {
  filename   = "../deployments/layer.zip"
  layer_name = "${local.repo}-layer"

  source_code_hash    = filebase64sha256("../deployments/layer.zip")
  compatible_runtimes = [var.runtime]
}

module "next_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.0"

  function_name = "${local.repo}-server-lambda"
  description   = "${local.repo} Server"

  lambda_at_edge               = true
  runtime                      = var.runtime
  memory_size                  = var.lambda_memory_size
  ephemeral_storage_size       = 512
  timeout                      = 30
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "../deployments/source.zip"
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

  environment_variables = {
    NODE_ENV = var.enviroment
  }

  allowed_triggers = {
    api_gateway = {
      action     = "lambda:InvokeFunction"
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }
}
