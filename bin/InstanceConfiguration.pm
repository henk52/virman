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
# This module will interface to VIRMAN_INSTANCE_CONFIGURAITON.
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
                &GetBaseDomainName
                &GetDescription
                &GetInstanceType
                &GetNameOfAdminUserAccount
                &InstCfgGetFileProvidedDuringCloudInit
                &InstCfgGetInstallWrapper
                &InstCfgGetNetworkHash
                &InstCfgGetRunCommandsList
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

# TODO Move this to a common pm so that InstallWrapper could also use it.
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
    }
#    $refConfHash->{'FileProvidedDuringCloudInit'}   = \@arFileEntries;
  }

}


# -----------------------------------------------------------------
# Returns the hash, keyd by the index, so that it can be easily sorted.
# ---------------
sub InstCfgGetNetworkHash {
  my $xmlTree = shift;
  
  my %hNetworks;

  #print Dumper($xmlTree->{'VNic'});
  foreach my $hrefVNic (@{$xmlTree->{'VNic'}}) {
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
# ---------------
sub InstCfgGetInstallWrapper {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'InstallWrapper'}[0]);
}

# ----------------------------------------------------------------
# ---------------
# TODO Move this to a common pm so that InstallWrapper could also use it.
sub InstCfgGetRunCommandsList {
  my $config;
  if ( exists($config->{'RunCommand'}) ) {
    my @arRunCommand   = $config->{'RunCommand'};
    #$refConfHash->{'RunCommand'} = \@arRunCommand;
#    $refConfHash->{'RunCommand'} = $config->{'RunCommand'};
  }

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
    print Dumper($xmlTree);
    die("!!! XML file: $szFileName not of the expectd: 'VIRMAN_INSTANCE_CONFIGURAITON'");
  }

  return($xmlSubTree);

}


# This ends the perl module/package definition.
1;

