resource "random_id" "random_suffix" {
  byte_length = 8
}

resource "google_storage_bucket" "tags_bucket" {
  name                        = var.bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "gcf_source_bucket" {
  name                        = "gcf-source-${random_id.random_suffix.hex}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "tag_updater_source" {
  name   = var.function_source_file_name
  source = var.function_source_file_source
  bucket = google_storage_bucket.gcf_source_bucket.name
}

resource "google_storage_bucket_object" "empty_tags" {
  name   = var.tags_file_name
  source = local_file.empty.filename
  bucket = google_storage_bucket.tags_bucket.name
}

resource "local_file" "empty" {
  filename = var.tags_file_name
  content  = "java"
}
