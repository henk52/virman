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



$VERSION = 0.1.3;
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
#** @function public IPMergeInstanceAndWrapperInfo
# @brief Merge the Instance info and the, optional, install wrapper information.
#   The merged data is available in the $refhInstanceConfiguration.
#
# The section: FileProvidedDuringCloudInit will be merged and the InstallWrapper
#   configuration takes precedence to the Instance configuration.
# 
# @params refhVirmanConfiguration required The Virman configuration Hash.
# @params refhInstallWrapperConfiguration required The install wrapper data hash.
# @retval value [details]
# ....
#*
# ---------------
sub IPMergeInstanceAndWrapperInfo {
  my $refhInstanceConfiguration = shift;
  my $refhInstallWrapperConfiguration = shift;
  
  #print "--- refhInstanceConfiguration\n";
  #print Dumper($refhInstanceConfiguration);


  print "--- refhInstallWrapperConfiguration\n";
  print Dumper($refhInstallWrapperConfiguration);

  # Get length of pre list.
  my @arInstWrapPreNetworkKeys = sort(keys  $refhInstallWrapperConfiguration->{'PreNetworkConfiguration'});

  my @arInstWrapPostNetworkKeys = sort(keys  $refhInstallWrapperConfiguration->{'PostNetworkConfiguration'});

  # reverse the list of instance network.
  my @arInstanceNetworkKeys = reverse(sort(keys  $refhInstanceConfiguration->{'NetworkConfiguration'}));

  #print Dumper(\@arInstWrapPreNetworkKeys);
  #print Dumper(\@arInstanceNetworkKeys);
  #print Dumper(\@arInstWrapPostNetworkKeys);
  
  #print Dumper($refhInstallWrapperConfiguration);
  #print Dumper($refhInstanceConfiguration);
  
  # for each index, add the length of the pre lengt
  my $nElementsInInstWrapPreNetwork = $#arInstWrapPreNetworkKeys+1;
  foreach my $nIndex (@arInstanceNetworkKeys) {
    #$data->{key3}{key4}{key6} = delete $data->{key3}{key4}{key5}
    # see: http://stackoverflow.com/questions/1490356/how-to-replace-a-perl-hash-key
    #print "DDD nIndex: $nIndex  arrayLength=$#arInstWrapPreNetworkKeys\n";
    $refhInstanceConfiguration->{'NetworkConfiguration'}{$nIndex + $nElementsInInstWrapPreNetwork} = delete($refhInstanceConfiguration->{'NetworkConfiguration'}{$nIndex});
  }

  # insert the pre list
  foreach my $nIndex (@arInstWrapPreNetworkKeys) {
    $refhInstanceConfiguration->{'NetworkConfiguration'}{$nIndex} = $refhInstallWrapperConfiguration->{'PreNetworkConfiguration'}{$nIndex};
  }

  # insert the post list, add pre+instance number of entries to each post index.
  my $nElementsInInstanceNetwork = $#arInstanceNetworkKeys + 1;
  foreach my $nIndex (@arInstWrapPostNetworkKeys) {
    $refhInstanceConfiguration->{'NetworkConfiguration'}{$nIndex + $nElementsInInstWrapPreNetwork + $nElementsInInstanceNetwork} = $refhInstallWrapperConfiguration->{'PostNetworkConfiguration'}{$nIndex};
  }
  
  #print Dumper($refhInstanceConfiguration->{'NetworkConfiguration'});

  foreach my $szFileKey (keys  $refhInstallWrapperConfiguration->{'FileProvidedDuringCloudInit'}) {
    $refhInstanceConfiguration->{'FileProvidedDuringCloudInit'}{$szFileKey} = $refhInstallWrapperConfiguration->{'FileProvidedDuringCloudInit'}{$szFileKey};
  }
  
  if ( exists ($refhInstallWrapperConfiguration->{'PreAppRunCommand'}) ) {
    foreach my $szEntry (reverse(@{$refhInstallWrapperConfiguration->{'PreAppRunCommand'}}) ) {
      unshift($refhInstanceConfiguration->{'RunCommand'}, $szEntry);
    }
  }
  if ( exists ($refhInstallWrapperConfiguration->{'PostAppRunCommand'}) ) {
    foreach my $szEntry ( @{$refhInstallWrapperConfiguration->{'PostAppRunCommand'}}  ) {
      push($refhInstanceConfiguration->{'RunCommand'}, $szEntry);
    }
  }
  
  if ( exists ($refhInstallWrapperConfiguration->{'ScalarKeyValues'}) ) {
    foreach my $szEntry ( keys %{$refhInstallWrapperConfiguration->{'ScalarKeyValues'}}  ) {
      $refhInstanceConfiguration->{'ScalarKeyValues'}{$szEntry} = $refhInstallWrapperConfiguration->{'ScalarKeyValues'}{$szEntry};
    }
  }
  
  #die("!!! Hey look here....");  
} # end IPMergeInstanceAndWrapperInfo

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

  confess("!!! szDomainName is not defined(4th parm)") unless(defined($szDomainName));
  
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
    # This is where all the pre-instance files are stored.
  

  # TODO N Does this 'InstanceTempDirectory' really belong in the $refhMachineConfiguration or should it rather be in $refhInstanceConfiguration
  $refhMachineConfiguration->{'InstanceTempDirectory'} = "$refhVirmanConfiguration->{'CloudInitIsoFiles'}/$refhMachineConfiguration->{'szGuestName'}${szInstanceNumber}";
  
  $refhMachineConfiguration->{'szIsoImage'} = "$refhMachineConfiguration->{'InstanceTempDirectory'}/$refhMachineConfiguration->{'szGuestName'}${szInstanceNumber}-cidata.iso";
  
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
