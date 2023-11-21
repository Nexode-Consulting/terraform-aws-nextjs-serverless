module "static-assets-hosting" {
  source = "./modules/static-assets-hosting"

  deployment_name = var.deployment_name
  base_dir        = var.base_dir
}

module "server-assets-hosting" {
  source = "./modules/server-assets-hosting"

  deployment_name = var.deployment_name
  base_dir        = var.base_dir
}

module "public-assets-hosting" {
  source = "./modules/public-assets-hosting"

  deployment_name = var.deployment_name
  base_dir        = var.base_dir
}

module "server-side-rendering" {
  source = "./modules/server-side-rendering"

  deployment_name = var.deployment_name
  base_dir        = var.base_dir

  lambda_memory_size = var.lambda_memory_size
  logs_retention     = var.logs_retention
  runtime            = var.runtime

  next_lambda_env_vars          = var.next_lambda_env_vars
  next_lambda_policy_statements = var.next_lambda_policy_statements
}

module "lambda-forwarder" {
  source = "./modules/lambda-forwarder"

  deployment_name = var.deployment_name
  base_dir        = var.base_dir

  runtime        = var.runtime
  logs_retention = var.logs_retention
}

module "image-optimization" {
  source = "./modules/image-optimization"

  deployment_name = var.deployment_name
  base_dir        = var.base_dir

  runtime                               = var.runtime
  logs_retention                        = var.logs_retention
  image_optimization_lambda_memory_size = var.image_optimization_lambda_memory_size

  public_assets_bucket = module.public-assets-hosting.public_assets_bucket
}

module "distribution" {
  source = "./modules/distribution"

  static_assets_bucket    = module.static-assets-hosting.static_assets_bucket
  static_assets_origin_id = module.static-assets-hosting.static_assets_oai

  public_assets_bucket        = module.public-assets-hosting.public_assets_bucket
  public_assets_bucket_region = var.region
  public_assets_origin_id     = module.public-assets-hosting.public_assets_oai

  server_asssets_bucket_domain = replace(module.server-assets-hosting.server_assets_bucket.s3_bucket_website_endpoint, "http://", "")
  dynamic_origin_domain_name   = module.server-side-rendering.api_gateway.default_apigatewayv2_stage_domain_name

  image_optimization_qualified_arn = module.image-optimization.image_optimization.lambda_function_qualified_arn
  image_redirection_qualified_arn  = module.image-optimization.image_redirection.lambda_function_qualified_arn

  lambda_forwarder_qualified_arn = module.lambda-forwarder.lambda_function_qualified_arn

  cloudfront_acm_certificate_arn = var.cloudfront_acm_certificate_arn
  cloudfront_aliases             = var.cloudfront_aliases
  cloudfront_price_class         = var.cloudfront_price_class
}
