output "next_serverless" {
  value = module.next_serverless
}

output "cloudfront_url" {
  value = module.next_serverless.static-deploy.next_distribution.domain_name
}