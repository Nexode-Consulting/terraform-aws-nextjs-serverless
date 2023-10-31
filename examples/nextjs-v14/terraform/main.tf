module "next_serverless" {
  source = "Nexode-Consulting/nextjs-serverless/aws"

  deployment_name = var.deployment_name
  region          = var.region
  base_dir        = "../"
}
