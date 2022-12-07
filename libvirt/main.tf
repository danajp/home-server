terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals { 
  ssh_command = "ssh core@${local.vm_ip}"
  vm_ip = libvirt_domain.machine.network_interface[0].addresses[0]
}

variable "prefix" {
  description = "prefix for libvirt resource names"
  type        = string
  default     = "home-server"
}

variable "base_image" {
  description = "path to unpacked flatcar base image"
  type        = string
}

variable "virtual_cpus" {
  type    = number
  default = 1.0
}

variable "virtual_memory" {
  type    = number
  default = 2048
}

resource "libvirt_volume" "vm-disk" {
  name   = var.prefix
  format = "qcow2"
  source = var.base_image
}

resource "libvirt_ignition" "this" {
  name = "${var.prefix}-ignition"
  content = "config.ign"
}

resource "libvirt_domain" "machine" {
  name   = var.prefix
  vcpu   = var.virtual_cpus
  memory = var.virtual_memory

  coreos_ignition = libvirt_ignition.this.id

  fw_cfg_name = "opt/org.flatcar-linux/config"

  disk {
    volume_id = libvirt_volume.vm-disk.id
  }

  graphics {
    listen_type = "address"
  }

  # dynamic IP assignment on the bridge, NAT for Internet access
  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }
}

output "ssh_command" {
  value = local.ssh_command
}

output "kubeconfig_command"  {
  value = "${local.ssh_command} cat /etc/rancher/k3s/k3s.yaml | sed -e 's/default/home-server-libvirt/' -e 's/127.0.0.1/${local.vm_ip}/'"
}