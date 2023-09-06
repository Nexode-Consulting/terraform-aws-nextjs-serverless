module "dynamic-deploy" {
  source = "./modules/dynamic-deploy"

  deployment_name                = var.deployment_name
  region                         = var.region
  base_dir                       = var.base_dir
}

module "static-deploy" {
  source = "./modules/static-deploy"

  deployment_name                = var.deployment_name
  base_dir                       = var.base_dir
  dynamic_origin_domain_name     = module.dynamic-deploy.api_gateway.default_apigatewayv2_stage_domain_name
  cloudfront_acm_certificate_arn = var.acm_certificate_arn
  cloudfront_aliases = var.cloudfront_aliases
}

provider "aws" {
  region = "{{region}}"
  profile = "{{profile}}"
}

terraform {
  backend "s3" {
    bucket         = "{{bucket}}"
    key            = "{{filename}}"
    region         = "{{region}}"
    profile        = "{{profile}}"
  }
}
