output "next_lambda" {
  value = module.next_lambda
}

output "image_optimization" {
  value = module.image_optimization
}

output "image_redirection" {
  value = module.image_redirection
}

output "api_gateway" {
  value = module.api_gateway
}

output "api_gateway_cloudwatch_log_group" {
  value = module.api_gateway_cloudwatch_log_group
}

output "aws_lambda_layer_version" {
  value = aws_lambda_layer_version.server_layer
}
