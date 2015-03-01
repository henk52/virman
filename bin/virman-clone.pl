#!/usr/bin/perl -w

use strict;

# Purpose: create a machine instance, base on a given base machine and template.
# TODO provide template name in CLI.

# Steps:
#  Generate the machine definition in /opt/gas/


use Data::Dumper;
use Text::Template;
use FindBin;
use ExecuteAndTrace;
use Sys::Virt;
use Sys::Virt::Domain;
use XML::Simple;

my $szTemplatePath = "$FindBin::RealBin/../templates";
my $szFilesPath = "$FindBin::RealBin/../files";

# TODO C put this in a protected directory.
my $f_szGeneralContainerKeyFile = "/etc/bilby_rsa";

my $szVirshFilePoolPath = '/virt_images';

my %hMachineConfiguration;

my $f_szFedoraBaseName = 'baseks';

$hMachineConfiguration{'szGasBaseDirectory'} = '/opt/gas';


$hMachineConfiguration{'szGuestName'} = 'vrouter';
$hMachineConfiguration{'szGuestTitle'} = 'Virtual Router';
$hMachineConfiguration{'szGuestDescription'} = 'Virtual router.';

# The amount of memory allocate to the Guest in KiB.
$hMachineConfiguration{'szGuestMemory'} = '786432';

# file: cqow2
$hMachineConfiguration{'szGuestDiskType'} = 'file';

$hMachineConfiguration{'szGuestDriverType'} = 'qcow2';

$hMachineConfiguration{'szGuestDiskSourceTypeName'} = 'file';
$hMachineConfiguration{'szGuestStorageDevice'} = "${szVirshFilePoolPath}/$hMachineConfiguration{'szGuestName'}.qcow2";
# TODO V put this in a proctected subdir.
my $f_szInstanceNumber = "001";
$hMachineConfiguration{'szIsoImage'} = "/var/$hMachineConfiguration{'szGuestName'}${f_szInstanceNumber}-cidata.iso";

my @arPublicNetworkList = (
  'virbr0',
);
$hMachineConfiguration{'arPublicNetworkList'} = \@arPublicNetworkList;

my @arPrivateNetworkList = (
  'nm',
  'cont1',
  'cont2',
  'zczc',
);

$hMachineConfiguration{'arPrivateNetworkList'} = \@arPrivateNetworkList;


# ----------------------------------------------------
# See: http://www.projectatomic.io/blog/2014/10/getting-started-with-cloud-init/
# ------------------
sub GenerateCloudInitIsoImage {
  my $szDomainName = shift; 
  my $szInstanceNumber = shift;
  # TODO N Barf on missing data.
  # TODO V Barf on IDs already in use.

  Log("III write: meta-data");
  # TODO V Write these files to a unique subdirectory so that multiple operations can be done in parallel.
  open(METADATA, ">meta-data") || die("!!! Failed to open for write: 'meta-data' - $!");
  print METADATA "instance-id: $szDomainName$szInstanceNumber\n";
  print METADATA "local-hostname: $szDomainName-$szInstanceNumber\n";
  close(METADATA);

  if ( ! -f  "${f_szGeneralContainerKeyFile}.pub" ) {
    DieIfExecuteFails("ssh-keygen -f ${f_szGeneralContainerKeyFile} -t rsa -N \"\"");
  }

  my $szSshPublicKey = `cat ${f_szGeneralContainerKeyFile}.pub`;
  chomp($szSshPublicKey);

  my $szGlobalYamlGzipBin = `base64 --wrap=0 ${szFilesPath}/global.yaml.gz`;
  #my @arGlobalYamlGzipBinBase64List = `base64 --wrap=0 ${szFilesPath}/global.yaml.gz`;
  #my $szGlobalYamlGzipBin = join('', @arGlobalYamlGzipBinBase64List);

  Log("III write: user-data");
  open(USERDATA, ">user-data") || die("!!! Failed to open for write: 'user-data' - $!");
  print USERDATA "#cloud-config\n";
  print USERDATA "users:\n";
  print USERDATA "  - name: vagrant\n";
  print USERDATA "    gecos: generic administration.\n";
  print USERDATA "    sudo: ALL=(ALL) NOPASSWD:ALL\n";
  print USERDATA "    groups: adm,wheel,systemd-journal\n";
  print USERDATA "    lock-passwd: true\n";
  print USERDATA "    chpasswd: { expire: False }\n";
  print USERDATA "    ssh_pwauth: True\n";
  print USERDATA "    ssh_authorized_keys:\n";
  print USERDATA "      - $szSshPublicKey\n";
  print USERDATA "\n";
  print USERDATA "write_files:\n";
  print USERDATA "  - path: /etc/puppet/data/global.yaml\n";
  print USERDATA "    permissions: 0644\n";
  print USERDATA "    owner: root\n";
  print USERDATA "    encoding: gzip+base64\n";
  print USERDATA "    content: |\n";
#  print USERDATA "    content: !!binary |\n";
  print USERDATA "      $szGlobalYamlGzipBin\n";
  print USERDATA "\n";
  print USERDATA "\n";
  print USERDATA "\n";
  print USERDATA "\n";
  close(USERDATA);

  Log("III Generate ISO image: $hMachineConfiguration{'szIsoImage'}");
  DieIfExecuteFails("genisoimage -output $hMachineConfiguration{'szIsoImage'} -volid cidata -joliet -rock user-data meta-data");
}


