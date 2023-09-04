# terraform-aws-nextjs-serverless

## Usage


use `build-serverless-next` package to build 

```
module "next_serverless" {
  source = "../../../" # replace with tf registry source & version

  deployment_name = var.deployment_name
  region = var.region
  global_region = var.global_region
  base_dir = var.base_dir
}
```