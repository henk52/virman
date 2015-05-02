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

use Test::More tests => 3;
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
                  },
     '2' => {
                    'Name' => 'post2',
                    'AutoAssignement' => 'static',
                    'IpAddress' => '1.2.3.4',
                    'NetMask' => '255.255.255.0'
                  }
   );

GYUpdateNetworkCfg(\%NetworkConfiguration, $szTestYamlFileName);

#open(GLOBAL_YAML, "<$szTestYamlFileName") || die("!!! could not open file for write: $szTestYamlFileName - $!");
my $yaml = YAML::Tiny->read( $szTestYamlFileName );
#close(GLOBAL_YAML);

my %hExpectedDynamicYamlNicConfig = (
                           'vnicpost0' => {
                                            'nic_name' => 'eth0'
                                          },
                           'vnicpost1' => {
                                            'nic_name' => 'eth1'
                                          }
                             );
my %hExpectedStaticYamlNicConfig = (
                           'vnicpost2' => {
                                            'nic_name' => 'eth2',
                                            'ip_addr' => '1.2.3.4',
                                            'netmask' => '255.255.255.0'
                                          }
                             );

is_deeply(@{$yaml}[0]->{'dynamicnetconfig'}, \%hExpectedDynamicYamlNicConfig, 'Validate Dynamic GYUpdateNetworkCfg()');
is_deeply(@{$yaml}[0]->{'staticnetconfig'}, \%hExpectedStaticYamlNicConfig, 'Validate Static GYUpdateNetworkCfg()');


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
