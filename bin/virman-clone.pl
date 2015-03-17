#!/usr/bin/perl -w

use strict;

# Purpose: create a machine instance, base on a given base machine and template.
# TODO provide template name in CLI.

# Steps:
#  Generate the machine definition in /opt/gas/

use FindBin;
BEGIN{
	  push( @INC, "$FindBin::RealBin" );    ## Path to local modules
}

use Data::Dumper;
use Text::Template;
use ExecuteAndTrace;
use Sys::Virt;
use Sys::Virt::Domain;
use XML::Simple;


use ConfiguredNetworks;
use Default;
use InstanceConfiguration;



my %f_hVirmanConfiguration;
my $f_szVirmanConfigurationFile = "/etc/virman/default.xml";

my $f_szInstanceNumber = "001";

my $szTemplatePath = "$FindBin::RealBin/../templates";
my $szFilesPath = "$FindBin::RealBin/../files";

# TODO C put this in a protected directory.
my $f_szGeneralContainerKeyFile;

my $szVirshFilePoolPath = '/virt_images';

my %f_hMachineConfiguration;

# TODO V Read the networks that have been configured to validate the ones
#         the apps are asking for.



# ======================================= FUNCTIONS ================================
# ----------------------------------------------------
#** @function LoadVirmanConfiguration
# @brief Will load select values from /etc/virman/defaults.xml and store in the given hashref.
#
# This function should be called prior to any other other instance operations,
#  so that all the base directories are in place.
#
# @params refConfHash - Reference to the configuration hash. Will be updated witht he values.
# @params szFileName - the name of the defaults.xml file.
#*
# ----------------------------------------------------
sub LoadVirmanConfiguration {
  my $refConfHash = shift;
  my $szFileName = shift;

  # TODO verify the XML file exists.
  my $xmlTree = DefaultLoadXml($szFileName);
  
  
  $refConfHash->{'BaseStoragePath'}     = DefaultGetBaseStoragePath($xmlTree);
  $refConfHash->{'InstallWrapperPath'}  = DefaultGetInstallWrapperPath($xmlTree);
  $refConfHash->{'SshPath'}             = DefaultGetSshPath($xmlTree);
  $refConfHash->{'CloudInitIsoFiles'}   = DefaultGetCloudInitIsoFilesPath($xmlTree);
  $refConfHash->{'InstanceCfgBasePath'} =  DefaultGetInstanceCfgBasePath($xmlTree);

  #print Dumper($refConfHash);
  #die("!!! test end.");
}


# ----------------------------------------------------
#** @function ReadInstanceConfiguration
# @brief 
#
# @params refConfHash - The hash where the values are added to.
# @parmas szFileName - name of the XML file that contains the Instance configuration.
#*  
# ----------------------------------------------------
sub ReadInstanceConfiguration {
  my $refConfHash = shift;
  my $szFileName = shift;

  # TODO verify the XML file exists.
  my $xmlTree = InstCfgLoadXml($szFileName);

  $refConfHash->{'Description'} = GetDescription($xmlTree);
  $refConfHash->{'BaseDomainName'} = GetBaseDomainName($xmlTree);
  $refConfHash->{'NameOfAdminUserAccount'}   = GetNameOfAdminUserAccount($xmlTree);

  # TODO V only read it if it is defined?
  $refConfHash->{'InstallWrapper'} = InstCfgGetInstallWrapper($xmlTree);

  #print Dumper($xmlTree);
  my %hNetworkConfiguration = InstCfgGetNetworkHash($xmlTree);

  #print Dumper(\%hNetworkConfiguration);

  $refConfHash->{'NetworkConfiguration'} = \%hNetworkConfiguration;

  # TODO C Also provide functions: GetBaseDomainNameIfAvailable, where it is:
  # GetBaseDomainNameIfAvailable($xmlTree, $refConfHash->{'BaseDomainName'});
  # where the hash ref will be set if the data is available. Can I do it like this or would it have to be:
  # GetBaseDomainNameIfAvailable($xmlTree, $refConfHash, 'BaseDomainName');

  #die("!!! TODO read the network info as well.");
  #Remember to also generate the global.yaml file.

  # Get the file for installation.
  # TODO C Get the run commands.
  #print Dumper($refConfHash);
  #print "------------------------------------\n";
  #print Dumper($config);

  #print "DDD $refConfHash->{'NameOfAdminUserAccount'}\n";
  #die("!!! test end.");
}

