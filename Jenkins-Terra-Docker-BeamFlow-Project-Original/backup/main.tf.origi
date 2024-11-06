provider "google" {
  credentials = file("focused-evening-397008-aa8085446fa3.json")
  project     = "focused-evening-397008"
}

resource "google_storage_bucket" "bucket" {
  name          = "aekanun_workshop2"
  location      = "US-CENTRAL1"
  force_destroy = true
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "aekanun_workshop2" # แทนที่ด้วย ID ของ dataset ที่คุณต้องการสร้าง
  location                    = "US"
  delete_contents_on_destroy = true
  # ค่าตัวแปรอื่นๆ ที่คุณต้องการกำหนดสำหรับ resource นี้
}

resource "null_resource" "main_pipeline" {
  provisioner "local-exec" {
    command = "python3 main_pipeline.py"
  }
  depends_on = [google_bigquery_dataset.dataset]
}

resource "null_resource" "stop_dataflow_job_on_destroy" {

  provisioner "local-exec" {
    when    = destroy
    command = "gcloud dataflow jobs cancel $(head -n 1 job_info.txt) --region=$(tail -n 1 job_info.txt)"
  }
  depends_on = [null_resource.main_pipeline]
}
