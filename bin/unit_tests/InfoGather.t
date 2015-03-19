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
  push( @INC, "$FindBin::RealBin/..", "$FindBin::RealBin" );    ## Path to local modules
}

use Data::Dumper;

use Test::More tests => 2;
#use Test::Exception;

# TODO C 'use' the perl module that is to be tested.
use InfoGather;


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                                   T E S T S 
# ==============================================================================

# -----------------------------------------------------------------
# ---------------
my %hVirmanConfiguration;

IGLoadVirmanConfiguration(\%hVirmanConfiguration, "unit_tests/example_default.xml");
is($hVirmanConfiguration{'InstallWrapperPath'}, '/var/virman/install_wrappers', 'Validating IGLoadVirmanConfiguration()');


my %hInstanceConfiguration;
IGReadInstanceConfiguration(\%hInstanceConfiguration, 'unit_tests/example_InstanceConfiguration.xml');
is($hInstanceConfiguration{'InstallWrapper'}, 'ripwrap', 'Sample validation of IGReadInstanceConfiguration()');

