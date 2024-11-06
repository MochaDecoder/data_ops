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
 friendly_name              = "Workshop 2 Dataset"
 description                = "Dataset for workshop 2"
 location                   = "US"
 delete_contents_on_destroy = true

 access {
   role          = "OWNER"
   special_group = "projectOwners"
 }
 access {
   role          = "READER"
   special_group = "projectReaders"
 }
 access {
   role          = "WRITER"
   special_group = "projectWriters"
 }
}

# Pub/Sub Topic
resource "google_pubsub_topic" "transactions" {
 name = "aekanun-transactions"
 project = "stately-gist-435602-u9"

 # ตั้งค่า message retention ถ้าต้องการ
 message_retention_duration = "86600s"  # 24 ชั่วโมง
}

# Pub/Sub Subscription (ถ้าต้องการ)
resource "google_pubsub_subscription" "transactions_sub" {
 name  = "aekanun-transactions-sub"
 topic = google_pubsub_topic.transactions.name
 project = "stately-gist-435602-u9"

 # ตั้งค่า message retention
 message_retention_duration = "604800s"  # 7 วัน
 
 # ตั้งค่า acknowledgement deadline
 ack_deadline_seconds = 20

 # ตั้งค่า retry policy
 retry_policy {
   minimum_backoff = "10s"
   maximum_backoff = "600s"  # 10 นาที
 }

 # ตั้งค่า expiration policy
 expiration_policy {
   ttl = "2592000s"  # 30 วัน
 }
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
   google_pubsub_topic.transactions,
   google_pubsub_subscription.transactions_sub
 ]
}

# Resource สำหรับหยุด Dataflow job เมื่อ destroy
resource "null_resource" "stop_dataflow_job_on_destroy" {
 provisioner "local-exec" {
   when    = destroy
   command = "gcloud dataflow jobs cancel $(head -n 1 job_info.txt) --region=$(tail -n 1 job_info.txt)"
 }
 depends_on = [null_resource.main_pipeline]
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

output "pubsub_subscription" {
 description = "The name of the Pub/Sub subscription"
 value       = google_pubsub_subscription.transactions_sub.name
}