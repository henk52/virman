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

my %f_hVirmanConfiguration;
my $f_szVirmanConfigurationFile = "/etc/virman/default.xml";

my $f_szInstanceNumber = "001";

my $szTemplatePath = "$FindBin::RealBin/../templates";
my $szFilesPath = "$FindBin::RealBin/../files";

# TODO C put this in a protected directory.
my $f_szGeneralContainerKeyFile = "/etc/bilby_rsa";

my $szVirshFilePoolPath = '/virt_images';

my %hMachineConfiguration;

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

# ======================================= FUNCTIONS ================================
# ----------------------------------------------------
# ----------------------------------------------------
sub LoadVirmanConfiguration {
  my $refConfHash = shift;
  my $szFileName = shift;

  # TODO verify the XML file exists.
  my $config = XMLin($szFileName);
  
  $refConfHash->{'BaseStoragePath'}   = $config->{'BaseStoragePath'};
  $refConfHash->{'RolesRelativePath'} = $config->{'RolesRelativePath'};
  $refConfHash->{'SshRelativePath'}   = $config->{'SshRelativePath'};
  $refConfHash->{'CloudInitIsoFiles'} = $config->{'CloudInitIsoFiles'};

  #print Dumper($config);
  #die("!!! test end.");
}

# ----------------------------------------------------
# ----------------------------------------------------
sub ReadRoleConfiguration {
  my $refConfHash = shift;
  my $szFileName = shift;

  # TODO verify the XML file exists.
  my $config = XMLin($szFileName, ForceArray => 1);
  
  if ( exists($config->{'NameOfAdminUserAccount'}) ) {
    $refConfHash->{'NameOfAdminUserAccount'}   = ${$config->{'NameOfAdminUserAccount'}}[0];
  }

  if ( exists($config->{'BaseDomainName'}) ) {
    $refConfHash->{'BaseDomainName'}   = ${$config->{'BaseDomainName'}}[0];
  }

  if ( exists($config->{'RunCommand'}) ) {
    my @arRunCommand   = $config->{'RunCommand'};
    #$refConfHash->{'RunCommand'} = \@arRunCommand;
    $refConfHash->{'RunCommand'} = $config->{'RunCommand'};
  }
  if ( exists($config->{'FileProvidedDuringCloudInit'}) ) {
    my @arFileEntries;
    foreach my $refFileEntry (@{$config->{'FileProvidedDuringCloudInit'}}) {
      my %hFileEntry;
      $hFileEntry{'SourceFile'}      = ${$refFileEntry->{'SourceFile'}}[0];
      $hFileEntry{'SourceType'}      = ${$refFileEntry->{'SourceType'}}[0];
      # TODO C Also support !!binary
      $hFileEntry{'DestinationFile'} = ${$refFileEntry->{'DestinationFile'}}[0];
      push(@arFileEntries, \%hFileEntry);
    }
    $refConfHash->{'FileProvidedDuringCloudInit'}   = \@arFileEntries;
  }

  #print Dumper($refConfHash);
  #print Dumper($config);

  #print "DDD $refConfHash->{'NameOfAdminUserAccount'}\n";
  #die("!!! test end.");
}

# ----------------------------------------------------
# See: http://www.projectatomic.io/blog/2014/10/getting-started-with-cloud-init/
# ------------------
sub GenerateCloudInitIsoImage {
  my $refhRoleConfiguration = shift;
  my $szDomainName = shift; 
  my $szInstanceNumber = shift;
  # TODO N Barf on missing data.
  # TODO V Barf on IDs already in use.

  my %hRoleConfiguration = %{$refhRoleConfiguration};

  Log("III write: meta-data");
  # TODO V Write these files to a unique subdirectory so that multiple operations can be done in parallel.
  open(METADATA, ">meta-data") || die("!!! Failed to open for write: 'meta-data' - $!");
  print METADATA "instance-id: $szDomainName$szInstanceNumber\n";
  print METADATA "local-hostname: $szDomainName-$szInstanceNumber\n";
  close(METADATA);

  ${f_szGeneralContainerKeyFile} = "$f_hVirmanConfiguration{'SshRelativePath'}/bilby";
  if ( ! -f  "${f_szGeneralContainerKeyFile}.pub" ) {
    DieIfExecuteFails("ssh-keygen -f ${f_szGeneralContainerKeyFile} -t rsa -N \"\"");
  }

  my $szSshPublicKey = `cat ${f_szGeneralContainerKeyFile}.pub`;
  chomp($szSshPublicKey);

  
  my $szAdminName = 'vagrant';
  if ( exists($hRoleConfiguration{'NameOfAdminUserAccount'}) ) {
    $szAdminName = $hRoleConfiguration{'NameOfAdminUserAccount'};
  }

  #my $szGlobalYamlGzipBin = `base64 --wrap=0 ${szFilesPath}/global.yaml.gz`;
  #my @arGlobalYamlGzipBinBase64List = `base64 --wrap=0 ${szFilesPath}/global.yaml.gz`;
  #my $szGlobalYamlGzipBin = join('', @arGlobalYamlGzipBinBase64List);

  Log("III write: user-data");
  open(USERDATA, ">user-data") || die("!!! Failed to open for write: 'user-data' - $!");
  print USERDATA "#cloud-config\n";
  print USERDATA "users:\n";
  print USERDATA "  - name: $szAdminName\n";
  print USERDATA "    gecos: generic administration.\n";
  # TODO this needs to be dependent on the OS family.
  print USERDATA "    sudo: ALL=(ALL) NOPASSWD:ALL\n";
  print USERDATA "    groups: adm,wheel,systemd-journal\n";
  print USERDATA "    lock-passwd: true\n";
  print USERDATA "    chpasswd: { expire: False }\n";
  print USERDATA "    ssh_pwauth: True\n";
  print USERDATA "    ssh_authorized_keys:\n";
  print USERDATA "      - $szSshPublicKey\n";
  print USERDATA "\n";
  if ( exists($hRoleConfiguration{'FileProvidedDuringCloudInit'}) ) {
    print USERDATA "write_files:\n";
    foreach my $refFileEntry ( @{$hRoleConfiguration{'FileProvidedDuringCloudInit'}} ) {
      print USERDATA "  - path: $refFileEntry->{'DestinationFile'}\n";
      print USERDATA "    permissions: 0644\n";
      print USERDATA "    owner: root\n";
      print USERDATA "    encoding: $refFileEntry->{'SourceType'}\n";
      print USERDATA "    content: |\n";
    #  print USERDATA "    content: !!binary |\n";
      my $szBase64Encoding = `base64 --wrap=0 $refFileEntry->{'SourceFile'}`;
      print USERDATA "      $szBase64Encoding\n";
    }
    print USERDATA "\n";
  }
  if ( exists($hRoleConfiguration{'RunCommand'}) ) {
    print USERDATA "runcmd:\n";
    foreach my $szRunCmd ( @{$hRoleConfiguration{'RunCommand'}} ) {
      print USERDATA "  - $szRunCmd\n";
    }
    print USERDATA "\n";
  }
  print USERDATA "\n";
  # TODO V Add a phone_home
  print USERDATA "\n";
  close(USERDATA);

  Log("III Generate ISO image: $hMachineConfiguration{'szIsoImage'}");
  DieIfExecuteFails("genisoimage -output $hMachineConfiguration{'szIsoImage'} -volid cidata -joliet -rock user-data meta-data");
  #die("!!! testing exit.");
}


