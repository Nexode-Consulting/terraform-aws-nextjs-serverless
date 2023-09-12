package test

import (
	"crypto/tls"
	"fmt"
	"os"
	"strings"
	"testing"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func TestTerraformCloudFrontServerlessNextJS(t *testing.T) {
	t.Parallel()

	terraformDir := "../examples/nextjs-v13/terraform/"
	varFiles := []string{"../../../config/terratest.tfvars"}
	// Normally, a terraform options loading would be cleaner here,
	// but there is a bug in the library implementation that resets the saved location of the terraform output file
	// Thus it's safer to use terraform base dir and var file variables throughout this test.

	// This is the cleanup part
	defer test_structure.RunTestStage(t, "cleanupNextJSCloudFront", func() {
		undeployTerraform(t, terraformDir, varFiles)
	})

	// This is the setup
	test_structure.RunTestStage(t, "initializeNextJSCloudFront", func() {
		deployTerraform(t, terraformDir, varFiles)
	})

	// To get the URL, we need to parse the terraform output
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
		Reconfigure:  true,
		VarFiles:     varFiles,
	})
	serverlessModule := terraform.OutputJson(t, terraformOptions, "next_serverless")
	resultStat := gjson.Parse(fmt.Sprint(serverlessModule))
	aliasURL := resultStat.Get("static-deploy.next_distribution.aliases.0").String()
	if aliasURL == "" {
		aliasURL = resultStat.Get("static-deploy.next_distribution.domain_name").String()
	}

	// Stage 1
	test_structure.RunTestStage(t, "serverHealthCheck", func() {
		hitTheFrontPage(t, aliasURL)
	})

	// Stage 2
	test_structure.RunTestStage(t, "publicAssetsCheck", func() {
		getIcons(t, aliasURL)
	})

	// Stage 3
	// I could've checked the S3 buckets to see if these resources are uploaded there, too
	// but assuming that terraform apply finished with success, I just need to check the build
	// output of the NextJS app: required-server-files.json and build-manifest.json
	fileList := getRequiredServerFiles(aliasURL)
	fileList = append(fileList, getStaticAssets(aliasURL)...)
	fmt.Println(fileList)

	test_structure.RunTestStage(t, "staticAssetsCheck", func() {
		checkIfFilesExist(t, fileList, aliasURL)
	})
}

func deployTerraform(t *testing.T, workingDir string, varfiles []string) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: workingDir,
		Reconfigure:  true,
		VarFiles:     varfiles,
	})
	terraform.InitAndApply(t, terraformOptions)
}

func undeployTerraform(t *testing.T, workingDir string, varfiles []string) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: workingDir,
		Reconfigure:  true,
		VarFiles:     varfiles,
	})
	terraform.Destroy(t, terraformOptions)
}

// the front page should contain next.js in the raw text and it should respond with 200
func hitTheFrontPage(t *testing.T, aliasURL string) {
	tlsConfig := tls.Config{}
	code, body := http_helper.HttpGet(t, "https://"+aliasURL, &tlsConfig)
	assert.Equal(t, code, 200)
	assert.Contains(t, strings.ToLower(body), "next.js")
}

// hitting icons, which are public assets
func getIcons(t *testing.T, aliasURL string) {
	tlsConfig := tls.Config{}
	code, _ := http_helper.HttpGet(t, "https://"+aliasURL+"/assets/vercel.svg", &tlsConfig)
	assert.Equal(t, code, 200)
	code, _ = http_helper.HttpGet(t, "https://"+aliasURL+"/assets/next.svg", &tlsConfig)
	assert.Equal(t, code, 200)
	code, _ = http_helper.HttpGet(t, "https://"+aliasURL+"/favicon.ico", &tlsConfig)
	assert.Equal(t, code, 200)
}

// Accepts an array of strings as fileList, hits the aliasURL with these paths, expects 200
func checkIfFilesExist(t *testing.T, fileList []string, aliasURL string) {
	tlsConfig := tls.Config{}
	exists := true
	for _, files := range fileList {
		fmt.Println("https://" + aliasURL + files)
		code, _ := http_helper.HttpGet(t, "https://"+aliasURL+files, &tlsConfig)
		if code == 200 {
			exists = true
		} else {
			exists = false
			break
		}
	}
	assert.True(t, exists)
}

// test stage for the files mentioned in required-server-files.json
func getRequiredServerFiles(aliasURL string) []string {
	// Locally stored location of this file, we don't expect this to change?
	requiredServerFiles, _ := os.ReadFile("../example/nextjs-v13/standalone/.next/required-server-files.json")
	RSFData := gjson.Parse(string(requiredServerFiles)).Get("files").String()
	var fileList []string
	gjson.Parse(RSFData).ForEach(func(_, value gjson.Result) bool {
		stringValue := value.String()
		stringValue = "/_" + stringValue[1:]
		stringValue = strings.ReplaceAll(stringValue, "\\", "/")
		fileList = append(fileList, stringValue)
		return true
	})
	return fileList
}

// test stage for the files mentioned in build-manifest.json
func getStaticAssets(aliasURL string) []string {
	// Locally stored location of this file, we don't expect this to change?
	buildManifestFile, _ := os.ReadFile("../example/nextjs-v13/standalone/.next/build-manifest.json")
	var fileList []string
	processJSON(gjson.Parse(string(buildManifestFile)), &fileList)
	return fileList
}

// Helper function that gets all string values from nested JSONs of any depth.
// Called recursively from build-manifest.json parser
func processJSON(result gjson.Result, data *[]string) {
	result.ForEach(func(key, value gjson.Result) bool {
		switch {
		case value.IsArray() || value.IsObject():
			processJSON(value, data)
		case value.Type == gjson.String:
			*data = append(*data, "/_next/"+value.String())
		}
		return true
	})
}
