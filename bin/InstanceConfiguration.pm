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

use Common;


$VERSION = 0.4.0;
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
                &InstCfgLoadInstanceConfiguration
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
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief A brief description of the function
#
# A detailed description of the function
#
# @see CmnGetFileProvidedDuringCloudInit
#
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub InstCfgGetFileProvidedDuringCloudInit {
  my $xmlTree = shift;
 
  return(CmnGetFileProvidedDuringCloudInit($xmlTree));
} # end InstCfgGetFileProvidedDuringCloudInit.


# -----------------------------------------------------------------
# Returns the hash, keyd by the index, so that it can be easily sorted.
# TODO V Merge this with InstWrapGetNetworkHash
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
    if ( exists($hrefVNic->{'IpAddress'}) ) {
      $hNetworks{$szKey}{'IpAddress'} = @{$hrefVNic->{'IpAddress'}}[0];
    }
    if ( exists($hrefVNic->{'NetMask'}) ) {
      $hNetworks{$szKey}{'NetMask'} = @{$hrefVNic->{'NetMask'}}[0];
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
  my $xmlTree = shift;
  confess("!!! the xmlTree(first parm) is not defined.") unless(defined($xmlTree));
  
  my @arEmpty= ();
  my $ReturnValue = \@arEmpty;
  if ( exists($xmlTree->{'RunCommand'}) ) {
    #print Dumper($xmlTree->{'RunCommand'});
    $ReturnValue = \@{$xmlTree->{'RunCommand'}};
  }
  return($ReturnValue);
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
sub InstCfgLoadInstanceConfiguration {
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

  #die("!!! TODO read the network info as well.");
  #Remember to also generate the global.yaml file.

  # Get the file for installation.
  my %hFileProvidedDuringCloudInit = InstCfgGetFileProvidedDuringCloudInit($xmlTree);
  $refConfHash->{'FileProvidedDuringCloudInit'} = \%hFileProvidedDuringCloudInit;
  
  # Get the run commands.
  $refConfHash->{'RunCommand'} = InstCfgGetRunCommandsList($xmlTree);

  #print Dumper($refConfHash);
  #print "------------------------------------\n";
  #print Dumper($config);

  #print "DDD $refConfHash->{'NameOfAdminUserAccount'}\n";
  #die("!!! test end.");
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

