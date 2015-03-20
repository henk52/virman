#!/usr/bin/perl -w
use strict;

################################################################################
#
#                         P E R L  U N I T  T E S T  F I L E  
#
################################################################################
#
#   DATE OF ORIGIN  : Mar 19, 2015
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

use Test::More tests => 5;
#use Test::Exception;

# TODO C 'use' the perl module that is to be tested.
use InstallWrapper;


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                                   T E S T S 
# ==============================================================================

# -----------------------------------------------------------------
# ---------------
my $xmlTree = InstWrapLoadXml("$FindBin::RealBin/example_InstallWrapper.xml");
is($xmlTree->{'Version'}, '0.1.0', 'Was able to read the xml file.');

is(InstWrapGetNote($xmlTree) , 'Just a note.', 'InstWrapGetNote()');

my @arExepectedPostRunCmdList = ( 'post one', 'post two' );
my @arActualPostRunCmdList = InstWrapGetPostRunCommandList($xmlTree); 
is_deeply(\@arActualPostRunCmdList, \@arExepectedPostRunCmdList, 'InstWrapGetPostRunCommandList()');

my @arExepectedPreRunCmdList = ( 'pre one', 'pre two' );
my @arActualPreRunCmdList = InstWrapGetPreRunCommandList($xmlTree); 
is_deeply(\@arActualPreRunCmdList, \@arExepectedPreRunCmdList, 'InstWrapGetPreRunCommandList()');


my %ExpectedNetworkConfiguration = (
     '-1' => {
                    'Name' => 'configuration',
                    'AutoAssignement' => 'dhcp'
                  },
     '-2' => {
                    'Name' => 'oplan',
                    'AutoAssignement' => 'dhcp'
                  }
   );
my %hActualNetworkConfiguration = InstWrapGetNetworkHash($xmlTree);
is_deeply(\%hActualNetworkConfiguration, \%ExpectedNetworkConfiguration, 'InstWrapGetNetworkHash().');
