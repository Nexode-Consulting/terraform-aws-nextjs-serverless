####################################
####### server_assets_bucket #######
####################################

locals {
  static_pages_file_path = "${var.base_dir}standalone/.next/server/pages"
}

module "server_assets_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket                   = "${var.deployment_name}-server-assets"
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  website = {
    index_document = "index.html"
  }
}

resource "aws_s3_object" "server_assets_files" {
  bucket   = module.server_assets_bucket.s3_bucket_id
  for_each = fileset(local.static_pages_file_path, "**/*.html")

  key          = "pages/${each.key}"
  source       = "${local.static_pages_file_path}/${each.key}"
  content_type = "charset=utf-8"
  etag         = filemd5("${local.static_pages_file_path}/${each.key}")

  cache_control = "public, max-age=600"
}

data "aws_iam_policy_document" "server_assets_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.server_assets_bucket.s3_bucket_arn}/*"]

    principals {
       type = "*"
       identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "server_assets_bucket_policy" {
  bucket = module.server_assets_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.server_assets_s3_policy.json
}
