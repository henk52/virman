package Common;
use strict;

################################################################################
#
#                         P E R L   M O D U L E
#
################################################################################
#
#   DATE OF ORIGIN  : Mar 22, 2015
#
#----------------------------------- PURPOSE ------------------------------------
#** @file Common.pm
#
# This module holds functions that are common to a number of the modules.
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
                &CmnAddFileEntry
                &CmnGetFileProvidedDuringCloudInit
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
# @params refhFileStructure required The structure that will be updated.
# @params szGlobalYamlFile required The file, with path, to be included on the ISO.
# @params szEncoding required Type of cloud-init supported encoded: Base64 etc.
# @params szTargetDestination required destination, where the file will go, an be called on the instance.
# @retval none.
# ....
#*
# ---------------
sub CmnAddFileEntry {
  my $refhFileStructure   = shift;
  my $szFileName          = shift;
  my $szEncoding          = shift;
  my $szTargetDestination = shift;

  confess("!!! The hash to put this file information in, is not defined.") unless(defined($refhFileStructure));
  # TODO V Validate the parameters.
  # TODO V validate that the szEncoding is a supported type.
  # TODO V Validate the the $refhFileStructure->{$szGlobalYamlFile} doesn't exist already?
  $refhFileStructure->{$szFileName}{'SourceType'}       = $szEncoding;
  $refhFileStructure->{$szFileName}{'DestinationFile'}  = $szTargetDestination;
} # end CmnAddFileEntry.

# -----------------------------------------------------------------
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief A brief description of the function
#
# A detailed description of the function
#
# @see InstWrapGetFileProvidedDuringCloudInit
# @see InstCfgGetFileProvidedDuringCloudInit
#
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub CmnGetFileProvidedDuringCloudInit {
  my $xmlTree = shift;
 
  my %hConfig;
  #my $config = \%hConfig;
  if ( exists($xmlTree->{'FileProvidedDuringCloudInit'}) ) {
    foreach my $refFileEntry (@{$xmlTree->{'FileProvidedDuringCloudInit'}}) {
      # TODO V add if exists to the structures. 
      $hConfig{${$refFileEntry->{'SourceFile'}}[0]}{'SourceType'}      = ${$refFileEntry->{'SourceType'}}[0];
      $hConfig{${$refFileEntry->{'SourceFile'}}[0]}{'DestinationFile'} = ${$refFileEntry->{'DestinationFile'}}[0];
    } # end foreach.
  } # end if.
  #print Dumper(\%hConfig);
  #die("END TEST");
  return(%hConfig);
} # end CmnGetFileProvidedDuringCloudInit.


# This ends the perl module/package definition.
1;