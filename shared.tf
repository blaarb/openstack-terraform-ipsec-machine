terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.47.0"
    }
  }
}

provider "openstack" {
  user_name   = ""
  tenant_name = "Tutorial-project"
  password    = ""
  auth_url    = "https://auth.pscloud.io/v3/"
  region      = "kz-ala-1"
}

variable "os-image" {
  # default = "a91d529c-1e61-4eba-a1d0-3c645c87dc28" #centos-stream-8
  default = "d6e8208a-45f4-4c21-ad7c-e43a27da04ad" #almalinux 8
}

variable "vpn-machine_internal-ip" {
  default = "192.168.0.101"
}

variable "vpn-target_internal-ip" {
  default = "192.168.0.102"
}

resource "openstack_compute_secgroup_v2" "sgroup-allow-all" {
  name        = "sgroup-allow-all"
  description = "security group for name"
  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_network_v2" "private_network" {
  name           = "net1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "subnet1"
  network_id = openstack_networking_network_v2.private_network.id
  cidr       = "192.168.0.0/24"
  dns_nameservers = [
    "195.210.46.195",
    "195.210.46.132"
  ]
  ip_version  = 4
  enable_dhcp = true
  depends_on  = [openstack_networking_network_v2.private_network]
}

resource "openstack_networking_router_v2" "default_router" {
  name                = "default_router"
  external_network_id = "83554642-6df5-4c7a-bf55-21bc74496109" #UUID of the floating ip network
  admin_state_up      = "true"
  depends_on          = [openstack_networking_network_v2.private_network]
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id  = openstack_networking_router_v2.default_router.id
  subnet_id  = openstack_networking_subnet_v2.private_subnet.id
  depends_on = [openstack_networking_router_v2.default_router]
}
