package GlobalYaml;
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
#** @file GlobalYaml.pm
#
# This module will create and/or update a global.yaml file.
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

use YAML::Tiny;



$VERSION = 0.1.0;
@ISA = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
                &GYUpdateNetworkCfg
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
# If the file does not exist, then open it.
# For each entry in the $refhNetworkConfig look for it in the yaml file.
#   If the entry exists in yaml update it.
#   otherwise create it.
#
# TODO V implement reading/merging with existing data.
#
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub GYUpdateNetworkCfg {
  my $refhNetworkConfig = shift;
  my $szYamlFileName = shift;
  
  die("!!! Filename is not given.") unless(defined($szYamlFileName));
  
  #print Dumper($refhNetworkConfig);
  
  my @arNetworkKeys = sort(keys  $refhNetworkConfig);
  
  my $pYamlFileHandle;
  my $yaml;
  
  if ( ! -f $szYamlFileName ) {
    #open($pYamlFileHandle, ">$szYamlFileName") || die("!!! could not open file for write: $szYamlFileName - $!");
    $yaml = YAML::Tiny->new();
  } else {
    #open($pYamlFileHandle, "$szYamlFileName") || die("!!! could not open file for read/write: $szYamlFileName - $!");
    $yaml = YAML::Tiny->read( $szYamlFileName );
  }
  #close($pYamlFileHandle);
  #print Dumper($yaml);
  my %hYamlGlobalConfig;
  my %hYamlNetConfig;
  foreach my $szIndex (@arNetworkKeys) {
    if ( $refhNetworkConfig->{$szIndex}{'AutoAssignement'} eq "dhcp" ) {
      my %hNic = ( 
           'nic_name' => $refhNetworkConfig->{$szIndex}{'Name'},
           'boot_proto' => 'dhcp'
           );
      $hYamlNetConfig{"vnic" . $refhNetworkConfig->{$szIndex}{'Name'}} = \%hNic;
    } # endif dhcp.
  } # endif foreach.
  #$yaml->{'netconfig'} = \%hYamlNetConfig;
  $hYamlGlobalConfig{'netconfig'} = \%hYamlNetConfig;
  push(@{$yaml}, \%hYamlGlobalConfig);
  #print Dumper(\%hYamlGlobalConfig);
  #print Dumper($yaml);
  
  # Save the document back to the file
  $yaml->write( $szYamlFileName );

  #die("XXX END TEST");
}

# This ends the perl module/package definition.
1;