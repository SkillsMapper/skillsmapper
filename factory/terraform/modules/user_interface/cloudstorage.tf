resource "google_storage_bucket" "bucket" {
  name          = "${var.project_id}-ui"
  location      = var.region
  storage_class = "REGIONAL"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "null_resource" "upload_files" {
  provisioner "local-exec" {
    command = "gsutil -m cp -r ${var.ui_source} gs://${var.project_id}-ui"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

