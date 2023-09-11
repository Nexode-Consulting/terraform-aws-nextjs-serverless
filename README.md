# terraform-aws-nextjs-serverless


## Setup

### Prepare 

Add the following dependencies to your package.json.

```json
package.json

{
  "scripts": {
    "build-serverless-next": "build-serverless-next",
    ...
  },
  "dependencies": {
    "build-serverless-next": "latest",
    "next": "^13",
    ...
  },
  ...
}
```
### Create Terraform deployment

Ensure that the deployment name is unique since its used for creating s3 buckets.


```
main.tf

module "next_serverless" {
  source  = "Nexode-Consulting/nextjs-serverless/aws"

  deployment_name = "nextjs-serverless" #needs to be unique since it will create an s3 bucket
  region = "eu-central-1"
  global_region = "us-east-1"
  base_dir = "./"
}
```

### Deployment
Build the Next.js Code and deploy
```bash
npm i
num run build-serverless-next
terraform apply
```