package common

import "github.com/launchbynttdata/lcaf-component-terratest/types"

type ThisTFModuleConfig struct {
	types.GenericTFModuleConfig
	Vpc_id        string    `json:"vpc_id"`
	Zone_name     string    `json:"zone_name"`
	Comment       string    `json:"comment"`
	Force_destroy bool      `json:"force_destroy"`
	Records       []Records `json:"records"`
}

type Alias struct {
}
type Records struct {
	Alias   Alias    `json:"alias"`
	Name    string   `json:"name"`
	Records []string `json:"records"`
	TTL     int64    `json:"ttl"`
	Type    string   `json:"type"`
}
