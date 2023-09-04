module "dynamic-deploy" {
  source = "./modules/dynamic-deploy"

  deployment_name = var.deployment_name
  region          = var.region
  base_dir        = var.base_dir
}

module "static-deploy" {
  source = "./modules/static-deploy"

  deployment_name            = var.deployment_name
  base_dir                   = var.base_dir
  dynamic_origin_domain_name = module.dynamic-deploy.api_gateway.default_apigatewayv2_stage_domain_name
}
