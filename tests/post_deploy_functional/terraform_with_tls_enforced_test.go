package test

import (
	"context"
	"fmt"
	"os"
	"reflect"
	"strconv"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/appmesh"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

const (
	base            = "../../examples/"
	testVarFileName = "/test.tfvars"
	caModule        = "module.private_ca"
)

var standardTags = map[string]string{
	"provisioner": "Terraform",
}

func TestAppMeshVirtualNode(t *testing.T) {
	t.Parallel()
	stage := test_structure.RunTestStage

	files, err := os.ReadDir(base)
	if err != nil {
		assert.Error(t, err)
	}
	for _, file := range files {
		dir := base + file.Name()
		if file.IsDir() {
			defer stage(t, "teardown_appmesh_virtualnode", func() { tearDownAppMeshVirtualNode(t, dir) })
			stage(t, "setup_and_test_appmesh_virtualnode", func() { setupAndTestAppMeshVirtualNode(t, dir) })
		}
	}
}

func setupAndTestAppMeshVirtualNode(t *testing.T, dir string) {
	varsFilePath := []string{dir + testVarFileName}

	terraformOptionsCA := &terraform.Options{
		TerraformDir: dir,
		Targets:      []string{caModule},
		VarFiles:     varsFilePath,
		Logger:       logger.Discard,

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// Seperate terraform options for CA to execute first
	terraformOptionsCA.VarFiles = varsFilePath

	terraformOptions := &terraform.Options{
		TerraformDir: dir,
		VarFiles:     []string{dir + testVarFileName},
		NoColor:      true,
		Logger:       logger.Discard,
	}

	expectedPatternARN := "^arn:aws:appmesh:[a-z]{2}-[a-z]+-[0-9]{1}:[0-9]{12}:mesh/[a-zA-Z0-9-]+/virtualNode/[a-zA-Z0-9-]+$"

	test_structure.SaveTerraformOptions(t, dir, terraformOptions)

	terraform.InitAndApply(t, terraformOptionsCA)
	// sleep for 3 minutes for the CA status change to ISSUED
	time.Sleep(3 * time.Minute)
	terraform.InitAndApply(t, terraformOptions)

	actualId := terraform.Output(t, terraformOptions, "id")
	assert.NotEmpty(t, actualId, "Virtual Node ID is empty")
	actualARN := terraform.Output(t, terraformOptions, "arn")
	assert.Regexp(t, expectedPatternARN, actualARN, "ARN does not match expected pattern")
	actualRadomId := terraform.Output(t, terraformOptions, "random_int")
	assert.NotEmpty(t, actualRadomId, "Random ID is empty")
	actualName := terraform.Output(t, terraformOptions, "name")
	assert.NotEmpty(t, actualName, "name is empty")

	expectedNamePrefix := terraform.GetVariableAsStringFromVarFile(t, dir+testVarFileName, "naming_prefix")

	expectedVnodeName := expectedNamePrefix + "-vnode-" + actualRadomId
	expectedMeshName := expectedNamePrefix + "-app-mesh-" + actualRadomId

	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		config.WithSharedConfigProfile(os.Getenv("AWS_PROFILE")),
	)
	if err != nil {
		assert.Error(t, err, "can't connect to aws")
	}

	client := appmesh.NewFromConfig(cfg)
	input := &appmesh.DescribeVirtualNodeInput{
		VirtualNodeName: aws.String(expectedVnodeName),
		MeshName:        aws.String(expectedMeshName),
	}

	result, err := client.DescribeVirtualNode(context.TODO(), input)
	if err != nil {
		assert.Fail(t, fmt.Sprintf("The expected virtual node was not found %s", err.Error()))

	}
	virtualNode := result.VirtualNode
	expectedId := *virtualNode.Metadata.Uid
	expectedArn := *virtualNode.Metadata.Arn

	ActualVnodeListeners := virtualNode.Spec.Listeners
	ActualTLSEnforce := strconv.FormatBool(*virtualNode.Spec.BackendDefaults.ClientPolicy.Tls.Enforce)

	assert.Regexp(t, expectedPatternARN, actualARN, "ARN does not match expected pattern")
	assert.Equal(t, expectedArn, actualARN, "ARN does not match")
	assert.Equal(t, expectedId, actualId, "Vnode id does not match")

	for _, listener := range ActualVnodeListeners {
		VnodeTlsMode := listener.Tls.Mode
		ActualListenerTlsMode := string(VnodeTlsMode)
		ActualVnodeHealthCheckPath := listener.HealthCheck.Path
		ActualVnodeHealthCheckHealthyTS := listener.HealthCheck.HealthyThreshold
		ActualVnodeHealthCheckIntervalMillis := *listener.HealthCheck.IntervalMillis
		ActualVnodeHealthCheckTimeoutMillis := *listener.HealthCheck.TimeoutMillis
		ActualVnodeHealthCheckUnhealthyThreshold := listener.HealthCheck.UnhealthyThreshold
		ActualVnodePort := fmt.Sprintf("[%d]", listener.PortMapping.Port)

		expectedTlsMode, err := terraform.GetVariableAsStringFromVarFileE(t, dir+testVarFileName, "tls_mode")
		if err == nil {
			assert.Equal(t, expectedTlsMode, ActualListenerTlsMode, "Vnode TLS Mode does not match")
		}

		expectedTlsEnforce, err := terraform.GetVariableAsStringFromVarFileE(t, dir+testVarFileName, "tls_enforce")
		if err == nil {
			assert.Equal(t, expectedTlsEnforce, ActualTLSEnforce, "Vnode TLS Enforce does not match")
		}

		expectedTlsPort, err := terraform.GetVariableAsStringFromVarFileE(t, dir+testVarFileName, "ports")
		if err == nil {
			assert.Equal(t, string(expectedTlsPort), ActualVnodePort, "Vnode TLS Port does not match")
		}

		expectedHealthCheckPath, err := terraform.GetVariableAsStringFromVarFileE(t, dir+testVarFileName, "health_check_path")
		if err == nil {
			assert.Equal(t, expectedHealthCheckPath, *ActualVnodeHealthCheckPath, "Vnode HealthCheck  Path does not match")
		}

		expectedHealthCheckHealthyTS, err := terraform.GetVariableAsMapFromVarFileE(t, dir+testVarFileName, "health_check_config")
		if err == nil {
			assert.Equal(t, expectedHealthCheckHealthyTS["healthy_threshold"], fmt.Sprintf("%d", ActualVnodeHealthCheckHealthyTS), "Vnode Healthcheck TS does not match")
		}

		expectedHealthCheckIntervalMillis, err := terraform.GetVariableAsMapFromVarFileE(t, dir+testVarFileName, "health_check_config")
		if err == nil {
			assert.Equal(t, expectedHealthCheckIntervalMillis["interval_millis"], fmt.Sprintf("%d", ActualVnodeHealthCheckIntervalMillis), "Vnode Healthcheck Interval Millis Port does not match")
		}

		expectedVnodeHealthCheckTimeoutMilis, err := terraform.GetVariableAsMapFromVarFileE(t, dir+testVarFileName, "health_check_config")
		if err == nil {
			assert.Equal(t, expectedVnodeHealthCheckTimeoutMilis["timeout_millis"], fmt.Sprintf("%d", ActualVnodeHealthCheckTimeoutMillis), "Vnode Timeout Millis  does not match")
		}

		expectedHealthCheckUnhealthyTS, err := terraform.GetVariableAsMapFromVarFileE(t, dir+testVarFileName, "health_check_config")
		if err == nil {
			assert.Equal(t, expectedHealthCheckUnhealthyTS["unhealthy_threshold"], fmt.Sprintf("%d", ActualVnodeHealthCheckUnhealthyThreshold), "Vnode Unhealthy threshold  does not match")
		}

	}
	checkTagsMatch(t, dir, actualARN, client)
}

func checkTagsMatch(t *testing.T, dir string, actualARN string, client *appmesh.Client) {
	expectedTags, err := terraform.GetVariableAsMapFromVarFileE(t, dir+testVarFileName, "tags")
	if err == nil {
		result2, err2 := client.ListTagsForResource(context.TODO(), &appmesh.ListTagsForResourceInput{ResourceArn: aws.String(actualARN)})
		if err2 != nil {
			assert.Error(t, err2, "Failed to retrieve tags from AWS")
		}
		// convert AWS Tag[] to map so we can compare
		actualTags := map[string]string{}
		for _, tag := range result2.Tags {
			actualTags[*tag.Key] = *tag.Value
		}

		// add the standard tags to the expected tags
		for k, v := range standardTags {
			expectedTags[k] = v
		}
		expectedTags["env"] = actualTags["env"]
		assert.True(t, reflect.DeepEqual(actualTags, expectedTags), fmt.Sprintf("tags did not match, expected: %v\nactual: %v", expectedTags, actualTags))
	}
}

func tearDownAppMeshVirtualNode(t *testing.T, dir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, dir)
	terraformOptions.Logger = logger.Discard
	terraform.Destroy(t, terraformOptions)

}
