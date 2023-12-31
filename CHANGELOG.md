# Changelog

All notable changes to this project will be documented in this file.

<!-- ## [Unreleased] -->


## [v0.2.20] - 2023-12-13

* Fix broken SPA feature [#47](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/47)


## [v0.2.19] - 2023-12-06

* Option to copy all packages directly into the next_lambda [#46](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/46)


## [v0.2.18] - 2023-12-04

* Support remote images [#44](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/44)


## [v0.2.17] - 2023-11-23

Updates:
* add & update customization options of the module through terraform variables [#42](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/42)
* store next_lambda source zip in s3 [#38](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/38)
* expand image examples [#39](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/39)
* update cache diagram [#37](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/37)
* update dependencies versions to latest [#43](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/43)

**Breaking Changes**
* `lambda_memory_size` is replaced by `next_lambda_memory_size` & `image_optimization_lambda_memory_size`
* `runtime` is replaced by `next_lambda_runtime` & `image_optimization_runtime`
* `logs_retention` is replaced by `next_lambda_logs_retention` & `image_optimization_logs_retention`


## [v0.2.16] - 2023-11-20

* Bugfix: next_lambda_layer was not updating [#35](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/35)
* `build-serverless-next`: Option to copy some packages directly into the next_lambda, since in some rare cases import from the layer fails [#36](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/36)


## [v0.2.13] - 2023-11-16

* Add docs about dependancies [#33](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/33)
* Bugfix: Image redirection had issues with deeply nested files [#34](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/34)


## [v0.2.11] - 2023-11-03

* Add SSR example [#26](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/26)
* Add CHANGELOG docs [#30](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/30)
* Fix: Set a version for every package used by `build-serverless-next` [#31](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/31)


## [v0.2.10] - 2023-11-01

**Add License**

* Add License for the module [#23](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/23)
* Add License for the modulethe packages [#24](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/24)


## [v0.2.8] - 2023-11-01

**Intialize Terraform Tests**

* Add terraform tests using TerraTest [#17](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/17)
* Improve visualizations [#18](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/18)
* Improved Documentation [#22](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/22)


## [v0.2.6] - 2023-10-26

* Improve visualizations [#16](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/16)


## [v0.2.5] - 2023-10-26

* Add visualization diagrams for the module and the distribution


## [v0.2.4] - 2023-10-23

* Fix: S3 cross-region access for Image Optimization on Lambda@Edge


## [v0.2.1] - 2023-10-23

**Improve Image Optimization**

* Image Optimization: fetch images from S3, instead of public S3 URL


## [v0.2.0] - 2023-10-23

**Restructure Modules** [#15](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/15)

* Restructure the Modules' structure to support future plans
* Release a functional version of Image Optimization feature


## [v0.1.1] - 2023-10-20

* Fix: lambda@edge source code read


## [v0.1.0] - 2023-10-20

**Intial Image Optimization Feature Releaze**

* Serve public assets using Lambda@Edge to optimize size, file type, quality


## [v0.0.7] - 2023-09-12

* Fix cloudwatch log group name mis-configuration [#13](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/13)


## [v0.0.6] - 2023-09-12

* Add next_lambda_policy_statements option [#11](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/11)


## [v0.0.4] - 2023-09-12

* Change: Store next_lambda layer in S3, instead of uploading it directly


## [v0.0.2] - 2023-09-07

* Add the custom domain option for the CloudFront distribution [#5](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/5)
* Add the option for next_lambda env vars [#5](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/5)
* Fix BucketACL issue [#5](https://github.com/Nexode-Consulting/terraform-aws-nextjs-serverless/pull/5)


## [v0.0.1] - 2023-09-04

**Initial Release**

* Serve next.js app with AWS Lambda & API Gateway
* Serve static assets with CloudFront & S3
* Serve public assets with CloudFront & S3
