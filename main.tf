module "dynamic-deploy" {
  source = "./modules/dynamic-deploy"

  deployment_name               = var.deployment_name
  region                        = var.region
  base_dir                      = var.base_dir
  next_lambda_env_vars          = var.next_lambda_env_vars
  next_lambda_policy_statements = var.next_lambda_policy_statements
}

module "static-deploy" {
  source = "./modules/static-deploy"

  deployment_name                  = var.deployment_name
  base_dir                         = var.base_dir
  dynamic_origin_domain_name       = module.dynamic-deploy.api_gateway.default_apigatewayv2_stage_domain_name
  cloudfront_acm_certificate_arn   = var.cloudfront_acm_certificate_arn
  cloudfront_aliases               = var.cloudfront_aliases
  cloudfront_price_class           = var.cloudfront_price_class
  image_optimization_qualified_arn = module.dynamic-deploy.image_optimization.lambda_function_qualified_arn
  image_redirection_qualified_arn  = module.dynamic-deploy.image_redirection.lambda_function_qualified_arn
}
