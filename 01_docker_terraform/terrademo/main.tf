terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }
}

provider "google" {
  credentials = "./keys/my-creds.json"
  project     = "project-7620f717-1e5e-458a-80e"
  region      = "europe-central2"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "project-7620f717-1e5e-458a-80e-terra-bucket"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}
