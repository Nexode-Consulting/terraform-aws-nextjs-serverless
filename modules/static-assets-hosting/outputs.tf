output "static_assets_bucket" {
  value = module.static_assets_bucket
}

output "static_assets_oai" {
  value = aws_cloudfront_origin_access_identity.static_assets_oai
}
