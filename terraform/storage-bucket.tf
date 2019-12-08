provider "google" {
  version = "~> 2.15"
  project = var.project
  region  = var.region
}

//module "storage_prod" {
////  source  = "SweetOps/storage-bucket/google"
//  source = "git::https://github.com/SweetOps/terraform-google-storage-bucket.git?ref=master"
//  version = "0.3.0"
//  location = var.region
//  name = "devops-prod"
//    stage      = "production"
//  namespace  = "sweetops"
//}
//
//output "storage_prod_url" {
//  value = module.storage_prod.url
//}

module "bucket_prod" {
  source = "git::https://github.com/SweetOps/terraform-google-storage-bucket.git?ref=master"
  //  name        = ""
  stage     = "prod"
  namespace = "devops"
  location  = var.region
}

output "bucket_prod_url" {
  value = module.bucket_prod.url
}

module "bucket_stage" {
  source = "git::https://github.com/SweetOps/terraform-google-storage-bucket.git?ref=master"
  //  name        = ""
  stage     = "stage"
  namespace = "devops"
  location  = var.region
}

output "bucket_stage_url" {
  value = module.bucket_stage.url
}
