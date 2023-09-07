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

  environment_variables = {
    NODE_ENV = "prod"
  }

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

  create_vpc_link = false

  create_api_domain_name = false
  # domain_name                 = local.server_domain
  # domain_name_certificate_arn = aws_acm_certificate.server_domain_cert.arn

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

# resource "aws_acm_certificate" "server_domain_cert" {
#   domain_name       = local.server_domain
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "server_domain_cert_validation" {
#   depends_on = [aws_route53_record.server_alias]

#   certificate_arn = aws_acm_certificate.server_domain_cert.arn
# }

# resource "aws_route53_record" "server_alias" {
#   depends_on = [aws_acm_certificate.server_domain_cert]

#   zone_id = data.aws_route53_zone.base_domain.zone_id
#   name    = local.server_domain
#   type    = "A"

#   alias {
#     name                   = module.api_gateway.apigatewayv2_domain_name_configuration[0].target_domain_name
#     zone_id                = module.api_gateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "server_domain" {
#   depends_on = [aws_acm_certificate.server_domain_cert]

#   for_each = {
#     for dvo in aws_acm_certificate.server_domain_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.base_domain.zone_id
# }