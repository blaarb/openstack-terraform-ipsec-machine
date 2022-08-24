resource "openstack_networking_port_v2" "vpn-target_port" {
  name               = "vpn-target_port"
  network_id         = "${openstack_networking_network_v2.private_network.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.sgroup-allow-all.id}"]

  fixed_ip {
    subnet_id  = "${openstack_networking_subnet_v2.private_subnet.id}"
    ip_address = var.vpn-target_internal-ip
  }
}

resource "openstack_blockstorage_volume_v3" "vpn-target-main-disk" {
  name                 = "vpn-target-main-disk"
  description          = ""
  size                 = 10
  volume_type          = "ceph-ssd"
  image_id             = var.os-image
  enable_online_resize = true
}

resource "openstack_compute_instance_v2" "vpn-target" {
  name            = "vpn-target"
  flavor_name     = "d1.ram1cpu1"
  key_pair        = "pscloud"
  security_groups = ["sgroup-allow-all"]
  # config_drive = false
  user_data = <<-EOF
                #cloud-config
                packages:
                  - tmux
                  - vim
              EOF
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.vpn-target-main-disk.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }
  network {
    port = "${openstack_networking_port_v2.vpn-target_port.id}"
  }
  depends_on = [openstack_compute_secgroup_v2.sgroup-allow-all, openstack_blockstorage_volume_v3.vpn-target-main-disk]
}