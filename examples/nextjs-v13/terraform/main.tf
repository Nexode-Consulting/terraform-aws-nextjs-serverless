module "next_serverless" {
  source = "../../../"

  deployment_name = var.deployment_name
  region          = var.region
  # global_region   = "us-east-1"
  base_dir        = var.base_dir

  cloudfront_acm_certificate_arn = module.next_cloudfront_certificate.acm_certificate_arn
  cloudfront_aliases             = [var.deployment_domain]
}

module "next_cloudfront_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = var.deployment_domain
  zone_id     = data.aws_route53_zone.hosted_zone.zone_id

  providers = {
    aws = aws.global_region
  }
}


data "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone
}

resource "aws_route53_record" "next_cloudfront_alias" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.deployment_domain
  type    = "A"

  allow_overwrite = true

  alias {
    name                   = module.next_serverless.cloudfront_url
    zone_id                = module.next_serverless.static-deploy.next_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}