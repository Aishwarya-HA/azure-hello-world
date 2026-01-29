# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial GCP Cloud SQL module implementation
- Support for MySQL, PostgreSQL, and SQL Server
- Configurable availability types (ZONAL/REGIONAL)
- Backup and maintenance window configuration
- Query insights support
- Database and user creation
- Comprehensive documentation
- Basic and complete example configurations
- CI/CD pipeline with GitHub Actions
- Security scanning (TFSec, Trivy, Checkov)
- Terraform linting and validation

### Changed
- Updated module structure for GCP Cloud SQL
- Simplified security documentation
- Enhanced documentation with architecture diagrams

### Fixed
- Fixed TFLint configuration for v0.54.0+
- Removed reserved `depends_on` variable
- Updated GCP authentication to use credentials_json
- Extract `project_id` from Google credentials instead of hardcoding

## [1.0.0] - TBD

### Added
- Initial release of GCP Cloud SQL Terraform module
