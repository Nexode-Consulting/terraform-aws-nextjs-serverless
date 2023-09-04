output "public_assets_bucket" {
  value = module.public_assets_bucket
}

output "static_assets_bucket" {
  value = module.static_assets_bucket
}

output "next_distribution" {
  value = aws_cloudfront_distribution.next_distribution
}
