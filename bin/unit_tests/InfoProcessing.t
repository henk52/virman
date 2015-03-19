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

use Test::More tests => 1;
#use Test::Exception;

# TODO C 'use' the perl module that is to be tested.
use InfoProcessing;


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

is($hMachineConfiguration{'szGuestDescription'}, $f_szInstanceDescription, 'IPSetMachineConfiguration[szGuestDescription]')

# TODO C Also test these:
# 'szGuestName' => 'MY_NAME'
# 'arPrivateNetworkList' => [ 'Net0Name'                                    ],


