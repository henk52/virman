package Default;
use strict;

################################################################################
#
#                         P E R L   M O D U L E
#
################################################################################
#
#   DATE OF ORIGIN  : 2015-03-15
#
#----------------------------------- PURPOSE ------------------------------------
#
# This module will read the VIRMAN default.xml file.
#
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



$VERSION = 0.2.0;
@ISA = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
                &DefaultGetBaseStoragePath
                &DefaultGetCloudInitIsoFilesPath
                &DefaultGetInstallWrapperPath
                &DefaultGetInstanceCfgBasePath
                &DefaultGetQcowFilePoolPath
                &DefaultGetSshPath
                &DefaultLoadXml
            );


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================
my $f_szXmlTopTagName = 'VIRMAN_CONFIGURATION';


# ==============================================================================
#                               F U N C T I O N S
# ==============================================================================

# -----------------------------------------------------------------
# ---------------
sub DefaultGetBaseStoragePath {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'BaseStoragePath'}[0]);
}

# -----------------------------------------------------------------
# ---------------
sub DefaultGetCloudInitIsoFilesPath {
  my $xmlTree = shift;

  confess("!!! xmlTree undefined.") unless(defined($xmlTree));

  my $szResult = $xmlTree->{'CloudInitIsoFilesPath'}[0];

  confess("!!! <CloudInitIsoFilesPath> in the virman default.xml file is invalid/empty. expected a scalar type got " . ref($szResult)) unless( ref($szResult) eq "" );

  return($szResult);
}

# -----------------------------------------------------------------
# ---------------
sub DefaultGetInstallWrapperPath {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'InstallWrapperPath'}[0]);
}

# -----------------------------------------------------------------
# ---------------
sub DefaultGetInstanceCfgBasePath {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'InstanceCfgBasePath'}[0]);
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
sub DefaultGetQcowFilePoolPath {
   my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'QcowFilePoolPath'}[0]);
}

# -----------------------------------------------------------------
# ---------------
sub DefaultGetSshPath {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'SshPath'}[0]);
}

# -----------------------------------------------------------------
# ---------------
sub DefaultLoadXml {
  my $szFileName = shift;

  if ( ! -f $szFileName ) {
    # TODO V support just failing with an error code.
    die("!!! file '$szFileName' does not exist.");
  }

  my $xmlTree = XMLin($szFileName, ForceArray => 1);

  my $xmlSubTree;

  if ( exists($xmlTree->{$f_szXmlTopTagName}) ) {
    $xmlSubTree = $xmlTree->{$f_szXmlTopTagName}[0];
  } else {
    print Dumper($xmlTree);
    die("!!! XML file: $szFileName not of the expectd: '$f_szXmlTopTagName'");
  }

  return($xmlSubTree);
}


# This ends the perl module/package definition.
1;

