# openstack-terraform-ipsec-machine
Example terraform role for deploying ipsec machine (libreswan + certmonger) in openstack cloud

#### shared.tf
This file contains variables and network definitions shared between both machines.

#### vpn-machine.tf
A machine with libreswan and cert-monger opening a serving as a vpn connection point for **vpn-target**.

#### vpn-target.tf
A machine "hidden" behind a VPN, or benefitting from a VPN connection.
