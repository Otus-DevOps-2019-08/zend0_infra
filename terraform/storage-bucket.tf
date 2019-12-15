provider "google" {
  version = "~> 2.15"
  project = var.project
  region  = var.region
}

module "bucket_prod" {
  source    = "git::https://github.com/SweetOps/terraform-google-storage-bucket.git?ref=master"
  name      = "otus"
  namespace = "tf"
  stage     = "prod"
  location  = var.region
}

output "bucket_prod_url" {
  value = module.bucket_prod.url
}

module "bucket_stage" {
  source    = "git::https://github.com/SweetOps/terraform-google-storage-bucket.git?ref=master"
  name      = "otus"
  namespace = "tf"
  stage     = "stage"
  location  = var.region
}

output "bucket_stage_url" {
  value = module.bucket_stage.url
}
