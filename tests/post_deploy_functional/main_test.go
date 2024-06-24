package test

import (
	"testing"

	"github.com/launchbynttdata/lcaf-component-terratest/lib"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	testimpl "github.com/launchbynttdata/tf-aws-module_primitive-appmesh/tests/testimpl"
)

const (
	testConfigsExamplesFolderDefault = "../../examples"
	infraTFVarFileNameDefault        = "test.tfvars"
)

func TestModule(t *testing.T) {
	// The terraform provider ignores the aws cloud map attributes, but notices when AWS changes them from null to empty map
	// This is why the terraform apply is not idempotent, though the second apply will not change anything
	ctx := types.CreateTestContextBuilder().
		SetTestConfig(&testimpl.ThisTFModuleConfig{}).
		SetTestConfigFolderName(testConfigsExamplesFolderDefault).
		SetTestConfigFileName(infraTFVarFileNameDefault).
		SetTestSpecificFlags(map[string]types.TestFlags{
			"with_tls_enforced": {
				"IS_TERRAFORM_IDEMPOTENT_APPLY": false,
			},
		}).
		Build()

	lib.RunSetupTestTeardown(t, *ctx, testimpl.TestComplete)
}
