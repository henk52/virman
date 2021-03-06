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

$VERSION = 0.3.1;
@ISA     = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
  &GYUpdateNetworkCfg
  &GYUpdateScalar
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
# This function will go through the entire list and create two
#   hashes of network confs, one for static and one for dhcp.
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
  my $szYamlFileName    = shift;

  die("!!! Filename is not given.") unless ( defined($szYamlFileName) );
  die("!!! network config hash not provided.") unless ( defined($refhNetworkConfig) );

  #print Dumper($refhNetworkConfig);
  #die("XXXXXXXXXXXXXXXXXXXXX");

  my @arNetworkKeys = sort( keys $refhNetworkConfig );

  my $pYamlFileHandle;
  my $yaml;

  if ( !-f $szYamlFileName ) {
    #open($pYamlFileHandle, ">$szYamlFileName") || die("!!! could not open file for write: $szYamlFileName - $!");
    $yaml = YAML::Tiny->new();
  } else {
    #open($pYamlFileHandle, "$szYamlFileName") || die("!!! could not open file for read/write: $szYamlFileName - $!");
    $yaml = YAML::Tiny->read($szYamlFileName);
  }

  #close($pYamlFileHandle);
  #print Dumper($yaml);
  my %hYamlGlobalConfig;
  my %hYamlDynamicNetConfig;
  my %hYamlStaticNetConfig;
  foreach my $szIndex (@arNetworkKeys) {
    if ( exists( $refhNetworkConfig->{$szIndex}{'AutoAssignement'} ) ) {
      if ( $refhNetworkConfig->{$szIndex}{'AutoAssignement'} eq "dhcp" )
      {
        my %hNic = ( 'nic_name' => "eth$szIndex" );
        $hYamlDynamicNetConfig{ "vnic"
            . $refhNetworkConfig->{$szIndex}{'Name'} } = \%hNic;
      }
      else {    # endif dhcp.
        my %hNic = ( 
               'nic_name' => "eth$szIndex",
               'ip_addr'  =>  $refhNetworkConfig->{$szIndex}{'IpAddress'},
               'netmask'  =>  $refhNetworkConfig->{$szIndex}{'NetMask'}
               );
        $hYamlStaticNetConfig{ "vnic"
            . $refhNetworkConfig->{$szIndex}{'Name'} } = \%hNic;
      }
    }    # end if autoassingment.
  }    # endif foreach.
  if (%hYamlDynamicNetConfig) {
    $hYamlGlobalConfig{'dynamicnetconfig'} = \%hYamlDynamicNetConfig;
  }
  if (%hYamlStaticNetConfig) {
    $hYamlGlobalConfig{'staticnetconfig'}  = \%hYamlStaticNetConfig;
  }
  push( @{$yaml}, \%hYamlGlobalConfig );

  #print Dumper(\%hYamlGlobalConfig);
  #print Dumper($yaml); die("XXXXXXXXXXXXXXXXXXX");

  # Save the document back to the file
  $yaml->write($szYamlFileName);

  #die("XXX END TEST");
}

# -----------------------------------------------------------------
#** @function [public|protected|private] [return-type] function-name (parameters)
# @brief A brief description of the function
#
# This will write the given values.
#  The values are given as a hash, but it is just a key/value list, that is added to the file.
# @params value [required|optional] [details]
# @retval value [details]
# ....
#*
# ---------------
sub GYUpdateScalar {
  my $szYamlFileName   = shift;
  my $refhKeyValueList = shift;
  
  confess("!!! Filename is not given.") unless ( defined($szYamlFileName) );
  #confess("!!! KeyValue list hash not provided.") unless ( defined($refhKeyValueList) );

  # Sometimes there might be no scalar vlues to define.
  if ( defined($refhKeyValueList) ) {
    my $pYamlFileHandle;
    my $yaml;

    if ( !-f $szYamlFileName ) {
      #open($pYamlFileHandle, ">$szYamlFileName") || die("!!! could not open file for write: $szYamlFileName - $!");
      $yaml = YAML::Tiny->new();
    } else {
      #open($pYamlFileHandle, "$szYamlFileName") || die("!!! could not open file for read/write: $szYamlFileName - $!");
      $yaml = YAML::Tiny->read($szYamlFileName);
    }
  
  
    # TODO Itterate through the list and add the values to the YAML file.
    foreach my $szKey (keys $refhKeyValueList) {
      $yaml->[0]->{"$szKey"} = "$refhKeyValueList->{$szKey}";
    }
  
  
    # Save the document back to the file
    $yaml->write($szYamlFileName);
  } # endif hash defined.
  
}

# This ends the perl module/package definition.
1;
