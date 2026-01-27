output "bucket_name" {
  description = "The name of the created GCS bucket"
  value       = google_storage_bucket.bucket.name
}

output "bucket_self_link" {
  description = "The URI of the created GCS bucket"
  value       = google_storage_bucket.bucket.self_link
}

output "bucket_url" {
  description = "The base URL of the bucket in the format gs://<bucket-name>"
  value       = google_storage_bucket.bucket.url
}

output "bucket_location" {
  description = "The location (region) of the GCS bucket"
  value       = google_storage_bucket.bucket.location
}

output "bucket_id" {
  description = "The unique identifier for the bucket"
  value       = google_storage_bucket.bucket.id
}

output "bucket_storage_class" {
  description = "The storage class of the bucket"
  value       = google_storage_bucket.bucket.storage_class
}

output "bucket_labels" {
  description = "The labels applied to the bucket"
  value       = google_storage_bucket.bucket.labels
}

output "bucket_versioning_enabled" {
  description = "Whether versioning is enabled on the bucket"
  value       = var.versioning_enabled
}

output "bucket_public_access_prevention" {
  description = "The public access prevention setting for the bucket"
  value       = google_storage_bucket.bucket.public_access_prevention
}

output "iam_members" {
  description = "Map of IAM role to members assigned to the bucket"
  value       = var.iam_members
}

output "iam_bindings" {
  description = "List of IAM binding identifiers created for the bucket"
  value = [
    for binding in google_storage_bucket_iam_member.members : binding.id
  ]
}

output "encryption_key" {
  description = "The Cloud KMS key name used for bucket encryption (if CMEK is enabled)"
  value       = var.encryption_default_kms_key_name
  sensitive   = true
}

output "autoclass_enabled" {
  description = "Whether Autoclass is enabled on the bucket"
  value       = var.autoclass_enabled
}

output "autoclass_terminal_storage_class" {
  description = "The terminal storage class for Autoclass transitions"
  value       = var.autoclass_terminal_storage_class
}

output "website_config" {
  description = "Website configuration of the bucket"
  value       = var.website_config
}

output "soft_delete_retention_seconds" {
  description = "Soft delete policy retention duration in seconds"
  value       = var.soft_delete_policy != null ? var.soft_delete_policy.retention_duration_seconds : null
}

output "custom_placement_locations" {
  description = "Custom placement data locations for dual-region bucket"
  value       = var.custom_placement_config != null ? var.custom_placement_config.data_locations : null
}

output "default_event_based_hold" {
  description = "Default event-based hold status on new objects"
  value       = var.default_event_based_hold
}

output "requester_pays" {
  description = "Whether Requester Pays is enabled"
  value       = var.requester_pays
}
