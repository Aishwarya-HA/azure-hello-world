variable "project_id" {
  description = "The GCP project ID where the GCS bucket will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
}

variable "region" {
  description = "GCS bucket region. Supports europe-west3 (Frankfurt) or europe-west4 (Netherlands)"
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+$", var.region)) && contains(["europe-west3", "europe-west4"], var.region)
    error_message = "Region must be either europe-west3 (Frankfurt) or europe-west4 (Netherlands)"
  }
}

variable "bucket_name" {
  description = "Full name for the GCS bucket (must be globally unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-_]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, lowercase letters, numbers, hyphens, and underscores only"
  }
}

variable "enable_versioning" {
  description = "Enable versioning for the GCS bucket to maintain object version history"
  type        = bool
  default     = false
}

variable "platform" {
  description = "Platform identifier for bucket naming (e.g., data, app, analytics)"
  type        = string
}

variable "environment" {
  description = "Environment identifier (dev, qa, uat, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "uat", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, uat, prod"
  }
}

variable "enable_storage_api" {
  description = "Enable Google Cloud Storage API for the project"
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Prevents public access to the bucket. enforced or inherited"
  type        = string
  default     = "enforced"

  validation {
    condition     = contains(["enforced", "inherited"], var.public_access_prevention)
    error_message = "Public access prevention must be either 'enforced' or 'inherited'"
  }
}

variable "versioning_enabled" {
  description = "Enable object versioning for the bucket"
  type        = bool
  default     = true
}

variable "encryption_default_kms_key_name" {
  description = "The Cloud KMS key name for default encryption. If null, Google-managed encryption is used"
  type        = string
  default     = null
  sensitive   = true
}

variable "force_destroy" {
  description = "Allow deletion of bucket even when containing objects (use with caution)"
  type        = bool
  default     = false
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access (recommended for IAM)"
  type        = bool
  default     = true
}

variable "retention_policy" {
  description = "Retention policy configuration for the bucket"
  type = object({
    retention_period = number
    is_locked        = optional(bool, false)
  })
  default = null
}

variable "logging_config" {
  description = "Access logging configuration for the bucket"
  type = object({
    log_bucket        = string
    log_object_prefix = optional(string, "")
  })
  default = null
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for object management (age, storage class transitions, deletions)"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                        = optional(number)
      created_before             = optional(string)
      with_state                 = optional(string)
      matches_storage_class      = optional(list(string))
      num_newer_versions         = optional(number)
      days_since_noncurrent_time = optional(number)
      days_since_custom_time     = optional(number)
    })
  }))
  default = []
}

variable "iam_members" {
  description = "IAM bindings for the bucket. Map of role to list of members"
  type        = map(list(string))
  default     = {}
}

variable "cors_config" {
  description = "CORS configuration for the bucket"
  type = list(object({
    origins          = optional(list(string))
    methods          = optional(list(string))
    response_headers = optional(list(string))
    max_age_seconds  = optional(number)
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to the bucket. Will be merged with required organizational labels"
  type        = map(string)
  default     = {}
}

variable "storage_class" {
  description = "Storage class for the bucket (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE"
  }
}

variable "autoclass_enabled" {
  description = "Enable Autoclass for automatic storage class transitions"
  type        = bool
  default     = false
}

variable "autoclass_terminal_storage_class" {
  description = "Terminal storage class for Autoclass (NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = null

  validation {
    condition     = var.autoclass_terminal_storage_class == null ? true : contains(["NEARLINE", "COLDLINE", "ARCHIVE"], var.autoclass_terminal_storage_class)
    error_message = "Terminal storage class must be NEARLINE, COLDLINE, or ARCHIVE"
  }
}

variable "default_event_based_hold" {
  description = "Enable default event-based hold on new objects"
  type        = bool
  default     = false
}

variable "requester_pays" {
  description = "Enable Requester Pays on the bucket"
  type        = bool
  default     = false
}

variable "website_config" {
  description = "Website configuration for static website hosting"
  type = object({
    main_page_suffix = optional(string)
    not_found_page   = optional(string)
  })
  default = null
}

variable "soft_delete_policy" {
  description = "Soft delete policy retention duration in seconds (7-90 days)"
  type = object({
    retention_duration_seconds = number
  })
  default = null

  validation {
    condition     = var.soft_delete_policy == null ? true : (var.soft_delete_policy.retention_duration_seconds >= 604800 && var.soft_delete_policy.retention_duration_seconds <= 7776000)
    error_message = "Soft delete retention must be between 7 days (604800s) and 90 days (7776000s)"
  }
}

variable "custom_placement_config" {
  description = "Custom placement configuration for dual-region buckets"
  type = object({
    data_locations = list(string)
  })
  default = null

  validation {
    condition     = var.custom_placement_config == null ? true : length(var.custom_placement_config.data_locations) == 2
    error_message = "Custom placement requires exactly 2 data locations for dual-region"
  }
}
