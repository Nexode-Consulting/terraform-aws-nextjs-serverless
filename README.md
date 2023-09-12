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

### Tests
This module is tested with terratest, which is essentially a Go test library with cloud and Terraform SDK integrations

To run the tests manually:
```bash
cd test/
go mod init <my_module>
go mod tidy
go test -v -timeout 30m //This makes sure that the entire infrastructure can be deployed, tested and destroyed, since Go packages time out at 10 minute mark. If you still timeout or your CI/CD tool is stuck, this is the first place to look.
```