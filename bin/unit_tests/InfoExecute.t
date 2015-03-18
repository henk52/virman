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
  push( @INC, "$FindBin::RealBin:$FindBin::RealBin/.." );    ## Path to local modules
}

use Data::Dumper;

use Test::More tests => 1;
#use Test::Exception;

# TODO C 'use' the perl module that is to be tested.
use InfoExecute;


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                                   T E S T S 
# ==============================================================================

# -----------------------------------------------------------------
# ---------------
my %hCombinedInstanceAndWrapperConf = (
                       
                                      );
my %hMachineConfiguration = (
                     'szGuestName' => 'GUEST_NAME',
                     'szIsoImage'  => 'test.iso'
                            );
my %hVirmanConfiguration = (
                     'SshRelativePath' => '.'
                           );
IEGenerateCloudInitIsoImage(\%hCombinedInstanceAndWrapperConf, );
