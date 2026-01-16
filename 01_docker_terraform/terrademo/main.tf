terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }
}

provider "google" {
  project = "project-7620f717-1e5e-458a-80e"
  region  = "europe-central2"
}
