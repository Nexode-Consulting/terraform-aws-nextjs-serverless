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

module "public_assets_static_files" {
  source  = "hashicorp/dir/template"
  version = "1.0.2"

  base_dir = "${var.base_dir}public"
}

resource "aws_s3_object" "public_assets_files" {
  bucket   = module.public_assets_bucket.s3_bucket_id
  for_each = module.public_assets_static_files.files

  key          = "assets/${each.key}" # necessary prefix
  source       = each.value.source_path
  content      = each.value.content
  content_type = each.value.content_type
  etag         = each.value.digests.md5
}

# CloudFront IAM policy
resource "aws_cloudfront_origin_access_identity" "public_assets_oai" {
  comment = "public_assets_origin"
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
