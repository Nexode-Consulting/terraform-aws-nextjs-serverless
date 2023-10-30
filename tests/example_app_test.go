package test

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

/**********************************************************/
/********* Test Next Serverless Module Example App ********/
/**********************************************************/
func TestNextServerlessModuleExampleApp(t *testing.T) {
	// The base directory for locating the example files and directories in the Next.js v13 example app.
	basePath := "../examples/nextjs-v13"

	// Configure the Terraform options for the test.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: basePath + "/terraform/",
		RetryableTerraformErrors: map[string]string{
			".*because it is a replicated function. Please see our documentation for Deleting Lambda@Edge Functions and Replicas.*": "Lambda was unable to delete Edge Function",
		},
		MaxRetries:         5,
		TimeBetweenRetries: 30 * time.Second,
		NoColor:            false,
		PlanFilePath:       "./tf-plan",
	})

	// When all tests are asserted, destroy all terraform resources
	defer terraform.Destroy(t, terraformOptions)

	// init terraform
	terraform.Init(t, terraformOptions)
	// validate terraform
	terraform.Validate(t, terraformOptions)
	// plan terraform resources
	terraform.Plan(t, terraformOptions)
	// deploy all terraform resources
	terraform.Apply(t, terraformOptions)

	// export the terraform output
	output := terraform.OutputJson(t, terraformOptions, "next_serverless")

	// read the distribution URL
	distributionURL := readTerraformOutputs(output)

	// assert the test cases
	redirectsImages(t, distributionURL, basePath)
	optimizesImages(t, distributionURL, basePath)
	distributesStaticAssets(t, distributionURL, basePath)
	distributesPublicAssets(t, distributionURL)
	rendersServerSide(t, distributionURL)
}

/**********************************************************/
/*********************** Test Cases ***********************/
/**********************************************************/

// Tests if the redireted image returns a status code of 200 and has a content type of "image/".
func redirectsImages(t *testing.T, distributionURL string, basePath string) {
	// /_next/image?url=…. :
	// * Status 200
	// * Content type: image/…
	filenames := getFilenamesFromDirectory(basePath + "/public")
	status, contentType := customHttpGet(distributionURL + "/_next/image?url=/" + filenames[0] + "&w=256&q=75")
	assert.Equal(t, status, 200)
	assert.Contains(t, contentType, "image/")
}

// Tests the status and content type of an optimized image fetched from the distribution.
func optimizesImages(t *testing.T, distributionURL string, basePath string) {
	// /_next/image/redirection_url/… (redirection URL):
	// * Status 200
	// * Content type: image/…
	filenames := getFilenamesFromDirectory(basePath + "/public")
	status, contentType := customHttpGet(distributionURL + "/_next/image/" + "256/75/webp/" + filenames[0])
	assert.Equal(t, status, 200)
	assert.Contains(t, contentType, "image/")
}

// Tests the distribution of static assets by making HTTP requests the distribution and asserting the expected status code and content type.
func distributesStaticAssets(t *testing.T, distributionURL string, basePath string) {
	// /_next/static/css/(a static file from build):
	// * Status 200
	// * Content type: text/css
	filenames := getFilenamesFromDirectory(basePath + "/standalone/static/_next/static/css")
	status, contentType := customHttpGet(distributionURL + "/_next/static/css/" + filenames[0])
	assert.Equal(t, status, 200)
	assert.Equal(t, contentType, "text/css; charset=utf-8")

	// /_next/static/css/(a static file from build):
	// * Status 200
	// * Content type: application/javascript
	filenames = getFilenamesFromDirectory(basePath + "/standalone/static/_next/static/chunks")
	status, contentType = customHttpGet(distributionURL + "/_next/static/chunks/" + filenames[0])
	assert.Equal(t, status, 200)
	assert.Equal(t, contentType, "application/javascript")
}

// Tests the status and content type of an image file retrieved from the distribution.
func distributesPublicAssets(t *testing.T, distributionURL string) {
	// /assets/(am image from public/.. folder):
	// * Status 200
	// * Content type: image/…
	status, contentType := customHttpGet(distributionURL + "/assets/vercel.svg")
	assert.Equal(t, status, 200)
	assert.Contains(t, contentType, "image/")
}

// Tests if the server-side rendering (SSR) page is rendered correctly by checking the HTTP status code and the presence of a specific string in the response body.
func rendersServerSide(t *testing.T, distributionURL string) {
	// /(the ssr page):
	// * Status 200
	code, body := http_helper.HttpGet(t, distributionURL, nil)
	assert.Equal(t, code, 200)
	assert.Contains(t, body, "Powered by")
}

/**********************************************************/
/******************** Helper Functions ********************/
/**********************************************************/

// Reads a Terraform output, extracts the CloudFront URL, and returns the distribution URL.
func readTerraformOutputs(output string) string {
	var data map[string]interface{}
	json.Unmarshal([]byte(output), &data)

	cloudfrontURL := data["cloudfront_url"].(string)
	// next_distribution_arn := data["distribution"].(map[string]interface{})["next_distribution"].(map[string]interface{})["arn"].(string)

	distributionURL := "https://" + cloudfrontURL
	fmt.Println("Distribution URL:", distributionURL)

	return distributionURL
}

// Sends a GET request to the distribution and returns the status code and content type of the response.
func customHttpGet(url string) (int, string) {
	response, err := http.Get(url)
	if err != nil {
		return 0, ""
	}
	defer response.Body.Close()

	contentType := response.Header.Get("Content-Type")
	status := response.StatusCode

	return status, contentType
}

// Takes a directory path as input and returns a list of filenames in that directory.
func getFilenamesFromDirectory(path string) []string {
	dir, _ := os.Open(path)
	defer dir.Close()

	files, _ := dir.Readdir(-1)

	var filenames []string
	for _, file := range files {
		if !file.IsDir() {
			filenames = append(filenames, file.Name())
		}
	}

	return filenames
}
