#!/usr/bin/perl -w
use strict;

################################################################################
#
#                         P E R L  U N I T  T E S T  F I L E  
#
################################################################################
#
#   DATE OF ORIGIN  : Mar 22, 2015
#
#----------------------------------- PURPOSE ------------------------------------
#
# This module will 
#
#
################################################################################

use FindBin;

BEGIN {
  push( @INC, "$FindBin::RealBin","$FindBin::RealBin/.." );    ## Path to local modules
}

use Data::Dumper;

use Test::More tests => 2;
#use Test::Exception;

# the perl module that is to be tested.
use GlobalYaml;

# for reading back and verifying.
use YAML::Tiny;



# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                                   T E S T S 
# ==============================================================================

# -----------------------------------------------------------------
# ---------------

my $szTestYamlFileName = "global.yaml";

my %NetworkConfiguration = (
     '0' => {
                    'Name' => 'post0',
                    'AutoAssignement' => 'dhcp'
                  },
     '1' => {
                    'Name' => 'post1',
                    'AutoAssignement' => 'dhcp'
                  }
   );

GYUpdateNetworkCfg(\%NetworkConfiguration, $szTestYamlFileName);

#open(GLOBAL_YAML, "<$szTestYamlFileName") || die("!!! could not open file for write: $szTestYamlFileName - $!");
my $yaml = YAML::Tiny->read( $szTestYamlFileName );
#close(GLOBAL_YAML);

my %hExpectedYamlNicConfig = (
                           'vnicpost0' => {
                                            'nic_name' => 'eth0'
                                          },
                           'vnicpost1' => {
                                            'nic_name' => 'eth1'
                                          }
                             );

is_deeply(@{$yaml}[0]->{'dynamicnetconfig'}, \%hExpectedYamlNicConfig, 'Validate GYUpdateNetworkCfg()');


# TODO V Make a test where static is also involved.
unlink($szTestYamlFileName);

# TODO Test with netconfig hash not there.

my %hKeyValuePair = (
  'ApplicationName' => 'Test1',
  'InstallFile'     => 'myapp.zip'
);

GYUpdateScalar($szTestYamlFileName, \%hKeyValuePair);
$yaml = YAML::Tiny->read( $szTestYamlFileName );
is_deeply($yaml->[0], \%hKeyValuePair, 'Validating GYUpdateScalar()');
#print Dumper($yaml);
unlink($szTestYamlFileName);
