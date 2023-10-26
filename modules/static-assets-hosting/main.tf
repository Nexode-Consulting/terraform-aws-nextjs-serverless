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

# CloudFront IAM policy
resource "aws_cloudfront_origin_access_identity" "static_assets_oai" {
  comment = "static_assets_origin"
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