# ----------------------------------------------------
# This functions genrates the ISO file used by cloud-init
#  The two files: 
#     - meta-data
#     - user-data
#
# See: http://www.projectatomic.io/blog/2014/10/getting-started-with-cloud-init/
# ------------------
sub GenerateCloudInitIsoImage {
  my $refhRoleConfiguration = shift;
  my $refhVirmanConfiguration = shift;
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

  ${f_szGeneralContainerKeyFile} = "$f_hVirmanConfiguration{'SshRelativePath'}/virman";
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

  Log("III Generate ISO image: $f_hMachineConfiguration{'szIsoImage'}");
  DieIfExecuteFails("genisoimage -output $f_hMachineConfiguration{'szIsoImage'} -volid cidata -joliet -rock user-data meta-data");
  #die("!!! testing exit.");
}


# ----------------------------------------------------
# This function populates the $refhMachineConfiguration, which is used for
#   filling in the domain.xml file, in the template file.
#
# @params $refhMachineConfiguration - reference to the hash that will be given to the domain.xml text texmplate.
# @params $refhVirmanConfiguration - The virman /etc/virman/defaults.xml.
# @params $refhInstanceConfiguration - The instance configuration.
#    TODO V Later merge this inst-conf with the install_wrapper file.
# ----------------------------------------------------
sub SetMachineConfiguration {
  my $refhMachineConfiguration = shift;
  my $refhVirmanConfiguration = shift;
  my $refhInstanceConfiguration = shift;
  my $szDomainName = shift;

  $refhMachineConfiguration->{'szGuestName'} = $szDomainName;

# TODO C Support a dir for the instance machine dom.xml files.
  $refhMachineConfiguration->{'szGasBaseDirectory'} = '/opt/gas';

  # TODO title and description should be retrieved from the role.xml file.
  $refhMachineConfiguration->{'szGuestTitle'} = "Virtual $szDomainName";
  # TODO V Take the description from the Instance conf description.
  if ( exists($refhInstanceConfiguration->{'Description'}) ) {
  	$refhMachineConfiguration->{'szGuestDescription'} = $refhInstanceConfiguration->{'Description'};
  } else {
  	$refhMachineConfiguration->{'szGuestDescription'} = "Virtual $szDomainName.";  	
  }
 
  # The amount of memory allocate to the Guest in KiB.
  $refhMachineConfiguration->{'szGuestMemory'} = '786432';

  # file: cqow2
  $refhMachineConfiguration->{'szGuestDiskType'} = 'file';

  $refhMachineConfiguration->{'szGuestDriverType'} = 'qcow2';

  $refhMachineConfiguration->{'szGuestDiskSourceTypeName'} = 'file';
  $refhMachineConfiguration->{'szGuestStorageDevice'} = "${szVirshFilePoolPath}/$refhMachineConfiguration->{'szGuestName'}.qcow2";
  # TODO V put this in a proctected subdir.
  $refhMachineConfiguration->{'szIsoImage'} = "$refhVirmanConfiguration->{'CloudInitIsoFiles'}/$refhMachineConfiguration->{'szGuestName'}${f_szInstanceNumber}-cidata.iso";
  
  # The Network list.
  # Sort the sub hash: NetworkConfiguration
  my @arBridgeTypeNetworkList;
  my @arPrivateNetworkTypeNetworkList;
  
  #print Dumper(%{$refhInstanceConfiguration->{'NetworkConfiguration'}});
  #foreach my $refNetwork ( sort keys %{$refhInstanceConfiguration->{'NetworkConfiguration'}} ) {
  foreach my $refNetwork ( sort keys $refhInstanceConfiguration->{'NetworkConfiguration'} ) {
  	# TODO V Later figure out if the refNetwork goes into the bridge or the network list. 
        print "---\n";
  	push(@arPrivateNetworkTypeNetworkList, $refhInstanceConfiguration->{'NetworkConfiguration'}{$refNetwork}{'Name'});
  }

  $refhMachineConfiguration->{'arPublicNetworkList'} = \@arBridgeTypeNetworkList;
  $refhMachineConfiguration->{'arPrivateNetworkList'} = \@arPrivateNetworkTypeNetworkList;

  #print Dumper($refhMachineConfiguration);
  #die("!!! TEST END.");
}


