module "static_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "${local.repo}-static"
  acl    = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "static_static_files" {
  source  = "hashicorp/dir/template"
  version = "1.0.2"

  base_dir = "../standalone/.next"
}

resource "aws_s3_object" "static_files" {
  bucket   = module.static_bucket.s3_bucket_id
  for_each = module.static_static_files.files

  key          = each.key
  source       = each.value.source_path
  content      = each.value.content
  content_type = each.value.content_type
  etag         = each.value.digests.md5
}

resource "aws_cloudfront_origin_access_identity" "static_oai" {}

resource "aws_cloudfront_distribution" "static_distribution" {
  origin {
    domain_name = module.static_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.static_oai.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  # aliases             = [local.static_domain]
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_identity.static_oai.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/index.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_cloudfront_origin_access_identity.static_oai.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
    # acm_certificate_arn      = module.static_cloudfront_certificate.acm_certificate_arn
    # minimum_protocol_version = "TLSv1.2_2021"
    # ssl_support_method       = "sni-only"
  }

  # custom_error_response {
  #   error_caching_min_ttl = 300
  #   error_code            = 403
  #   response_code         = 200
  #   response_page_path    = "/index.html"
  # }

  # custom_error_response {
  #   error_caching_min_ttl = 300
  #   error_code            = 404
  #   response_code         = 200
  #   response_page_path    = "/index.html"
  # }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

data "aws_iam_policy_document" "static_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.static_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_bucket_policy" {
  bucket = module.static_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.static_s3_policy.json
}

# module "static_cloudfront_certificate" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "4.3.2"

#   domain_name = local.static_domain
#   zone_id     = data.aws_route53_zone.base_domain.zone_id

#   providers = {
#     aws = aws.global_region
#   }
# }

# resource "aws_route53_record" "static_domain" {
#   depends_on = [module.static_cloudfront_certificate]

#   for_each = {
#     for dvo in module.static_cloudfront_certificate.acm_certificate_domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.base_domain.zone_id
# }

# resource "aws_route53_record" "static_alias" {
#   zone_id = data.aws_route53_zone.base_domain.zone_id
#   name    = local.static_domain
#   type    = "A"

#   allow_overwrite = true

#   alias {
#     name                   = aws_cloudfront_distribution.static_distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.static_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
