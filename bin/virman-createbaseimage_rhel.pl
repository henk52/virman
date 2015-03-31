#!/usr/bin/perl -w
use strict;

use ExecuteAndTrace;

# Purpose: Creates a base image via kickstart configuration.


# TODO Make base image name configurable.
# TODO Make image and ks.cfg configurable.
# TODO Make size configurable?
# TODO Make the file type configurable qcows/lvm

Log("III Create the baseimage: baseks\n");
DieIfExecuteFails("virt-install --name rhel63_x86_64 --memory 768 --disk \"pool=qcows,bus=virtio,size=10\" --vcpus 1 --location http://169.254.0.3/images/rhel_63_x86_64 --graphics none --extra-args=\"acpi=on console=tty0 console=ttyS0,115200 ks=http://169.254.0.3/configs/ks_rhel-63-x86_64_http_kvm_guest.cfg\" --network bridge:virbrconf");

Log("III Remove udev nic rules and ifcfg-eth0.\n");
DieIfExecuteFails("virt-sysprep  --enable udev-persistent-net,customize --delete /etc/sysconfig/network-scripts/ifcfg-eth0 -a /virt_images/rhel63_x86_64.qcow2");
Log("III Done\n");
