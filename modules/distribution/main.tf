####################################
############ lambdas_oai ###########
####################################

resource "aws_cloudfront_origin_access_identity" "dynamic_assets_oai" {
  comment = "dynamic_assets_origin"
}

resource "aws_cloudfront_origin_access_identity" "image_redirection_oai" {
  comment = "image_redirection_origin"
}

resource "aws_cloudfront_origin_access_identity" "image_optimization_oai" {
  comment = "image_optimization_origin"
}

####################################
########### distribution ###########
####################################

resource "aws_cloudfront_distribution" "next_distribution" {
  origin {
    domain_name = var.public_assets_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = var.public_assets_origin_id.id

    s3_origin_config {
      origin_access_identity = var.public_assets_origin_id.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = var.static_assets_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = var.static_assets_origin_id.id

    s3_origin_config {
      origin_access_identity = var.static_assets_origin_id.cloudfront_access_identity_path
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

  origin {
    domain_name = "example.com"
    origin_id   = aws_cloudfront_origin_access_identity.image_redirection_oai.id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = "example.com"
    origin_id   = aws_cloudfront_origin_access_identity.image_optimization_oai.id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "S3-Region"
      value = var.public_assets_bucket_region
    }

    custom_header {
      name  = "Public-Assets-Bucket"
      value = var.public_assets_bucket.s3_bucket_id
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases             = var.cloudfront_aliases
  default_root_object = null

  ordered_cache_behavior {
    path_pattern     = "/_next/image/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_cloudfront_origin_access_identity.image_optimization_oai.id

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = var.image_optimization_qualified_arn
    }

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    default_ttl = var.cloudfront_cache_default_ttl
    max_ttl     = var.cloudfront_cache_max_ttl
    min_ttl     = var.cloudfront_cache_min_ttl

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/image*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_cloudfront_origin_access_identity.image_redirection_oai.id

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = var.image_redirection_qualified_arn
      include_body = true
    }

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    default_ttl = var.cloudfront_cache_default_ttl
    max_ttl     = var.cloudfront_cache_max_ttl
    min_ttl     = var.cloudfront_cache_min_ttl

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/static/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = var.static_assets_origin_id.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    default_ttl = var.cloudfront_cache_default_ttl
    max_ttl     = var.cloudfront_cache_max_ttl
    min_ttl     = var.cloudfront_cache_min_ttl

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = var.public_assets_origin_id.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    default_ttl = var.cloudfront_cache_default_ttl
    max_ttl     = var.cloudfront_cache_max_ttl
    min_ttl     = var.cloudfront_cache_min_ttl

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

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

  price_class = var.cloudfront_price_class

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_acm_certificate_arn == null
    acm_certificate_arn            = var.cloudfront_acm_certificate_arn
    minimum_protocol_version       = var.cloudfront_acm_certificate_arn == null ? "TLSv1" : "TLSv1.2_2021"
    ssl_support_method             = var.cloudfront_acm_certificate_arn != null ? "sni-only" : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_monitoring_subscription" "next_distribution_monitoring" {
  distribution_id = aws_cloudfront_distribution.next_distribution.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}
