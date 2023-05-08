resource "google_storage_bucket" "tags_bucket" {
  name                        = "${var.project_id}-${var.bucket_name}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "gcf_source_bucket" {
  name                        = "${var.project_id}-gcf-source"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "tag_updater_source" {
  name   = var.function_source_file_name
  source = var.function_source_file_source
  bucket = google_storage_bucket.gcf_source_bucket.name
}