# ====================================== MAIN ============================================ 

my $szDomainName = shift || die("!!! You must provide a role name.");


# TODO Support list the supported roles.
# TODO Support manual instance number?

LoadVirmanConfiguration(\%f_hVirmanConfiguration, $f_szVirmanConfigurationFile);

my $szXmlConfigurationFilename = "$f_hVirmanConfiguration{'InstanceCfgBasePath'}/${szDomainName}/${szDomainName}.xml";

if ( ! -f "$szXmlConfigurationFilename" ) {
  die("!!! Domain name '$szDomainName' does not have a role.xml file in $f_hVirmanConfiguration{'RolesRelativePath'}");
}

my %hInstanceConfiguration;
ReadInstanceConfiguration(\%hInstanceConfiguration, $szXmlConfigurationFilename);

SetMachineConfiguration(\%f_hMachineConfiguration, \%f_hVirmanConfiguration, \%hInstanceConfiguration, $szDomainName);


# TODO C Read the InstallWrapper is given.
# ReadInsatllWrapper

# TODO C Merge the InstallWrapper hash and the instance configuration.

GenerateCloudInitIsoImage(\%hInstanceConfiguration, \%f_hVirmanConfiguration, $f_hMachineConfiguration{'szGuestName'}, $f_szInstanceNumber);


my $uri = 'qemu:///system';
my $vmm = Sys::Virt->new(uri => $uri);
my $dom = $vmm->get_domain_by_name($hInstanceConfiguration{'BaseDomainName'});
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

my $szResult = $template->fill_in(HASH => \%f_hMachineConfiguration);
# print $szResult ;

# TODO C Somewhere fill in the network list.
 
Log("III Writing: $f_hMachineConfiguration{'szGasBaseDirectory'}/$f_hMachineConfiguration{'szGuestName'}.xml");
open (OUTPUT_TEMPLATE, ">$f_hMachineConfiguration{'szGasBaseDirectory'}/$f_hMachineConfiguration{'szGuestName'}.xml") || die("!!! failed to open file for write: $f_hMachineConfiguration{'szGasBaseDirectory'}/$f_hMachineConfiguration{'szGuestName'}.xml - $!");
print OUTPUT_TEMPLATE "$szResult";
close(OUTPUT_TEMPLATE);

#die("!!! Template written, see name above.");

# TODO Also support LVM.
if ( $f_hMachineConfiguration{'szGuestDriverType'} eq 'qcow2' ) {
  # TODO Get the driver to make sure it is a 'qcow2'.
  my $szBackingFileQcow2 = $ref->{'devices'}{'disk'}{'source'}{'file'};

  Log("III Cloning  image from $hInstanceConfiguration{'BaseDomainName'} for use by $f_hMachineConfiguration{'szGuestName'} to $f_hMachineConfiguration{'szGuestStorageDevice'}");
  DieIfExecuteFails("qemu-img create -f qcow2 -o backing_file=$szBackingFileQcow2 $f_hMachineConfiguration{'szGuestStorageDevice'}");

  #Log("III Cloning $hRoleConfiguration{'BaseDomainName'} for use by $hMachineConfiguration{'szGuestName'} to $hMachineConfiguration{'szGuestStorageDevice'}");
  #DieIfExecuteFails("virt-clone --connect qemu:///system --original $hRoleConfiguration{'BaseDomainName'} --name $hMachineConfiguration{'szGuestName'} --file $hMachineConfiguration{'szGuestStorageDevice'}");
  #DieIfExecuteFails("virt-clone --connect qemu:///system --original $f_szFedoraBaseName --name $hMachineConfiguration{'szGuestName'} --file $f_hMachineConfiguration{'szGuestStorageDevice'}");

  Log("III Create the instance of $f_hMachineConfiguration{'szGuestName'}");
  DieIfExecuteFails("virsh define --file $f_hMachineConfiguration{'szGasBaseDirectory'}/$f_hMachineConfiguration{'szGuestName'}.xml");
}

# TODO Generate the configuration ISO image.
# Provide the image to the container, or should that be part of the XML generation?

Log("III Done.\n");
