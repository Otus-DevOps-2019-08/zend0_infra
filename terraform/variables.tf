variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "europe-west1-b"
}
variable name {
  description = "Name public IP"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable "ssh_keys" {
  description = "Username(s) and key(s) for project"
}