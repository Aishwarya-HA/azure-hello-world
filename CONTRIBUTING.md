# Contributing to Terraform Module

Thank you for your interest in contributing to this Terraform module! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Module Standards](#module-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Versioning](#versioning)

## Code of Conduct

This project adheres to Unilever's Code of Conduct. By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- Terraform >= 1.0
- Go >= 1.21 (for Terratest)
- Python 3.9+ (for pre-commit hooks)
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Unilever-IaC-Core/<module-name>.git
   cd <module-name>
   ```

2. Install development tools:
   ```bash
   ./scripts/install-tools.sh
   ```

3. Initialize pre-commit hooks:
   ```bash
   .venv/bin/pre-commit install
   ```

## Development Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Follow Terraform best practices
   - Update documentation
   - Add or update tests
   - Update CHANGELOG.md

3. **Test your changes:**
   ```bash
   # Format code
   terraform fmt -recursive

   # Validate
   terraform validate

   # Run tests
   cd test
   go test -v -timeout 30m
   ```

4. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat: your descriptive commit message"
   ```
   
   Pre-commit hooks will automatically:
   - Format code
   - Run linters
   - Check for secrets
   - Update documentation

5. **Push and create PR:**
   ```bash
   git push origin feature/your-feature-name
   ```

## Module Standards

### File Structure

```
.
├── main.tf                 # Main module resources
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── providers.tf           # Provider version constraints
├── README.md               # Module documentation
├── CHANGELOG.md            # Version history
├── terraform/              # Terraform infrastructure code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── modules/           # Terraform modules
├── test/                   # Terratest tests
│   └── *_test.go          # Test files
└── docs/
    └── architecture.md     # Architecture documentation
```

### Naming Conventions

- **Resources:** Use descriptive names with underscores (e.g., `azurerm_resource_group.main`)
- **Variables:** Use snake_case (e.g., `resource_group_name`)
- **Outputs:** Use snake_case and descriptive names
- **Tags:** Always include standard tags

### Documentation Requirements

- All variables must have descriptions
- All outputs must have descriptions
- README must include usage examples
- Complex logic should have inline comments

### Variable Standards

```hcl
variable "example_variable" {
  description = "Clear description of what this variable does"
  type        = string
  default     = null
  
  validation {
    condition     = var.example_variable != ""
    error_message = "Variable cannot be empty."
  }
}
```

## Testing

### Unit Tests

Run Terratest unit tests:

```bash
cd test
go test -v -timeout 30m
```

### Integration Tests

Integration tests run in CI/CD pipeline on PR creation.

### Local Testing

Use terraform directory for local testing:

```bash
cd terraform
terraform init
terraform plan
```

## Pull Request Process

1. **Update Documentation:**
   - Update README.md if adding features
   - Update CHANGELOG.md following Keep a Changelog format
   - Ensure terraform-docs is regenerated

2. **PR Description:**
   - Clearly describe changes
   - Link related issues
   - Include testing performed
   - Note breaking changes

3. **Review Requirements:**
   - Pass all CI/CD checks
   - Minimum 1 approval from code owners
   - No merge conflicts
   - All conversations resolved

4. **Commit Message Format:**
   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `refactor:` Code refactoring
   - `test:` Test updates
   - `chore:` Maintenance tasks

## Versioning

This module follows [Semantic Versioning](https://semver.org/):

- **MAJOR:** Breaking changes
- **MINOR:** New features (backwards compatible)
- **PATCH:** Bug fixes

### Release Process

1. Update CHANGELOG.md with version and date
2. Create version tag:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
3. GitHub Actions will automatically create release

## Questions?

If you have questions, please:
- Check existing issues and discussions
- Contact the Platform Engineering team
- Create a new issue with the `question` label

Thank you for contributing! 🎉
