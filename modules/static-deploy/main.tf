####################################
####### public_assets_bucket #######
####################################

module "public_assets_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket                   = "${var.deployment_name}-public-assets"
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "public_assets_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.public_assets_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.public_assets_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "public_assets_bucket_policy" {
  bucket = module.public_assets_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.public_assets_s3_policy.json
}

module "public_assets_static_files" {
  source  = "hashicorp/dir/template"
  version = "1.0.2"

  base_dir = "${var.base_dir}standalone/public"
}

resource "aws_s3_object" "public_assets_files" {
  bucket   = module.public_assets_bucket.s3_bucket_id
  for_each = module.public_assets_static_files.files

  key          = each.key
  source       = each.value.source_path
  content      = each.value.content
  content_type = each.value.content_type
  etag         = each.value.digests.md5
}

resource "aws_cloudfront_origin_access_identity" "public_assets_oai" {
  comment = "public_assets_origin"
}

####################################
####### static_assets_bucket #######
####################################

module "static_assets_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket                   = "${var.deployment_name}-static-assets"
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "static_assets_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.static_assets_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static_assets_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_assets_bucket_policy" {
  bucket = module.static_assets_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.static_assets_s3_policy.json
}

module "static_assets_static_files" {
  source  = "hashicorp/dir/template"
  version = "1.0.2"

  base_dir = "${var.base_dir}standalone/static"
}

resource "aws_s3_object" "static_assets_files" {
  bucket   = module.static_assets_bucket.s3_bucket_id
  for_each = module.static_assets_static_files.files

  key          = each.key
  source       = each.value.source_path
  content      = each.value.content
  content_type = each.value.content_type
  etag         = each.value.digests.md5
}

resource "aws_cloudfront_origin_access_identity" "static_assets_oai" {
  comment = "static_assets_origin"
}

####################################
########## dynamic_assets ##########
####################################

resource "aws_cloudfront_origin_access_identity" "dynamic_assets_oai" {
  comment = "dynamic_assets_origin"
}

####################################
########### distribution ###########
####################################

resource "aws_cloudfront_distribution" "next_distribution" {
  origin {
    domain_name = module.public_assets_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.public_assets_oai.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.public_assets_oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = module.static_assets_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.static_assets_oai.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_assets_oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = var.dynamic_origin_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.dynamic_assets_oai.id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases             = var.cloudfront_aliases
  default_root_object = null

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_identity.dynamic_assets_oai.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_cloudfront_origin_access_identity.static_assets_oai.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_cloudfront_origin_access_identity.public_assets_oai.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_acm_certificate_arn == null
    acm_certificate_arn            = var.cloudfront_acm_certificate_arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = var.cloudfront_acm_certificate_arn != null ? "sni-only" : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
