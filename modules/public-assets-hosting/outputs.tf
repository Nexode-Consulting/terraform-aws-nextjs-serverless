output "public_assets_bucket" {
  value = module.public_assets_bucket
}

output "public_assets_oai" {
  value = aws_cloudfront_origin_access_identity.public_assets_oai
}
