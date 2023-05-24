resource "google_storage_bucket" "bucket" {
  name          = "${var.project_id}-ui"
  location      = var.region
  storage_class = "REGIONAL"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "local_file" "config_js" {
  content = templatefile("${var.ui_project}/config.js.template", {
    API_KEY    = var.api_key
    PROJECT_ID = var.project_id
  })
  filename = "${var.ui_project}/src/js/config.js"
}

resource "null_resource" "upload_files" {
  depends_on = [local_file.config_js]
  provisioner "local-exec" {
    command = "gsutil -m cp -r ${var.ui_source} gs://${var.project_id}-ui"
  }

  triggers = {
    always_run = timestamp()
  }
}

