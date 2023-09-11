package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

// An example of how to test the Terraform module using Terratest.
func TestTerraformAwsS3Example(t *testing.T) {
	t.Parallel()

	awsRegion := "eu-central-1"

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",
		Reconfigure:  true,
		VarFiles:     []string{"config/dev.tfvars"},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Cloudfront tests:
	// 1) Route53 records: Make sure that there is a CNAME record between the cloudfront alias and the cloudfront URL
	// 2) Call different paths, one for assets/public, one for _next/static and make sure that you're hitting the public and static buckets, respectively
	// 3) Invoke the lambda function, make sure that you get the proper response
	dynamicRes, _ := terraform.OutputMapOfObjectsE(t, terraformOptions, "dynamic-deploy")
	staticRes, _ := terraform.OutputMapOfObjectsE(t, terraformOptions, "static-deploy")
	resultDyn := gjson.Parse(fmt.Sprint(dynamicRes))
	resultStat := gjson.Parse(fmt.Sprint(staticRes))

	// Domain check
	customDomain := resultStat.Get("next_distribution.aliases.0")
	actualCustomDomain := "nextjs-teufel.mo.sandboxes.nexode-consulting.net"
	assert.Contains(t, customDomain, actualCustomDomain)

	// Certificate used should be in the us-east-1 region
	certificateARN := resultStat.Get("next_distribution.viewer_certificate.0.acm_certificate_arn")
	actualCertificateARN := aws.GetAcmCertificateArn(t, "us-east-1", actualCustomDomain)
	assert.Equal(t, certificateARN, actualCertificateARN)

	// Cloudfront URL should be used in the Route53 record set so that the alias works, and the requests are forwarded to CloudFront
	// cloudfrontURL := resultStat.Get("next_distribution.domain_name")
	// actualCloudfrontURL := "some string" //TODO get this from a DNS lookup
	// assert.Equal(t, cloudfrontURL, actualCloudfrontURL)

	// API Gateway should be used as the default / path to the CloudFront entry.
	actualApigatewayURL := resultDyn.Get("api_gateway.apigatewayv2_api_api_endpoint")
	apigatewayURL := resultStat.Get("next_distribution.origin.0.domain_name")
	assert.Equal(t, apigatewayURL, actualApigatewayURL)

	// Let's not forget to use the Public Assets bucket in the CloudFront routes, which should correspond with the /assets/public path
	publicAssetsBucketURL := resultStat.Get("next_distribution.origin.1.domain_name")
	actualPublicAssetsBucketURL := resultStat.Get("public_assets_bucket.s3_bucket_bucket_regional_domain_name")
	assert.Equal(t, publicAssetsBucketURL, actualPublicAssetsBucketURL)

	// Let's not forget to use the Static Assets bucket in the CloudFront routes, which should correspond with the /_next/static path
	staticAssetsBucketURL := resultStat.Get("next_distribution.origin.2.domain_name")
	actualStaticAssetsBucketURL := resultStat.Get("static_assets_bucket.s3_bucket_bucket_regional_domain_name")
	assert.Equal(t, staticAssetsBucketURL, actualStaticAssetsBucketURL)

	// Let's call the function once TODO
	functionName := resultDyn.Get("next_lambda.lambda_function_name").String()
	response := aws.InvokeFunction(t, awsRegion, functionName, ExampleFunctionPayload{ShouldFail: false, Echo: "hi!"})
	print(response)
	// assert.Equal(t, `"hi!"`, string(response))
	// assert.Contains(t, string(functionError.Payload), "Failed to handle")

	// Let's make a call to the /assets/public path TODO

	// Let's make a call to the /_next/static path TODO
}

type ExampleFunctionPayload struct {
	Echo       string
	ShouldFail bool
}
