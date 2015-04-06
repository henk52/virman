package InfoGather;
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
#** @file InfoGather.pm
#
# This module will holds the functions for gathering the data for the cloning.
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

use Default;
use InstanceConfiguration;



$VERSION = 0.1.1;
@ISA = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
                &IGLoadVirmanConfiguration
                &IGReadInstanceConfiguration
            );
            
            # TODO IGReadInstallWrapperConfiguration


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
sub IGLoadVirmanConfiguration {
  my $refConfHash = shift;
  my $szFileName = shift;

  # TODO verify the XML file exists.
  my $xmlTree = DefaultLoadXml($szFileName);
  
  
  $refConfHash->{'BaseStoragePath'}     = DefaultGetBaseStoragePath($xmlTree);
  $refConfHash->{'InstallWrapperPath'}  = DefaultGetInstallWrapperPath($xmlTree);
  $refConfHash->{'SshPath'}             = DefaultGetSshPath($xmlTree);
  $refConfHash->{'CloudInitIsoFiles'}   = DefaultGetCloudInitIsoFilesPath($xmlTree);
  $refConfHash->{'InstanceCfgBasePath'} = DefaultGetInstanceCfgBasePath($xmlTree);
  $refConfHash->{'QcowFilePoolPath'}    = DefaultGetQcowFilePoolPath($xmlTree);

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
sub IGReadInstanceConfiguration {
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


  # Get the file for installation.
  my @arRunCommands = InstCfgGetRunCommandsList($xmlTree);
  $refConfHash->{'RunCommand'} = \@arRunCommands;
}


# This ends the perl module/package definition.
1;