package InfoExecute;
use strict;

################################################################################
#
#                         P E R L   M O D U L E
#
################################################################################
#
#   DATE OF ORIGIN  : Mar 18, 2015
#
#----------------------------------- PURPOSE ------------------------------------
#** @file InfoExecute.pm
#
# This module will
#
#*
#----------------------------------- SYNOPSIS -----------------------------------
#    CAUTIONS:
#
#    ASSUMPTIONS/PRECONDITIONS:
#
#    POSTCONDITIONS:
#
#    PARAMETER DESCRIPTION:
#        Input:
#
#
#        Return value:
#            none
#
#
#--------------------------- GLOBAL DATA DESCRIPTION ----------------------------
#---------------------------- PROJECT SPECIFIC DATA -----------------------------
#
#---------------------------- DESCRIPTION OF LOGIC ------------------------------
#
#
################################################################################

use vars qw(@ISA @EXPORT $VERSION);
use Exporter;
use Carp;
use Data::Dumper;
use Sys::Virt;
use Sys::Virt::Domain;
use Text::Template;

use ExecuteAndTrace;

$VERSION = 0.1.0;
@ISA     = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
  &IEGetBackingFile
  &IEGenerateCloudInitIsoImage
  &IECreateInstance
);

# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================

# ==============================================================================
#                               F U N C T I O N S
# ==============================================================================

# -----------------------------------------------------------------
#** @function public IEGetBackingFile
# @brief Returns the qcow2 storage file name for the BaseDomainName given in the %InstanceConfiguration.
#
# A detailed description of the function
# @params \%InstanceConfiguration
# @retval value [details]
# ....
#*
# ---------------
sub IEGetBackingFile {
  my $refhInstanceConfiguration = shift;

  my $uri = 'qemu:///system';
  my $vmm = Sys::Virt->new( uri => $uri );
  my $dom =
    $vmm->get_domain_by_name( $refhInstanceConfiguration->{'BaseDomainName'} );
  my $flags = 0;
  my $xml   = $dom->get_xml_description($flags);
  my $ref   = XMLin($xml);

  # TODO Get the driver to make sure it is a 'qcow2'.
  my $szBackingFileQcow2 = $ref->{'devices'}{'disk'}{'source'}{'file'};

  return ($szBackingFileQcow2);
}

