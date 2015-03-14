package ConfiguredNetworks;
use strict;

################################################################################
#
#                         P E R L   M O D U L E
#
################################################################################
#
#
#----------------------------------- PURPOSE ------------------------------------
#
# This module will provide the perl interface to the 
#   /etc/virman/configured_networks.xml
#
#----------------------------------- SYNOPSIS -----------------------------------
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
                &CfgNetsLoadXml
                &GetListOfBridgeNetworkNames
                &GetListOfInternalNetworks
            );


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                               F U N C T I O N S
# ==============================================================================

# -----------------------------------------------------------------
# Load the XML file given and return the XmlStructure.
# ---------------
sub CfgNetsLoadXml {
  my $szFileName = shift;

  if ( ! -f $szFileName ) {
    # TODO V support just failing with an error code.
    die("!!! file '$szFileName' does not exist.");
  }

  my $xmlTree = XMLin($szFileName, ForceArray => 1);

  my $xmlSubTree = $xmlTree->{'VIRMAN_CONFIGURED_NETWORK'}[0];
  print Dumper($xmlSubTree);

  return($xmlSubTree);
}

# -----------------------------------------------------------------
# ---------------
sub GetListOfNetworkNamesForGivenType {
  my $xmlTree = shift;
  my $szType  = shift;

  my @arNetworkNameList;

  foreach my $refhNetwork (@{$xmlTree->{'Network'}}) {
    #print Dumper($refhNetwork);
    if ( $refhNetwork->{'Type'} eq $szType ) {
      push(@arNetworkNameList, $refhNetwork->{'Name'});
    }
  }
  return(\@arNetworkNameList);
}

# -----------------------------------------------------------------
# ---------------
sub GetListOfBridgeNetworkNames {
  my $xmlTree = shift;

  my @arNetworkNameList = GetListOfNetworkNamesForGivenType($xmlTree, 'bridge');

  return(@arNetworkNameList);
}

# Create a common function wich is common and has a second parm of 'type'

# -----------------------------------------------------------------
# ---------------
sub GetListOfInternalNetworks {
  my $xmlTree = shift;

  my @arNetworkNameList = GetListOfNetworkNamesForGivenType($xmlTree, 'network');

  return(@arNetworkNameList);
}

# -----------------------------------------------------------------
# ---------------

# This ends the perl module/package definition.
1;

