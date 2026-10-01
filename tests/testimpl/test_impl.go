package common

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/appmesh"
	appmeshtypes "github.com/aws/aws-sdk-go-v2/service/appmesh/types"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/require"
)

type nodeVerification struct {
	client   *appmesh.Client
	nodeArn  string
	nodeName string
	meshName string
}

// TestComposableVirtualNode runs read-only assertions first, then performs a
// small mutating operation (temporary tag add/remove) to prove write behavior.
func TestComposableVirtualNode(t *testing.T, ctx types.TestContext) {
	verification := verifyNodeReadOnly(t, ctx)
	runNodeTagWriteProbe(t, verification.client, verification.nodeArn)
}

// TestComposableVirtualNodeReadOnly validates the deployed virtual node via
// read-only SDK calls only. It shares verifyNodeReadOnly with the functional
// test but never invokes a mutating operation.
func TestComposableVirtualNodeReadOnly(t *testing.T, ctx types.TestContext) {
	verifyNodeReadOnly(t, ctx)
}

func verifyNodeReadOnly(t *testing.T, ctx types.TestContext) nodeVerification {
	t.Helper()

	appmeshClient := appmesh.NewFromConfig(GetAWSConfig(t))
	nodeName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "name")
	meshName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "mesh_name")

	_, err := appmeshClient.DescribeMesh(context.TODO(), &appmesh.DescribeMeshInput{MeshName: &meshName})
	require.NoErrorf(t, err, "error getting mesh description, %v", err)

	output, err := appmeshClient.DescribeVirtualNode(context.TODO(), &appmesh.DescribeVirtualNodeInput{
		MeshName:        &meshName,
		VirtualNodeName: &nodeName,
	})
	require.NoErrorf(t, err, "unable to describe virtual node, %v", err)
	virtualNode := output.VirtualNode

	t.Run("TestDoesNodeExist", func(t *testing.T) {
		require.Equal(t, "ACTIVE", string(virtualNode.Status.Status), "Expected virtual node to be active")
	})

	return nodeVerification{
		client:   appmeshClient,
		nodeArn:  *virtualNode.Metadata.Arn,
		nodeName: nodeName,
		meshName: meshName,
	}
}

// runNodeTagWriteProbe proves the module's write path by adding a temporary
// tag to the virtual node, verifying it took effect, then removing it. It
// must only be called from the functional (non-readonly) test path.
func runNodeTagWriteProbe(t *testing.T, client *appmesh.Client, nodeArn string) {
	t.Run("CanTagAndUntagNode", func(t *testing.T) {
		const probeKey = "lcaf-readonly-probe"
		const probeValue = "terratest"

		_, err := client.TagResource(context.TODO(), &appmesh.TagResourceInput{
			ResourceArn: &nodeArn,
			Tags: []appmeshtypes.TagRef{
				{Key: aws.String(probeKey), Value: aws.String(probeValue)},
			},
		})
		require.NoErrorf(t, err, "unable to tag virtual node, %v", err)

		defer func() {
			_, err := client.UntagResource(context.TODO(), &appmesh.UntagResourceInput{
				ResourceArn: &nodeArn,
				TagKeys:     []string{probeKey},
			})
			require.NoErrorf(t, err, "unable to untag virtual node, %v", err)
		}()

		tagsOutput, err := client.ListTagsForResource(context.TODO(), &appmesh.ListTagsForResourceInput{
			ResourceArn: &nodeArn,
		})
		require.NoErrorf(t, err, "unable to list tags for virtual node, %v", err)

		var found bool
		for _, tag := range tagsOutput.Tags {
			if aws.ToString(tag.Key) == probeKey {
				require.Equal(t, probeValue, aws.ToString(tag.Value), "Expected probe tag value to be %s, but got %s", probeValue, aws.ToString(tag.Value))
				found = true
				break
			}
		}
		require.True(t, found, "Expected probe tag %s to be present after TagResource", probeKey)
	})
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
