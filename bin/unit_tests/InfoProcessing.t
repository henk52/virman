#!/usr/bin/perl -w
use strict;

################################################################################
#
#                         P E R L  U N I T  T E S T  F I L E  
#
################################################################################
#
#   DATE OF ORIGIN  : Mar 18, 2015
#
#----------------------------------- PURPOSE ------------------------------------
#
# This module will 
#
#
################################################################################

use FindBin;

BEGIN {
  push( @INC, "$FindBin::RealBin", "$FindBin::RealBin/.." );    ## Path to local modules
}

use Data::Dumper;

use Test::More tests => 2;
#use Test::Exception;

# The module under test.
use InfoProcessing;


# Support modules for testing.
use InstanceConfiguration;
use InstallWrapper;





# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                                   T E S T S 
# ==============================================================================

# -----------------------------------------------------------------
# ---------------
my $f_szInstanceDescription = 'Instance Description';
my %hInstanceConfiguration = (
              'Description' => "$f_szInstanceDescription",
              'NetworkConfiguration' => {
                       '0' => { 'Name' => 'Net0Name'  }
                                        }
                             );
my %hVirmanConfiguration = (
               'CloudInitIsoFiles' => '/ISO_FILES',
               'QcowFilePoolPath'  => '/virt_images'
                           );
my %hMachineConfiguration;
IPSetMachineConfiguration(\%hMachineConfiguration, \%hVirmanConfiguration, \%hInstanceConfiguration, 'MY_NAME', '009');

is($hMachineConfiguration{'szGuestDescription'}, $f_szInstanceDescription, 'IPSetMachineConfiguration[szGuestDescription]');

# TODO C Also test these:
# 'szGuestName' => 'MY_NAME'
# 'arPrivateNetworkList' => [ 'Net0Name'                                    ],

undef %hInstanceConfiguration;
InstCfgLoadInstanceConfiguration(\%hInstanceConfiguration, "unit_tests/example_InstanceConfiguration.xml");

my %hInstallWrapperConfiguration;
InstWrapLoadInstallWrapperConfiguration(\%hInstallWrapperConfiguration, "unit_tests/example_InstallWrapper.xml");

IPMergeInstanceAndWrapperInfo(\%hInstanceConfiguration, \%hInstallWrapperConfiguration);
my %hExpectedMergedConfigs = (
 'InstallWrapper' => 'ripwrap',
          'NameOfAdminUserAccount' => 'vagrant',
          'RunCommand' => [
                            'pre one',
                            'pre two',
                            'command1',
                            'command2',
                            'post one',
                            'post two'
                          ],
          'NetworkConfiguration' => {
                                      '3' => {
                                               'Name' => 'inst2'
                                             },
                                      '2' => {
                                               'AutoAssignement' => 'dhcp',
                                               'Name' => 'inst1'
                                             },
                                      '1' => {
                                               'Name' => 'inst0',
                                               'AutoAssignement' => 'dhcp'
                                             },
                                      '5' => {
                                               'Name' => 'post0',
                                               'AutoAssignement' => 'dhcp'
                                             },
                                      '4' => {
                                               'AutoAssignement' => 'static',
                                               'NetMask' => '255.255.255.0',
                                               'IpAddress' => '10.1.2.3',
                                               'Name' => 'fix1'
                                             },
                                      '6' => {
                                               'AutoAssignement' => 'dhcp',
                                               'Name' => 'post1'
                                             },
                                      '0' => {
                                             'AutoAssignement' => 'dhcp',
                                             'Name' => 'pre0'
                                           }
                                    },
          'Description' => 'Monitor machine',
          'BaseDomainName' => 'rhel63_x86_64',
          'FileProvidedDuringCloudInit' => {
                                             'bravo.tgz' => {
                                                            'DestinationFile' => '/vagrant/InstallWrapper_bravo.tgz',
                                                            'SourceType' => 'Base64'
                                                          },
                                             '/var/virman/vrouter/global.yaml' => {
                                                                                  'SourceType' => 'base64',
                                                                                  'DestinationFile' => '/etc/puppet/data/global.yaml'
                                                                                },
                                             'alpha.tgz' => {
                                                            'SourceType' => 'Base64',
                                                            'DestinationFile' => '/vagrant/alpha.tgz'
                                                          }
                                           }
);
#print Dumper(\%hInstanceConfiguration);
is_deeply(\%hInstanceConfiguration, \%hExpectedMergedConfigs, 'IPMergeInstanceAndWrapperInfo()');
