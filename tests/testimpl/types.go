package common

import "github.com/launchbynttdata/lcaf-component-terratest/types"

// ThisTFModuleConfig holds module-specific test configuration.
// Embed GenericTFModuleConfig to inherit common fields used by the LCAF framework.
type ThisTFModuleConfig struct {
	types.GenericTFModuleConfig
}
