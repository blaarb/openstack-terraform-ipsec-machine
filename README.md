# openstack-terraform-ipsec-machine
Example terraform role for deploying ipsec machine (libreswan + certmonger) in openstack cloud. The templates are based on the following public tutorials:
- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/securing_networks/configuring-a-vpn-with-ipsec_securing-networks
- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system-level_authentication_guide/certmongerx

#### shared.tf
This file contains variables and network definitions shared between both machines.

#### vpn-machine.tf
A machine with libreswan and cert-monger opening a serving as a vpn connection point for **vpn-target**.

#### vpn-target.tf
A machine "hidden" behind a VPN, or benefitting from a VPN connection.
