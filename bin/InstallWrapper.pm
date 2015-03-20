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
                &InstWrapGetNetworkHash
                &InstWrapGetPostRunCommandList
                &InstWrapGetPreRunCommandList
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
sub InstWrapGetFileHash {
  my $xmlTree = shift;

  # TODO Barf if XML tree is undef, or not an XML?

  return($xmlTree->{'BaseDomainName'}[0]);
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
sub InstWrapGetNetworkHash {
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
  return(%hNetworks);}

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

  # TODO Barf if XML tree is undef, or not an XML?

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
  #print Dumper($xmlSubTree);

  return($xmlSubTree);
}
# This ends the perl module/package definition.
1;