//resource "google_compute_target_pool" "default" {
//  name = "puma-pool"
//
//  instances = [
//    "${var.zone}/reddit-app-0",
//    "${var.zone}/reddit-app-1",
//  ]
//
//  health_checks = [
//    google_compute_http_health_check.default.name,
//  ]
//}
//
//resource "google_compute_http_health_check" "default" {
//  name               = "default"
//  port               = 9292
//  request_path       = "/"
//  check_interval_sec = 1
//  timeout_sec        = 1
//}
//
//resource "google_compute_global_address" "default" {
//  project      = var.project
//  name         = "${var.name}-address"
//  ip_version   = "IPV4"
//  address_type = "EXTERNAL"
//}
//
//resource "google_compute_forwarding_rule" "default" {
//  name       = "website-forwarding-rule"
//  target     = google_compute_target_pool.default.self_link
//  port_range = "80"
//}
//
////resource "google_compute_target_pool" "default" {
////  name = "website-target-pool"
////}
//
//
//# ------------------------------------------------------------------------------
//# IF PLAIN HTTP ENABLED, CREATE FORWARDING RULE AND PROXY
//# ------------------------------------------------------------------------------
//
////resource "google_compute_target_http_proxy" "http" {
////  count   = var.enable_http ? 1 : 0
////  project = var.project
////  name    = "${var.name}-http-proxy"
////  url_map = var.url_map
////}
////
////resource "google_compute_global_forwarding_rule" "http" {
////  provider   = google-beta
////  count      = var.enable_http ? 1 : 0
////  project    = var.project
////  name       = "${var.name}-http-rule"
////  target     = google_compute_target_http_proxy.http[0].self_link
////  ip_address = google_compute_global_address.default.address
////  port_range = "80"
////
////  depends_on = [google_compute_global_address.default]
////
////  labels = var.custom_labels
////}