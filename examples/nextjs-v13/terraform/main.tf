module "next_serverless" {
  source = "../../../"

  deployment_name = var.deployment_name
  region          = var.region
  global_region   = var.global_region
  base_dir        = var.base_dir
}