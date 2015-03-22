package InstallWrapper;
use strict;

################################################################################
#
#                         P E R L   M O D U L E
#
################################################################################
#
#   DATE OF ORIGIN  : Mar 19, 2015
#
#----------------------------------- PURPOSE ------------------------------------
#** @file InstallWrapper.pm
#
# This module will be your interface to the install wrapper files.
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

use XML::Simple;


$VERSION = 0.1.0;
@ISA = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
                &InstWrapGetFileHash
                &InstWrapGetNote
                &InstWrapGetPreNetworkHash
                &InstWrapGetPostNetworkHash
                &InstWrapGetPostRunCommandList
                &InstWrapGetPreRunCommandList
                &InstWrapLoadInstallWrapperConfiguration
                &InstWrapLoadXml
            );


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                               F U N C T I O N S
# ==============================================================================


# -----------------------------------------------------------------
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief A brief description of the function
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstCfgGetFileProvidedDuringCloudInit {

  my %hConfig;
  my $config = \%hConfig;
  # TODO V This could be made common so it could be read both from the app.xml and the OTHER.xml
  if ( exists($config->{'FileProvidedDuringCloudInit'}) ) {
    my @arFileEntries;
    foreach my $refFileEntry (@{$config->{'FileProvidedDuringCloudInit'}}) {
      my %hFileEntry;
      $hFileEntry{'SourceFile'}      = ${$refFileEntry->{'SourceFile'}}[0];
      $hFileEntry{'SourceType'}      = ${$refFileEntry->{'SourceType'}}[0];
      # TODO C Also support !!binary
      $hFileEntry{'DestinationFile'} = ${$refFileEntry->{'DestinationFile'}}[0];
      push(@arFileEntries, \%hFileEntry);
    } # end foreach.
  } # end if.
} # end InstCfgGetFileProvidedDuringCloudInit.

# -----------------------------------------------------------------
#** @function private GetNetworkHash
# @brief A brief description of the function
#
# @see InstWrapGetPreNetworkHash
# @see InstWrapGetPostNetworkHash
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub GetNetworkHash {
  my $xmlTree = shift;
  my $szVnicTagName = shift;
  
  my %hNetworks;

  #print Dumper($xmlTree->{'VNic'});
  foreach my $hrefVNic (@{$xmlTree->{$szVnicTagName}}) {
    #print Dumper($hrefVNic);
    my $szKey = $hrefVNic->{'Index'};
    $hNetworks{$szKey}{'Name'} = @{$hrefVNic->{'NetworkName'}}[0];
    if ( exists($hrefVNic->{'AutoAssignement'}) ) {
      $hNetworks{$szKey}{'AutoAssignement'} = @{$hrefVNic->{'AutoAssignement'}}[0];
    }
    #print "Name: $szNetworkName\n";
  }

  #print Dumper(\%hNetworks);
  return(%hNetworks);
}


# -----------------------------------------------------------------
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief A brief description of the function
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstWrapGetPostNetworkHash {
  my $xmlTree = shift;

  my %hNetworks = GetNetworkHash($xmlTree, "VNicPost");
  return(%hNetworks);
}

# -----------------------------------------------------------------
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief A brief description of the function
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstWrapGetPreNetworkHash {
  my $xmlTree = shift;

  my %hNetworks = GetNetworkHash($xmlTree, "VNicPre");
  return(%hNetworks);
}

# -----------------------------------------------------------------
#** @function public InstWrapGetNote
# @brief Get the note that is in the install wrapper structure.
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstWrapGetNote {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'Note'}[0]);
}


# -----------------------------------------------------------------
#** @function public InstWrapGetPostRunCommandList
# @brief A brief description of the function
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstWrapGetPostRunCommandList {
  my $xmlTree = shift;

  confess("!!! no XML tree given as a parameter.") unless(defined($xmlTree));
  
  #print Dumper($xmlTree);
  

  return(@{$xmlTree->{'PostAppRunCommand'}});
}

# -----------------------------------------------------------------
#** @function public InstWrapGetPreRunCommandList
# @brief A brief description of the function
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstWrapGetPreRunCommandList {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return(@{$xmlTree->{'PreAppRunCommand'}});
}


# -----------------------------------------------------------------
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief A brief description of the function
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstWrapLoadInstallWrapperConfiguration {
  my $refConfHash = shift;
  my $szFileName = shift;

  # TODO verify the XML file exists.
  my $xmlTree = InstWrapLoadXml($szFileName);
  confess("!!! no XML loaded from $szFileName") unless(defined($xmlTree));
  
  
  $refConfHash->{'Note'}     = InstWrapGetNote($xmlTree);
  
  my %hPreNetworkHash = InstWrapGetPreNetworkHash($xmlTree);
  $refConfHash->{'PreNetworkConfiguration'}     = \%hPreNetworkHash;
  
  
  my %hPostNetworkHash = InstWrapGetPostNetworkHash($xmlTree);
  $refConfHash->{'PostNetworkConfiguration'}     = \%hPostNetworkHash;

  my @arPostAppRnCmd = InstWrapGetPostRunCommandList($xmlTree);
  $refConfHash->{'PostAppRunCommand'}     = \@arPostAppRnCmd;
  
  my @arPreAppRnCmd = InstWrapGetPreRunCommandList($xmlTree);
  $refConfHash->{'PreAppRunCommands'}     = \@arPreAppRnCmd;
  #$refConfHash->{''}     = ($xmlTree);

  #print Dumper($refConfHash);
  #die("!!! test end.");
}

# -----------------------------------------------------------------
#** @function public InstWrapLoadXml
# @brief A brief description of the function
#
# A detailed description of the function
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstWrapLoadXml {
  my $szFileName = shift;

  if ( ! -f $szFileName ) {
    # TODO V support just failing with an error code.
    die("!!! file '$szFileName' does not exist.");
  }

  my $xmlTree = XMLin($szFileName, ForceArray => 1);

  my $xmlSubTree = $xmlTree->{'INSTALL_WRAPPER'}[0];
  confess("!!! This is not a valid XML tree for INSTALL_WRAPPER") unless(defined($xmlSubTree));
  #print Dumper($xmlSubTree);

  return($xmlSubTree);
}
# This ends the perl module/package definition.
1;