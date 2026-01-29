# Terraform Module Tests

This directory contains automated tests for the Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

- Go >= 1.21
- Terraform >= 1.0
- Azure CLI (authenticated) or GCP SDK (for cloud-specific modules)
- Appropriate cloud permissions

## Running Tests

### All Tests

```bash
go test -v -timeout 30m
```

### Specific Test

```bash
go test -v -timeout 30m -run TestBasicExample
```

### With Coverage

```bash
go test -v -timeout 30m -coverprofile=coverage.out
go tool cover -html=coverage.out
```

### Parallel Execution

```bash
go test -v -timeout 30m -parallel 4
```

## Test Structure

```
test/
├── go.mod              # Go module definition
├── go.sum              # Go dependencies
├── basic_test.go       # Basic terraform tests
├── complete_test.go    # Complete terraform tests
└── README.md           # This file
```

## Writing Tests

Example test structure:

```go
func TestBasicExample(t *testing.T) {
    t.Parallel()
    
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../terraform",
        EnvVars: map[string]string{
            "TF_VAR_subscription_id": "dummy-subscription-id",
            "TF_VAR_admin_ssh_key":   "ssh-rsa dummy-key",
            "TF_VAR_location":        "eastus",
            "TF_VAR_vm_size":         "Standard_DC1s_v3",
            "TF_VAR_prefix":          "test",
        },
    })
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Add your assertions
    publicIp := terraform.Output(t, terraformOptions, "public_ip")
    assert.NotEmpty(t, publicIp)
}
```

## Best Practices

1. **Isolation:** Each test should be independent
2. **Cleanup:** Always use `defer terraform.Destroy()`
3. **Unique Names:** Use `random.UniqueId()` for resource names
4. **Parallel:** Use `t.Parallel()` for faster execution
5. **Timeouts:** Set appropriate timeouts for long-running tests

## Troubleshooting

### Test Hangs

Increase timeout:
```bash
go test -v -timeout 60m
```

### Cleanup Failed

Manually destroy resources:
```bash
cd ../terraform
terraform destroy -auto-approve
```

### Permissions Issues

Verify cloud authentication:
```bash
# Azure
az account show

# GCP
gcloud auth list
```

## CI/CD

Tests run automatically in GitHub Actions on:
- Pull requests
- Pushes to main branch
- Manual workflow trigger

See `.github/workflows/terraform-module.yml` for configuration.
