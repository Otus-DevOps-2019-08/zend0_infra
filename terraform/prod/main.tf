terraform {
  //  Версия terraform
  //  required_version = "0.12.8"
  required_version = ">= 0.12"

  backend "gcs" {
    bucket = "tf-prod-otus"
  }
}

provider "google" {
  //  Версия провайдера
  version = "~> 2.15"

  //  ID проекта
  project = var.project
  region  = var.region
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["79.164.18.97/32"]
}

module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  zone            = var.zone
  app_disk_image  = var.app_disk_image
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  zone            = var.zone
  db_disk_image   = var.db_disk_image
}

data "terraform_remote_state" "prod" {
  backend = "gcs"
  config = {
    bucket = "tf-prod-otus"
  }
}