GenerateCloudInitIsoImage($hMachineConfiguration{'szGuestName'}, $f_szInstanceNumber);

# ====================================== MAIN ============================================ 
my $uri = 'qemu:///system';
my $vmm = Sys::Virt->new(uri => $uri);
my $dom = $vmm->get_domain_by_name($f_szFedoraBaseName);
my $flags=0;
my $xml = $dom->get_xml_description($flags);
my  $ref = XMLin($xml);


print "---------------------\n";
my $szTemplateFile = "$szTemplatePath/vrouter_xml.tmpl";
#my $szTemplateFile = "$szTemplatePath/test.tmpl";

my $template = Text::Template->new(TYPE => 'FILE', SOURCE => "$szTemplateFile")
         or die "Couldn't construct template: $Text::Template::ERROR";

#print "DDD szTemplateFile: $szTemplateFile\n";
#print "DDD template: $template\n";
#print Dumper($template);

my $szResult = $template->fill_in(HASH => \%hMachineConfiguration);
# print $szResult ;
 
Log("III Writing: $hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml");
open (OUTPUT_TEMPLATE, ">$hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml") || die("!!! failed to open file for write: $hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml - $!");
print OUTPUT_TEMPLATE "$szResult";
close(OUTPUT_TEMPLATE);


# TODO Also support LVM.
if ( $hMachineConfiguration{'szGuestDriverType'} eq 'qcow2' ) {
  # TODO Get the driver to make sure it is a 'qcow2'.
  my $szBackingFileQcow2 = $ref->{'devices'}{'disk'}{'source'}{'file'};

  Log("III Cloning  image from $f_szFedoraBaseName for use by $hMachineConfiguration{'szGuestName'} to $hMachineConfiguration{'szGuestStorageDevice'}");
  DieIfExecuteFails("qemu-img create -f qcow2 -o backing_file=$szBackingFileQcow2 $hMachineConfiguration{'szGuestStorageDevice'}");

  #Log("III Cloning $f_szFedoraBaseName for use by $hMachineConfiguration{'szGuestName'} to $hMachineConfiguration{'szGuestStorageDevice'}");
  #DieIfExecuteFails("virt-clone --connect qemu:///system --original $f_szFedoraBaseName --name $hMachineConfiguration{'szGuestName'} --file $hMachineConfiguration{'szGuestStorageDevice'}");
  #DieIfExecuteFails("virt-clone --connect qemu:///system --original baseks --name vrouter --file /virt_images/vrouter.qcow2");
  #DieIfExecuteFails("virt-clone --connect qemu:///system --original $f_szFedoraBaseName --name $hMachineConfiguration{'szGuestName'} --file $hMachineConfiguration{'szGuestStorageDevice'}");

  Log("III Create the instance of $hMachineConfiguration{'szGuestName'}");
  DieIfExecuteFails("virsh define --file $hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml");
}

# TODO Generate the configuration ISO image.
# Provide the image to the container, or should that be part of the XML generation?

Log("III Done.\n");
