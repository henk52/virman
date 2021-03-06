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



$VERSION = 0.2.0;
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

  InstCfgLoadInstanceConfiguration($refConfHash, $szFileName);
} # end IGReadInstanceConfiguration.


# This ends the perl module/package definition.
1;