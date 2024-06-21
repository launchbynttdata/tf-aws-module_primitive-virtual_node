package common

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/appmesh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/require"
)

func TestComplete(t *testing.T, ctx types.TestContext) {
	appmeshClient := appmesh.NewFromConfig(GetAWSConfig(t))
	nodeName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")
	meshName := terraform.Output(t, ctx.TerratestTerraformOptions(), "mesh_name")

	output, err := appmeshClient.DescribeVirtualNode(context.TODO(), &appmesh.DescribeVirtualNodeInput{
		MeshName:        &meshName,
		VirtualNodeName: &nodeName,
	})
	if err != nil {
		t.Errorf("Unable to describe virtual node, %v", err)
	}
	virtualNode := output.VirtualNode

	t.Run("TestDoesNodeExist", func(t *testing.T) {
		require.Equal(t, "ACTIVE", virtualNode.Status, "Expected virtual node to be active")
	})
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
