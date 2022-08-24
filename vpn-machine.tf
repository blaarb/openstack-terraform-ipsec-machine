
resource "openstack_networking_floatingip_v2" "vpn-machine_fip" {
  pool = "FloatingIP Net"
}

resource "openstack_networking_port_v2" "vpn-machine_port" {
  name               = "vpn-machine_port"
  network_id         = "${openstack_networking_network_v2.private_network.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.sgroup-allow-all.id}"]

  fixed_ip {
    subnet_id  = "${openstack_networking_subnet_v2.private_subnet.id}"
    ip_address = var.vpn-machine_internal-ip
  }
}

output "vpn-machine-floating-ip" {
  value = openstack_networking_floatingip_v2.vpn-machine_fip.address
}

resource "openstack_blockstorage_volume_v3" "vpn-machine-main-disk" {
  name                 = "vpn-machine-main-disk"
  description          = ""
  size                 = 10
  volume_type          = "ceph-ssd"
  image_id             = var.os-image
  enable_online_resize = true
}

resource "openstack_compute_instance_v2" "vpn-machine" {
  name            = "vpn-machine-floating-ip"
  flavor_name     = "d1.ram1cpu1"
  key_pair        = "pscloud"
  security_groups = ["sgroup-allow-all"]
  # config_drive = false
  user_data = <<-EOF
                #cloud-config
                packages:
                  - tmux
                  - vim
                  - libreswan
                  - certmonger
                  - firewalld
                write_files:
                  - path: /etc/strongswan/ipsec.d/tunnel.conf
                    content: |
                      conn tunnel01
                          auto=start
                          left=floating-ip
                          leftsubnet=192.168.0.0/24
                          right=
                          rightsubnet=
                          # enable if you use X.509 certs as auth method
                          leftcert=
                          left=
                          # enable if you use PSK (simply a password)
                          # authby=secret
                    permissions: '0640'
                runcmd:
                  - firewall-cmd --add-service="ipsec"
                  - firewall-cmd --runtime-to-permanent
                  - getcert add-scep-ca -c CA_KISC -u http://91.195.226.34:62269/cgi
              EOF
  
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.vpn-machine-main-disk.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }
  network {
    port = "${openstack_networking_port_v2.vpn-machine_port.id}"
  }
  depends_on = [openstack_compute_secgroup_v2.sgroup-allow-all, openstack_blockstorage_volume_v3.vpn-machine-main-disk]
}

resource "openstack_compute_floatingip_associate_v2" "vpn-machine_fip_association" {
  floating_ip = openstack_networking_floatingip_v2.vpn-machine_fip.address
  instance_id = openstack_compute_instance_v2.vpn-machine.id
  fixed_ip    = openstack_compute_instance_v2.vpn-machine.access_ip_v4
}
