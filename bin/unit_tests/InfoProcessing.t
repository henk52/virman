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
my %hMergedNetworks = (
          '0' => {
                 'AutoAssignement' => 'dhcp',
                 'Name' => 'pre0'
               },
          '1' => {
                   'AutoAssignement' => 'dhcp',
                   'Name' => 'inst0'
                 },
          '2' => {
                   'Name' => 'inst1',
                   'AutoAssignement' => 'dhcp'
                 },
          '3' => {
                   'Name' => 'inst2'
                 },
          '4' => {
                   'AutoAssignement' => 'dhcp',
                   'Name' => 'post0'
                 },
          '5' => {
                   'AutoAssignement' => 'dhcp',
                   'Name' => 'post1'
                 }
);
is_deeply($hInstanceConfiguration{'NetworkConfiguration'}, \%hMergedNetworks, 'InstWrapLoadInstallWrapperConfiguration(): Merged networks.');
