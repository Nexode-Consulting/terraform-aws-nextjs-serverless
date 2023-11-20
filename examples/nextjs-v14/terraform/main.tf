module "next_serverless" {
  source = "../../../"
  # source  = "Nexode-Consulting/nextjs-serverless/aws"
  # version = "0.2.7"

  deployment_name = var.deployment_name
  region          = var.region
  base_dir        = "../"
  runtime         = "nodejs18.x"
}
