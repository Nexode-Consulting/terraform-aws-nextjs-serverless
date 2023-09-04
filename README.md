# terraform-aws-nextjs-serverless

## Usage


use `build-serverless-next` package to build 

```
module "next_serverless" {
  source = "../../../" # replace with tf registry source & version

  deployment_name = "nextjs-serverless"
  region = "eu-central-1"
  global_region = "us-east-1"
  base_dir = "./"
}
```