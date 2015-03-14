package InstanceConfiguration;
use strict;

################################################################################
#
#                         P E R L   M O D U L E
#
################################################################################
#
#----------------------------------- PURPOSE ------------------------------------
#
# This module will 
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



$VERSION = 0.1.0;
@ISA = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
                &GetBaseDomainName
                &GetDescription
                &GetInstanceType
                &GetNameOfAdminUserAccount
                &GetNetworkHash
                &InstCfgLoadXml
            );


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                               F U N C T I O N S
# ==============================================================================

# -----------------------------------------------------------------
# ---------------
sub GetBaseDomainName {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'BaseDomainName'}[0]);
}

# -----------------------------------------------------------------
# ---------------
sub GetDescription {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'Description'}[0]);
}

# -----------------------------------------------------------------
# ---------------
sub GetInstanceType {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'InstanceType'}[0]);
}

# -----------------------------------------------------------------
# ---------------
sub GetNameOfAdminUserAccount {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'NameOfAdminUserAccount'}[0]);
}

# -----------------------------------------------------------------
# ---------------
sub GetNetworkHash {
}

# ----------------------------------------------------------------
# ---------------
sub InstCfgLoadXml {
  my $szFileName = shift;

  if ( ! -f $szFileName ) {
    # TODO V support just failing with an error code.
    die("!!! file '$szFileName' does not exist.");
  }

  my $xmlTree = XMLin($szFileName, ForceArray => 1);

  my $xmlSubTree;

  if ( exists($xmlTree->{'VIRMAN_INSTANCE_CONFIGURAITON'}) ) {
    $xmlSubTree = $xmlTree->{'VIRMAN_INSTANCE_CONFIGURAITON'}[0];
  } else {
    print Dumper($xmlSubTree);
    die("!!! XML file: $szFileName not of the expectd: 'VIRMAN_INSTANCE_CONFIGURAITON'");
  }

  return($xmlSubTree);

}


# This ends the perl module/package definition.
1;

