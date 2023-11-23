module "static-assets-hosting" {
  source = "./modules/static-assets-hosting"

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

  next_lambda_memory_size            = var.next_lambda_memory_size
  next_lambda_logs_retention         = var.next_lambda_logs_retention
  next_lambda_runtime                = var.next_lambda_runtime
  next_lambda_ephemeral_storage_size = var.next_lambda_ephemeral_storage_size

  next_lambda_env_vars          = var.next_lambda_env_vars
  next_lambda_policy_statements = var.next_lambda_policy_statements

  api_gateway_log_format = var.api_gateway_log_format
}

module "image-optimization" {
  source = "./modules/image-optimization"

  deployment_name = var.deployment_name
  base_dir        = var.base_dir

  image_optimization_runtime                = var.image_optimization_runtime
  image_optimization_logs_retention         = var.image_optimization_logs_retention
  image_optimization_lambda_memory_size     = var.image_optimization_lambda_memory_size
  image_optimization_ephemeral_storage_size = var.image_optimization_ephemeral_storage_size

  public_assets_bucket = module.public-assets-hosting.public_assets_bucket
}

module "distribution" {
  source = "./modules/distribution"

  static_assets_bucket    = module.static-assets-hosting.static_assets_bucket
  static_assets_origin_id = module.static-assets-hosting.static_assets_oai

  public_assets_bucket        = module.public-assets-hosting.public_assets_bucket
  public_assets_bucket_region = var.region
  public_assets_origin_id     = module.public-assets-hosting.public_assets_oai

  dynamic_origin_domain_name = module.server-side-rendering.api_gateway.default_apigatewayv2_stage_domain_name

  image_optimization_qualified_arn = module.image-optimization.image_optimization.lambda_function_qualified_arn
  image_redirection_qualified_arn  = module.image-optimization.image_redirection.lambda_function_qualified_arn

  cloudfront_acm_certificate_arn = var.cloudfront_acm_certificate_arn
  cloudfront_aliases             = var.cloudfront_aliases
  cloudfront_price_class         = var.cloudfront_price_class

  cloudfront_cache_default_ttl = var.cloudfront_cache_default_ttl
  cloudfront_cache_max_ttl     = var.cloudfront_cache_max_ttl
  cloudfront_cache_min_ttl     = var.cloudfront_cache_min_ttl
}
