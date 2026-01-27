locals {
  # Deterministic bucket naming using var.bucket_name as base
  bucket_name = var.bucket_name

  # Merge user-provided labels with required organizational labels
  bucket_labels = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      platform    = var.platform
      region      = var.region
    },
    var.labels
  )
}

# Enable Storage API if requested
resource "google_project_service" "storage_api" {
  count   = var.enable_storage_api ? 1 : 0
  project = var.project_id
  service = "storage.googleapis.com"

  disable_on_destroy = false

  lifecycle {
    precondition {
      condition     = var.project_id != ""
      error_message = "Project ID must be provided to enable Storage API"
    }
  }
}

# GCS Bucket with comprehensive security and observability features
resource "google_storage_bucket" "bucket" {
  project  = var.project_id
  name     = local.bucket_name
  location = var.region

  storage_class               = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention    = var.public_access_prevention
  force_destroy               = var.force_destroy
  labels                      = local.bucket_labels

  # Versioning for data protection
  versioning {
    enabled = var.versioning_enabled
  }

  # Encryption configuration (CMEK if provided, otherwise Google-managed)
  dynamic "encryption" {
    for_each = var.encryption_default_kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = var.encryption_default_kms_key_name
    }
  }

  # Retention policy for compliance
  dynamic "retention_policy" {
    for_each = var.retention_policy != null ? [var.retention_policy] : []
    content {
      retention_period = retention_policy.value.retention_period
      is_locked        = retention_policy.value.is_locked
    }
  }

  # Access logging for observability
  dynamic "logging" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      log_bucket        = logging.value.log_bucket
      log_object_prefix = logging.value.log_object_prefix
    }
  }

  # Lifecycle rules for automated object management
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lifecycle_rule.value.action.storage_class
      }
      condition {
        age                        = lifecycle_rule.value.condition.age
        created_before             = lifecycle_rule.value.condition.created_before
        with_state                 = lifecycle_rule.value.condition.with_state
        matches_storage_class      = lifecycle_rule.value.condition.matches_storage_class
        num_newer_versions         = lifecycle_rule.value.condition.num_newer_versions
        days_since_noncurrent_time = lifecycle_rule.value.condition.days_since_noncurrent_time
        days_since_custom_time     = lifecycle_rule.value.condition.days_since_custom_time
      }
    }
  }

  # CORS configuration
  dynamic "cors" {
    for_each = var.cors_config
    content {
      origin          = cors.value.origins
      method          = cors.value.methods
      response_header = cors.value.response_headers
      max_age_seconds = cors.value.max_age_seconds
    }
  }

  # Autoclass configuration
  dynamic "autoclass" {
    for_each = var.autoclass_enabled ? [1] : []
    content {
      enabled                = true
      terminal_storage_class = var.autoclass_terminal_storage_class
    }
  }

  # Website configuration
  dynamic "website" {
    for_each = var.website_config != null ? [var.website_config] : []
    content {
      main_page_suffix = website.value.main_page_suffix
      not_found_page   = website.value.not_found_page
    }
  }

  # Soft delete policy
  dynamic "soft_delete_policy" {
    for_each = var.soft_delete_policy != null ? [var.soft_delete_policy] : []
    content {
      retention_duration_seconds = soft_delete_policy.value.retention_duration_seconds
    }
  }

  # Custom placement for dual-region buckets
  dynamic "custom_placement_config" {
    for_each = var.custom_placement_config != null ? [var.custom_placement_config] : []
    content {
      data_locations = custom_placement_config.value.data_locations
    }
  }

  default_event_based_hold = var.default_event_based_hold
  requester_pays           = var.requester_pays

  depends_on = [google_project_service.storage_api]

  lifecycle {
    # Prevent accidental deletion in production
    precondition {
      condition     = var.environment != "prod" || var.force_destroy == false
      error_message = "force_destroy must be false for production buckets to prevent accidental deletion"
    }

    # Ensure CMEK is used in production
    precondition {
      condition     = var.environment != "prod" || var.encryption_default_kms_key_name != null
      error_message = "Production buckets must use customer-managed encryption keys (CMEK)"
    }
  }
}

# IAM bindings for bucket access control
resource "google_storage_bucket_iam_member" "members" {
  for_each = {
    for binding in flatten([
      for role, members in var.iam_members : [
        for member in members : {
          role   = role
          member = member
          key    = "${role}__${member}"
        }
      ]
    ]) : binding.key => binding
  }

  bucket = google_storage_bucket.bucket.name
  role   = each.value.role
  member = each.value.member
}
