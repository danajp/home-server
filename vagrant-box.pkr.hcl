variable "channel" {
  description = "The flatcar channel to install from"

  type    = string
  default = "beta"
}

source "virtualbox-iso" "flatcar" {
  iso_url      = "https://beta.release.flatcar-linux.net/amd64-usr/current/flatcar_production_iso_image.iso"
  iso_checksum = "md5:da9294a0baea16a64c95581e78e9115e"

  disk_size     = 8192
  guest_os_type = "Linux_64"

  memory = 4096

  # no ssh password, ssh key is copied via ignition config
  ssh_username         = "core"
  ssh_private_key_file = "~/.ssh/id_ecdsa"

  http_directory = "."

  boot_wait = "20s"
  boot_command = [
    "<enter>",
    "<enter>",
    "<enter>",
    "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/ignition.json > ignition.json",
    " && ",
    "sudo flatcar-install -d /dev/sda -i ignition.json -C ${var.channel}",
    " && ",
    "sudo reboot",
    "<enter>"
  ]

  shutdown_command = "sudo poweroff"
}

build {
  sources = [
    "sources.virtualbox-iso.flatcar"
  ]

  post-processor "vagrant" {
    output = "packer-{{.BuildName}}-{{.Provider}}.box"
  }
}

