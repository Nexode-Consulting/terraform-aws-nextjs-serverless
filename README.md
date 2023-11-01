# Terraform Next.js module for AWS

Zero-Config Terraform Module to deploy Next.js Apps on AWS using Serverless solutions


## Usage

### Prepare 

Add the following dependencies & script to your _package.json_ file

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

Add the `output: "standalone"` option to the _next.config.js_ file

```json
next.config.js

const nextConfig = {
  ...
  "output": "standalone",
  ...
}

module.exports = nextConfig

```


### Create Terraform deployment

Ensure that the deployment name is unique since its used for creating s3 buckets.

```
main.tf

provider "aws" {
  region = "eu-central-1" #customize your region
}

provider "aws" {
  alias  = "global_region"
  region = "us-east-1" #must be us-east-1
}

module "next_serverless" {
  source  = "Nexode-Consulting/nextjs-serverless/aws"

  deployment_name = "nextjs-serverless" #needs to be unique since it will create an s3 bucket
  region          = "eu-central-1" #customize your region
  base_dir        = "./"
}

output "next_serverless" {
  value = module.next_serverless
}
```

### Deployment
Build the Next.js Code and deploy
```bash
npm i build-serverless-next
npm run build-serverless-next

terraform init
terraform apply
```


## Architecture

### Module 
![Module ](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/blob/main/visuals/module.webp?raw=true)

### Distribution 
![Distribution ](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/blob/main/visuals/distribution.webp?raw=true)

### Cache 
![Cache ](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/blob/main/visuals/cache.webp?raw=true)


## Examples

* [Next.js v13](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/tree/main/examples/nextjs-v13)
  Complete example with SSR, API, static pages, image optimization & custom domain


## Known Issues

* The `build-serverless-next` _package's version_ must match the `next_serverless` _module's version_
* The `app/` folder must be in the root directory (ex. not in the `src/` directory)
* When destroying the `next_serverless` module, Lambda@Edge function need at least 15mins to be destroy, since they're [replicated functions](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html)


## Contributing

Feel free to improve this module. \
Our [contributing guidelines](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/tree/main/CONTRIBUTING.md) will help you get started.


## About

This module is maintained by [Nexode Consulting](https://nexode.de/en/). \
_We help companies develop and operate enterprise-grade software with startup momentum._
