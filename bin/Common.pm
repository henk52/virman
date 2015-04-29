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



$VERSION = 0.3.0;
@ISA = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
                &CmnAddFileEntry
                &CmnGetConfigKeyValue
                &CmnGetFileProvidedDuringCloudInit
                &CmnReturnArrayEmptyIfNotExist
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
  confess("!!! The filename has not been provided.") unless(defined($szFileName));
  confess("!!! The encoding has not been provided.") unless(defined($szEncoding));
  confess("!!! The target destination has not been provided.") unless(defined($szTargetDestination));
  
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
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub CmnGetConfigKeyValue {
  my $xmlTree = shift;

  confess("!!! no XML tree given as a parameter.") unless(defined($xmlTree));
  
  my %hScalarKeyValues;
  
  if ( exists($xmlTree->{'ConfigKeyValue'}) ) {
    foreach my $refFileEntry (@{$xmlTree->{'ConfigKeyValue'}}) {
      $hScalarKeyValues{${$refFileEntry->{'Key'}}[0]}      = ${$refFileEntry->{'Value'}}[0];
    } # end foreach.
  } # end if.
  
  return(%hScalarKeyValues);  
}
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

# -----------------------------------------------------------------
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief Return en empty array if the entry does not exist in the hash.
#
# A detailed description of the function
# @params xmlTree required
# @params szTagName required
# @retval an array.
# ....
#*
# ---------------
sub CmnReturnArrayEmptyIfNotExist {
  my $xmlTree = shift;
  my $szTagName = shift;

  confess("!!! no XML tree given as a parameter.") unless(defined($xmlTree));
  confess("!!! no tag name given as a parameter two.") unless(defined($szTagName));
  
  my @arEmpty= ();
  my $ReturnValue = \@arEmpty;
  if ( exists($xmlTree->{$szTagName}) ) {
    $ReturnValue = \@{$xmlTree->{$szTagName}};
  }
  #print "DDD CmnReturnArrayEmptyIfNotExist():\n";
  #print Dumper($ReturnValue);
  
  return(@{$ReturnValue});
} # end CmnReturnArrayEmptyIfNotExist.

# This ends the perl module/package definition.
1;