output "app_external_ip" {
  //  HCL
  //  value = "${google_compute_instance.app[*].network_interface[*].access_config[0].nat_ip}"
  //  HCL2
  value = google_compute_instance.app[*].network_interface[*].access_config[0].nat_ip
}