sub SetMachineConfiguration {
  my $refhMachineConfiguration = shift;
  my $refhVirmanConfiguration = shift;
  my $szDomainName = shift;

  $hMachineConfiguration{'szGuestName'} = $szDomainName;

# TODO C Support a dir for the instance machine dom.xml files.
  $hMachineConfiguration{'szGasBaseDirectory'} = '/opt/gas';

  # TODO title and description should be retrieved from the role.xml file.
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
  $hMachineConfiguration{'szIsoImage'} = "$refhVirmanConfiguration->{'CloudInitIsoFiles'}/$hMachineConfiguration{'szGuestName'}${f_szInstanceNumber}-cidata.iso";

}


# ====================================== MAIN ============================================ 

my $szDomainName = shift || die("!!! You must provide a role name.");


# TODO Support list the supported roles.
# TODO Support manual instance number?


LoadVirmanConfiguration(\%f_hVirmanConfiguration, $f_szVirmanConfigurationFile);

if ( ! -f "$f_hVirmanConfiguration{'RolesRelativePath'}/${szDomainName}.xml" ) {
  die("!!! Domain name '$szDomainName' does not have a role.xml file in $f_hVirmanConfiguration{'RolesRelativePath'}");
}

SetMachineConfiguration(\%hMachineConfiguration, \%f_hVirmanConfiguration, $szDomainName);

my %hRoleConfiguration;
ReadRoleConfiguration(\%hRoleConfiguration, "$f_hVirmanConfiguration{'RolesRelativePath'}/${szDomainName}.xml");


GenerateCloudInitIsoImage(\%hRoleConfiguration, \%f_hVirmanConfiguration, $hMachineConfiguration{'szGuestName'}, $f_szInstanceNumber);


my $uri = 'qemu:///system';
my $vmm = Sys::Virt->new(uri => $uri);
my $dom = $vmm->get_domain_by_name($hRoleConfiguration{'BaseDomainName'});
my $flags=0;
my $xml = $dom->get_xml_description($flags);
my  $ref = XMLin($xml);


print "---------------------\n";
my $szTemplateFile = "$szTemplatePath/domain_xml.tmpl";

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

  Log("III Cloning  image from $hRoleConfiguration{'BaseDomainName'} for use by $hMachineConfiguration{'szGuestName'} to $hMachineConfiguration{'szGuestStorageDevice'}");
  DieIfExecuteFails("qemu-img create -f qcow2 -o backing_file=$szBackingFileQcow2 $hMachineConfiguration{'szGuestStorageDevice'}");

  #Log("III Cloning $hRoleConfiguration{'BaseDomainName'} for use by $hMachineConfiguration{'szGuestName'} to $hMachineConfiguration{'szGuestStorageDevice'}");
  #DieIfExecuteFails("virt-clone --connect qemu:///system --original $hRoleConfiguration{'BaseDomainName'} --name $hMachineConfiguration{'szGuestName'} --file $hMachineConfiguration{'szGuestStorageDevice'}");
  #DieIfExecuteFails("virt-clone --connect qemu:///system --original $f_szFedoraBaseName --name $hMachineConfiguration{'szGuestName'} --file $hMachineConfiguration{'szGuestStorageDevice'}");

  Log("III Create the instance of $hMachineConfiguration{'szGuestName'}");
  DieIfExecuteFails("virsh define --file $hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml");
}

# TODO Generate the configuration ISO image.
# Provide the image to the container, or should that be part of the XML generation?

Log("III Done.\n");
