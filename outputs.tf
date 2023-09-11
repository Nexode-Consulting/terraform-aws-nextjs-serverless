output "dynamic-deploy" {
  value = module.dynamic-deploy
}

output "static-deploy" {
  value = module.static-deploy
}

output "cloudfront_url" {
  value = module.static-deploy.next_distribution.domain_name
}