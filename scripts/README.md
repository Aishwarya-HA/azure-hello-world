# Terraform Module Scripts

This directory contains utility scripts for module development and maintenance.

## Available Scripts

### install-tools.sh / install-tools.ps1

Installs required development tools:
- Terraform
- TFLint
- TFSec
- terraform-docs
- detect-secrets
- pre-commit

**Usage (Linux/macOS):**
```bash
./scripts/install-tools.sh
```

**Usage (Windows):**
```powershell
.\scripts\install-tools.ps1
```

### run-tflint.sh / run-tflint.ps1

Runs TFLint validation on the module.

**Usage (Linux/macOS):**
```bash
./scripts/run-tflint.sh
```

**Usage (Windows):**
```powershell
.\scripts\run-tflint.ps1
```

## Requirements

- **Linux/macOS:** Bash shell
- **Windows:** PowerShell 5.1 or later
- **All:** Internet connection for downloading tools

## Post-Installation

After running `install-tools.sh`:

1. Restart your terminal or run:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

2. Verify installation:
   ```bash
   terraform --version
   tflint --version
   tfsec --version
   terraform-docs --version
   ```

3. Install pre-commit hooks:
   ```bash
   .venv/bin/pre-commit install
   ```

## Troubleshooting

### Tools not found after installation

Make sure the tools directory is in your PATH:
```bash
export PATH="$PATH:$HOME/.terraform-tools/terraform:$HOME/.terraform-tools/tflint:$HOME/.terraform-tools/tfsec:$HOME/.terraform-tools/terraform-docs"
```

### Permission denied

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Python virtual environment issues

Recreate the virtual environment:
```bash
rm -rf .venv
python3 -m venv .venv
.venv/bin/pip install pre-commit detect-secrets
```
