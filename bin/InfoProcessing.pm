package InfoProcessing;
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
#** @file InfoProcessing.pm
#
# This module will handle/process the information that has been gathered.
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



$VERSION = 0.1.0;
@ISA = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
                &IPMergeInstanceAndWrapperInfo
                &IPSetMachineConfiguration
            );


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                               F U N C T I O N S
# ==============================================================================


# -----------------------------------------------------------------
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief Merge the Instance info and the, optional, install wrapper information.
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub IPMergeInstanceAndWrapperInfo {
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
sub IPSetMachineConfiguration {
  my $refhMachineConfiguration = shift;
  my $refhVirmanConfiguration = shift;
  my $refhInstanceConfiguration = shift;
  my $szDomainName = shift;
  my $szInstanceNumber = shift;

  $refhMachineConfiguration->{'szGuestName'} = $szDomainName;

# TODO C Support a dir for the instance machine dom.xml files.
  #$refhMachineConfiguration->{'szGasBaseDirectory'} = '/opt/gas';

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
  # TODO V When more than qcow is suppoerd the QcowFilePoolPath has to be interchangable iwth eg.g. LVMFilePoolPath.
  $refhMachineConfiguration->{'szGuestStorageDevice'} = "$refhVirmanConfiguration->{'QcowFilePoolPath'}/$refhMachineConfiguration->{'szGuestName'}.qcow2";
  # TODO V put this in a proctected subdir.
  $refhMachineConfiguration->{'szIsoImage'} = "$refhVirmanConfiguration->{'CloudInitIsoFiles'}/$refhMachineConfiguration->{'szGuestName'}${szInstanceNumber}-cidata.iso";
  
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


# This ends the perl module/package definition.
1;