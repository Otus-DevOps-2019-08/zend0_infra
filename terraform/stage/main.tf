terraform {
  //  Версия terraform
  //  required_version = "0.12.8"
  required_version = "0.12.17"
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
  source_ranges = ["0.0.0.0/0"]
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

//resource "google_compute_project_metadata" "default" {
//  metadata = {
//    ssh-keys = "appuser1:${file(var.public_key_path)}"
//  }
//}

//resource "google_compute_project_metadata" "default" {
//  //  Добавляем ключи для пользователя(пользователей)
//  metadata = {
//    ssh-keys = join("", [for user, key in var.ssh_keys : "${user}:${file(key)}"])
//  }
//}

//resource "google_compute_instance" "app" {
//  //  count        = 2
//  //  name         = "reddit-app-${count.index}"
//  name         = "reddit-app"
//  machine_type = "g1-small"
//  zone         = var.zone
//  tags         = ["reddit-app"]
//
//  metadata = {
//    //  Путь до публичного ключа
//    ssh-keys = "appuser:${file(var.public_key_path)}"
//  }
//
//  //  определение загрузочного диска
//  boot_disk {
//    initialize_params {
//      image = var.disk_image
//    }
//  }
//
//  network_interface {
//    network = "default"
//    access_config {
//      nat_ip = google_compute_address.app_ip.address
//    }
//  }
//
//  connection {
//    type  = "ssh"
//    host  = self.network_interface[0].access_config[0].nat_ip
//    user  = "appuser"
//    agent = false
//    //  путь до приватного ключа
//    private_key = file(var.private_key_path)
//  }
//
//  provisioner "file" {
//    source      = "files/puma.service"
//    destination = "/tmp/puma.service"
//  }
//
//  provisioner "remote-exec" {
//    script = "files/deploy.sh"
//  }
//}
//
////  Резервируем внешний IP
//resource "google_compute_address" "app_ip" {
//  name = "reddit-app-ip"
//}
