# Provider configuration
provider "google" {
 credentials = file("stately-gist-435602-u9-e7d9d76c1b6d.json")
 project     = "stately-gist-435602-u9"
 region      = "us-central1"
}

# Cloud Storage bucket
resource "google_storage_bucket" "bucket" {
 name          = "aekanun_workshop2"
 location      = "us-south1"
 force_destroy = true
 
 # การตั้งค่าความปลอดภัยเพิ่มเติม
 uniform_bucket_level_access = true
 
 versioning {
   enabled = false
 }
}

# BigQuery Dataset
resource "google_bigquery_dataset" "dataset" {
 dataset_id                  = "aekanun_workshop2"
 location                   = "US"
 delete_contents_on_destroy = true
}

# Pub/Sub Topic
resource "google_pubsub_topic" "transactions" {
 name = "aekanun-transactions"
 project = "stately-gist-435602-u9"

 # ตั้งค่า message retention
 message_retention_duration = "86600s"  # 24 ชั่วโมง
}

# Dataflow Pipeline
resource "null_resource" "main_pipeline" {
 provisioner "local-exec" {
   command = <<-EOT
     export GOOGLE_APPLICATION_CREDENTIALS="${path.module}/stately-gist-435602-u9-e7d9d76c1b6d.json"
     python3 main_pipeline.py
   EOT
 }
 depends_on = [
   google_bigquery_dataset.dataset,
   google_storage_bucket.bucket,
   google_pubsub_topic.transactions
 ]
}

# Resource สำหรับหยุด Dataflow job เมื่อ destroy
resource "null_resource" "stop_dataflow_job_on_destroy" {
 provisioner "local-exec" {
   when    = destroy
   command = <<-EOT
     export GOOGLE_APPLICATION_CREDENTIALS="${path.module}/stately-gist-435602-u9-e7d9d76c1b6d.json"
     
     # Activate service account
     gcloud auth activate-service-account --key-file=${path.module}/stately-gist-435602-u9-e7d9d76c1b6d.json
     
     # Set project
     gcloud config set project stately-gist-435602-u9
     
     # ลบทุก jobs ที่มี prefix ที่เราใช้
     JOBS=$(gcloud dataflow jobs list \
       --region=us-central1 \
       --project=stately-gist-435602-u9 \
       --filter="name:beamapp* AND state:running" \
       --format="get(id)")
     
     for JOB_ID in $JOBS; do
       echo "Canceling job: $JOB_ID"
       gcloud dataflow jobs cancel $JOB_ID \
         --region=us-central1 \
         --project=stately-gist-435602-u9
     done
   EOT
 }
}

# Outputs
output "bucket_name" {
 description = "The name of the GCS bucket"
 value       = google_storage_bucket.bucket.name
}

output "dataset_id" {
 description = "The ID of the BigQuery dataset"
 value       = google_bigquery_dataset.dataset.dataset_id
}

output "pubsub_topic" {
 description = "The name of the Pub/Sub topic"
 value       = google_pubsub_topic.transactions.name
}