# ----------------------------------------------------
# This functions genrates the ISO file used by cloud-init
#  The two files:
#     - meta-data
#     - user-data
#
# See: http://www.projectatomic.io/blog/2014/10/getting-started-with-cloud-init/
# ------------------
sub IEGenerateCloudInitIsoImage {
  my $refhCombinedInstanceAndWrapperConf = shift;
  my $refhVirmanConfiguration            = shift;
  my $refhMachineConfiguration           = shift;
  my $szInstanceNumber                   = shift;

  # TODO N Barf on missing data.
  # TODO V Barf on IDs already in use.

  my %hCombinedInstanceAndWrapperConf = %{$refhCombinedInstanceAndWrapperConf};

  my $szDomainName = $refhMachineConfiguration->{'szGuestName'};

  Log("III write: meta-data");

# TODO V Write these files to a unique subdirectory so that multiple operations can be done in parallel.
  open( METADATA, ">meta-data" )
    || die("!!! Failed to open for write: 'meta-data' - $!");
  print METADATA "instance-id: $szDomainName$szInstanceNumber\n";
  print METADATA "local-hostname: $szDomainName-$szInstanceNumber\n";
  close(METADATA);

  my $szGeneralContainerKeyFile = "$refhVirmanConfiguration->{'SshRelativePath'}/virman";
  if ( !-f "${szGeneralContainerKeyFile}.pub" ) {
    DieIfExecuteFails("ssh-keygen -f ${szGeneralContainerKeyFile} -t rsa -N \"\"");
  }
  
  my $szSshPublicKey = `cat ${szGeneralContainerKeyFile}.pub`;
  chomp($szSshPublicKey);

  my $szAdminName = 'vagrant';
  if ( exists( $hCombinedInstanceAndWrapperConf{'NameOfAdminUserAccount'} ) ) {
    $szAdminName = $hCombinedInstanceAndWrapperConf{'NameOfAdminUserAccount'};
  }

#my $szGlobalYamlGzipBin = `base64 --wrap=0 ${szFilesPath}/global.yaml.gz`;
#my @arGlobalYamlGzipBinBase64List = `base64 --wrap=0 ${szFilesPath}/global.yaml.gz`;
#my $szGlobalYamlGzipBin = join('', @arGlobalYamlGzipBinBase64List);

  Log("III write: user-data");
  open( USERDATA, ">user-data" )
    || die("!!! Failed to open for write: 'user-data' - $!");
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

  if ( exists( $hCombinedInstanceAndWrapperConf{'FileProvidedDuringCloudInit'} ) ) {
    print USERDATA "write_files:\n";
    foreach my $refFileEntry (
      @{ $hCombinedInstanceAndWrapperConf{'FileProvidedDuringCloudInit'} } )
    {
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
  if ( exists( $hCombinedInstanceAndWrapperConf{'RunCommand'} ) ) {
    print USERDATA "runcmd:\n";
    foreach my $szRunCmd ( @{ $hCombinedInstanceAndWrapperConf{'RunCommand'} } ) {
      print USERDATA "  - $szRunCmd\n";
    }
    print USERDATA "\n";
  }
  print USERDATA "\n";

  # TODO V Add a phone_home, possibly with the IP address of this instance???
  print USERDATA "\n";
  close(USERDATA);

  Log("III Generate ISO image: $refhMachineConfiguration->{'szIsoImage'}");
  DieIfExecuteFails(
"genisoimage -output $refhMachineConfiguration->{'szIsoImage'} -volid cidata -joliet -rock user-data meta-data"
  );

  #die("!!! testing exit.");
  # Returning 0 since we did not die.
  return(0);
}

# -----------------------------------------------------------------
#** @function public IECreateInstance
# @brief Create the clone instance.
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub IECreateInstance {
  my $refhCombinedInstanceAndWrapperConf = shift;
  my $refhMachineConfiguration           = shift;
  my $szTemplatePath                     = shift;
  my $szBackingFileQcow2                 = shift;

  # TODO V verify the template exists: $szTemplatePath

  my $szTemplateFile = "$szTemplatePath/domain_xml.tmpl";

  my $template =
    Text::Template->new( TYPE => 'FILE', SOURCE => "$szTemplateFile" )
    or die "Couldn't construct template: $Text::Template::ERROR";

  my %hMachineConfiguration = %{$refhMachineConfiguration};
  my $szResult = $template->fill_in( HASH => \%hMachineConfiguration );

  # print $szResult ;

  # TODO C Somewhere fill in the network list.

  Log("III Writing: $refhMachineConfiguration->{'szGasBaseDirectory'}/$refhMachineConfiguration->{'szGuestName'}.xml");
  open( OUTPUT_TEMPLATE,">$refhMachineConfiguration->{'szGasBaseDirectory'}/$refhMachineConfiguration->{'szGuestName'}.xml")  || die("!!! failed to open file for write: $refhMachineConfiguration->{'szGasBaseDirectory'}/$refhMachineConfiguration->{'szGuestName'}.xml - $!");
  print OUTPUT_TEMPLATE "$szResult";
  close(OUTPUT_TEMPLATE);

  #die("!!! Template written, see name above.");

  # TODO Also support LVM.
  if ( $refhMachineConfiguration->{'szGuestDriverType'} eq 'qcow2' ) {

    Log("III Cloning  image from $refhCombinedInstanceAndWrapperConf->{'BaseDomainName'} for use by $refhMachineConfiguration->{'szGuestName'} to $refhMachineConfiguration->{'szGuestStorageDevice'}");
    DieIfExecuteFails("qemu-img create -f qcow2 -o backing_file=$szBackingFileQcow2 $refhMachineConfiguration->{'szGuestStorageDevice'}");

    #Log("III Cloning $hRoleConfiguration{'BaseDomainName'} for use by $hMachineConfiguration{'szGuestName'} to $hMachineConfiguration{'szGuestStorageDevice'}");
    #DieIfExecuteFails("virt-clone --connect qemu:///system --original $hRoleConfiguration{'BaseDomainName'} --name $hMachineConfiguration{'szGuestName'} --file $hMachineConfiguration{'szGuestStorageDevice'}");
    #DieIfExecuteFails("virt-clone --connect qemu:///system --original $f_szFedoraBaseName --name $hMachineConfiguration{'szGuestName'} --file $f_hMachineConfiguration{'szGuestStorageDevice'}");

    Log("III Create the instance of $refhMachineConfiguration->{'szGuestName'}");
    # TODO V change to use the Sys::Virt::Domain
    DieIfExecuteFails("virsh define --file $refhMachineConfiguration->{'szGasBaseDirectory'}/$refhMachineConfiguration->{'szGuestName'}.xml");
  }

  # TODO Generate the configuration ISO image.
  # Provide the image to the container, or should that be part of the XML generation?
  return(0);
}

# This ends the perl module/package definition.
1;