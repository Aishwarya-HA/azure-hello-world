package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBasicExample(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform",
		NoColor:      true,
		EnvVars: map[string]string{
			"TF_VAR_subscription_id": "dummy-subscription-id",
			"TF_VAR_admin_ssh_key":   "ssh-rsa dummy-key",
			"TF_VAR_location":        "eastus",
			"TF_VAR_vm_size":         "Standard_DC1s_v3",
			"TF_VAR_prefix":          "test",
		},
	})

	// Comment out destroy and apply for plan-only testing
	// defer terraform.Destroy(t, terraformOptions)

	// Initialize and validate Terraform configuration
	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)

	// Run plan to validate configuration without applying
	planOutput := terraform.Plan(t, terraformOptions)
	assert.NotEmpty(t, planOutput, "Terraform plan should generate output")

	// Comment out apply and output testing
	// terraform.InitAndApply(t, terraformOptions)
	// publicIp := terraform.Output(t, terraformOptions, "public_ip")
	// assert.NotEmpty(t, publicIp, "Public IP should not be empty")
	// vmName := terraform.Output(t, terraformOptions, "vm_name")
	// assert.NotEmpty(t, vmName, "VM name should not be empty")
}
