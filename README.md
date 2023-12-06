# Terraform Next.js module for AWS

Zero-Config Terraform Module to deploy Next.js Apps on AWS using Serverless solutions


## Usage

### Dependencies

* Node: 16+
* Terraform: 1.6.3+
* bash
* zip


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

Check it on [Terraform Registry](https://registry.terraform.io/modules/Nexode-Consulting/nextjs-serverless) for more details.

_Ensure that the deployment name is unique since its used for creating s3 buckets._

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

  deployment_name = "nextjs-serverless" #needs to be unique since it will create s3 buckets
  region          = "eu-central-1" #customize your region
  base_dir        = "./" #The base directory of the next.js app
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
* Using the `<img>` tag or `background-image` css property might face issues rendering images, please use the build-in `<Image />` [component](https://nextjs.org/docs/pages/api-reference/components/image). Meanwhile, please move all images, icons, etc... in the `public` folder.
* In some rare cases, some modules can not be imported by next_lambda (for unknown reasons). To solve this issue use `build-serverless-next --copyAllPackages` to copy all the packages or `build-serverless-next --packages-to-copy=package_1,package_2,package_3` to copy specific packages only


## Contributing

Feel free to improve this module.
<br>
Our [contributing guidelines](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/tree/main/CONTRIBUTING.md) will help you get started.


## About

This module is maintained by [Nexode Consulting](https://nexode.de/en/).
<br>
_We help companies develop and operate enterprise-grade software with startup momentum._


## License
Apache-2.0 - see [LICENSE](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/tree/main/LICENSE) for details.
