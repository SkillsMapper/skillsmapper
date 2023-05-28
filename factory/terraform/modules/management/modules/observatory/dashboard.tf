
resource "google_monitoring_dashboard" "default" {
  project = var.project_id
  dashboard_json = jsonencode({
    "displayName" : "Cloud Run Dashboard",
    "gridLayout" : {
      "widgets" : [
        {
          "title" : "Cloud Run Service - Instance Count",
          "xyChart" : {
            "dataSets" : [
              {
                "timeSeriesQuery" : {
                  "timeSeriesFilter" : {
                    "filter" : "metric.type=\"run.googleapis.com/instance_counts/active\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"${var.fact_service_name}\" metric.label.\"project_id\"=\"${var.dev_project_id}\"",
                    "aggregation" : {
                      "alignmentPeriod" : { "seconds" : 60 },
                      "crossSeriesReducer" : "REDUCE_SUM",
                      "perSeriesAligner" : "ALIGN_SUM"
                    }
                  },
                  "unitOverride" : "1"
                },
                "plotType" : "LINE",
                "minAlignmentPeriod" : { "seconds" : 60 }
              }
            ],
            "timeshiftDuration" : { "seconds" : 0 },
            "yAxis" : { "label" : "y1Axis", "scale" : "LINEAR" },
            "chartOptions" : { "mode" : "COLOR" }
          }
        }
      ]
    }
  })
}
