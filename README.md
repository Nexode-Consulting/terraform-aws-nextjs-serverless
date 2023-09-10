# terraform-aws-nextjs-serverless



## Setup

### Prepare Build 

Add the following dependencies to your package.json.

```json
package.json

    "scripts": {
        "dev": "next dev",
        "test": "jest",
        "build": "next build",
        "export": "next export",
        "build-serverless-next": "build-serverless-next",
        "start": "next start",
        "lint": "next lint"
    },
  "dependencies": {
    ...
    "build-serverless-next": "^0.0.7-alpha",
    "next": "^13.4.19",
    ...
  },
  "devDependencies": {
    ...
    "serverless": "^3.34.0",
    "serverless-esbuild": "^1.46.0",
    "serverless-http": "^3.2.0",
    ...
  }



```
### Create Terraform deployment

Ensure that the deployment name is unique since its used for creating s3 buckets.


```
module "next_serverless" {
  source  = "Nexode-Consulting/nextjs-serverless/aws"

  deployment_name = "nextjs-serverless" #needs to be unique since it will create an s3 bucket
  region = "eu-central-1"
  global_region = "us-east-1"
  base_dir = "./"
}
```

## Deployment
Build the Next.js Code and deploy
```bash
num run build-serverless-next
terraform apply
`