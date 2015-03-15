#!/usr/bin/perl -w
use strict;

################################################################################
#
#                         P E R L  U N I T  T E S T  F I L E  
#
################################################################################
#
#   DATE OF ORIGIN  : 2015-03-15
#
#----------------------------------- PURPOSE ------------------------------------
#
# This module will 
#
#
################################################################################

use FindBin;

BEGIN {
  push( @INC, "$FindBin::RealBin/.." );    ## Path to local modules
}

use Data::Dumper;

use Test::More tests => 6;
#use Test::Exception;

# TODO C 'use' the perl module that is to be tested.
use Default;


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                                   T E S T S 
# ==============================================================================

# -----------------------------------------------------------------
# ---------------

my $xmlTree = DefaultLoadXml("$FindBin::RealBin/example_default.xml");
is($xmlTree->{'Version'}, '0.2.0', 'Was able to read the xml file.');

is(DefaultGetBaseStoragePath($xmlTree),       '/var/virman/basestorage',      'DefaultGetBaseStoragePath()');
is(DefaultGetCloudInitIsoFilesPath($xmlTree), '/var/virman/cloud_init_iso_files', 'DefaultGetCloudInitIsoFilesPath()');
is(DefaultGetInstallWrapperPath($xmlTree),    '/var/virman/install_wrappers', 'DefaultGetInstallWrapperPath()');
is(DefaultGetInstanceCfgBasePath($xmlTree),   '/var/virman/instanceconfigs',  'DefaultGetInstanceCfgBasePath()');
is(DefaultGetSshPath($xmlTree),               '/var/virman/.ssh',             'DefaultGetSshPath()');


