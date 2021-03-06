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

use Test::More tests => 1;
#use Test::Exception;

# the perl module that is to be tested.
use Common;


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                                   T E S T S 
# ==============================================================================

# -----------------------------------------------------------------
# ---------------

my %hFileStructure;
my $szGlobalYaml = "global.yaml";
my $szBase64Type = "Base64";
my $szDestinationFile = "/tmp/global.yaml";

CmnAddFileEntry(\%hFileStructure, $szGlobalYaml, $szBase64Type, $szDestinationFile);

my %hExpectedFileStructure = (
          "$szGlobalYaml" => {
             'SourceType' => "$szBase64Type",
             'DestinationFile' => "$szDestinationFile"
          }
);

is_deeply(\%hFileStructure, \%hExpectedFileStructure, 'Validating CmnAddFileEntry()');

