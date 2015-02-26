#!/usr/bin/perl -w
use strict;

use ExecuteAndTrace;

# Purpose: Creates a base image via kickstart configuration.


# TODO Make base image name configurable.
# TODO Make image and ks.cfg configurable.
# TODO Make size configurable?
# TODO Make the file type configurable qcows/lvm

Log("III Create the baseimage: baseks\n");
DieIfExecuteFails("virt-install --name baseks --memory 768 --disk \"pool=qcows,bus=virtio,size=10\" --vcpus 1 --location http://10.1.233.3/images/linux/releases/20/Fedora/x86_64/os --graphics none --extra-args=\"acpi=on console=tty0 console=ttyS0,115200 ks=http://10.1.233.3/configs/ks_fedora-20-x86_64_http_kvm_guest.cfg\" --network bridge:virbr0");
Log("III Done\n");
