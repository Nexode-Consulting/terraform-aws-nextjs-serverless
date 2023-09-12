package test

import (
	"crypto/tls"
	"fmt"
	"strings"
	"testing"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func TestTerraformCloudFrontServerlessNextJS(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/nextjs-v13/terraform/",
		Reconfigure:  true,
		// The path of the var file in relation to TerraformDir
		VarFiles: []string{"../../../config/terratest.tfvars"},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	serverlessModule := terraform.OutputJson(t, terraformOptions, "next_serverless")
	resultStat := gjson.Parse(fmt.Sprint(serverlessModule))
	aliasURL := resultStat.Get("static-deploy.next_distribution.aliases.0").String()
	tlsConfig := tls.Config{}

	// Integration tests
	// 1) Call to the / path: This should hit the lambda and return 200, along with the text next.js
	code1, body := http_helper.HttpGet(t, "https://"+aliasURL, &tlsConfig)
	assert.Equal(t, code1, 200)
	assert.Contains(t, strings.ToLower(body), "next.js")

	// 2) Call to the public bucket: This object should be returned with 200
	code2, _ := http_helper.HttpGet(t, "https://"+aliasURL+"/assets/vercel.svg", &tlsConfig)
	assert.Equal(t, code2, 200)

	// 3) Call to the static bucket: This object should be returned with 200
	code3, _ := http_helper.HttpGet(t, "https://"+aliasURL+"/_next/static/css/6aaa4fa06f977cba.css", &tlsConfig)
	assert.Equal(t, code3, 200)

	// time.Sleep(20 * time.Second)
}
