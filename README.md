# virman
Virtual machine manager, a virsh wrapper in PERL.


Create a virtual machine based on the config:
  /var/virman/instanceconfigs/box/box.xml
/opt/virman/bin/virman-clone.pl box


Delete the image box
  /opt/virman/bin/virman-delete.pl 


Create the base image 'rhel63_x86_64' used by e.g. 'box'
virt-install --name rhel63_x86_64 --memory 768 --disk "pool=qcows,bus=virtio,size=10" --vcpus 1 --location http://169.254.0.3/images/rhel_63_x86_64 --graphics none --extra-args="acpi=on console=tty0 console=ttyS0,115200 ks=http://169.254.0.3/configs/ks_rhel-63-x86_64_http_kvm_guest.cfg" --network bridge:virbrconf

# Remove the udev network rules and the ifcfg.
#  Add --dryrun --verbose to just test it.
virt-sysprep --enable udev-persistent-net --delete /etc/sysconfig/network-scripts/ifcfg-eth0 -a /virt_images/rhel63_x86_64.qcow2


#TODO Do the Network merge for the IPMergeInstanceAndWrapperInfo
TODO Do the Run command merge for IPMergeInstanceAndWrapperInfo
TODO Read the install wrapper, if the app references one.
  - GetVNics
  - GetFileProvided
  - GetPreAppRunCommand
  - GeTPostAppRunCommand
TODO Merge the data from the install wrapper with the Instance data
  - e.g. the run commands, file commands and network.
  - index of -1, -2 etc indicates the order they are appended to the network list.
    -1: becomes the first vnic after the app instance vnics. etc.
TODO get the 'configuration' network to work.
TODO get the app files added.
TODO install the app (files)

TODO make virman-clone.pl support multiple roles
  verify that the role exists

