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

use Test::More tests => 9;
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


my %ExpectedPreNetworkConfiguration = (
     '0' => {
                    'Name' => 'pre0',
                    'AutoAssignement' => 'dhcp'
                  }
   );
my %hActualNetworkConfiguration = InstWrapGetPreNetworkHash($xmlTree);
is_deeply(\%hActualNetworkConfiguration, \%ExpectedPreNetworkConfiguration, 'InstWrapGetPreNetworkHash().');

my %ExpectedPostNetworkConfiguration = (
     '0' => {
                    'Name' => 'post0',
                    'AutoAssignement' => 'dhcp'
                  },
     '1' => {
                    'Name' => 'post1',
                    'AutoAssignement' => 'dhcp'
                  }
   );
undef %hActualNetworkConfiguration;
%hActualNetworkConfiguration = InstWrapGetPostNetworkHash($xmlTree);
is_deeply(\%hActualNetworkConfiguration, \%ExpectedPostNetworkConfiguration, 'InstWrapGetPostNetworkHash().');

my %hFileHash = InstWrapGetFileProvidedDuringCloudInit($xmlTree);

my %ExpectedFileHash = (
       '/var/virman/vrouter/global.yaml' => {
                       'SourceType' => 'base64',
                       'DestinationFile' => '/etc/puppet/data/global.yaml'
                      },
       'bravo.tgz' => {
                       'DestinationFile' => '/vagrant/InstallWrapper_bravo.tgz',
                       'SourceType' => 'Base64'
                       }
);
is_deeply(\%hFileHash, \%ExpectedFileHash, 'Validating InstWrapGetFileProvidedDuringCloudInit().');


$xmlTree = InstWrapLoadXml("$FindBin::RealBin/example_InstallWrapper_empty.xml");
my @arExpetedEmptyRunCmdList = ();
my @arActualEmptyPostRunCmdList = InstWrapGetPostRunCommandList($xmlTree); 
#print Dumper(\@arExpetedEmptyRunCmdList);
#print Dumper(@arActualEmptyPostRunCmdList);
is_deeply(\@arActualEmptyPostRunCmdList, \@arExpetedEmptyRunCmdList, 'InstWrapGetPostRunCommandList() - empty Run command list.');


my %hFullWrapperConf;

my %hExpectedFullWrapperConf = (
'Note' => 'Just a note.',
          'FileProvidedDuringCloudInit' => {
                                             '/var/virman/vrouter/global.yaml' => {
                                                                                  'DestinationFile' => '/etc/puppet/data/global.yaml',
                                                                                  'SourceType' => 'base64'
                                                                                },
                                             'bravo.tgz' => {
                                                            'DestinationFile' => '/vagrant/InstallWrapper_bravo.tgz',
                                                            'SourceType' => 'Base64'
                                                          }
                                           },
          'PostNetworkConfiguration' => {
                                          '1' => {
                                                 'Name' => 'post1',
                                                 'AutoAssignement' => 'dhcp'
                                               },
                                          '0' => {
                                                 'AutoAssignement' => 'dhcp',
                                                 'Name' => 'post0'
                                               }
                                        },
          'PostAppRunCommand' => [
                                   'post one',
                                   'post two'
                                 ],
          'PreNetworkConfiguration' => {
                                         '0' => {
                                                'Name' => 'pre0',
                                                'AutoAssignement' => 'dhcp'
                                              }
                                       },
          'PreAppRunCommands' => [
                                   'pre one',
                                   'pre two'
                                 ]

                                            );

InstWrapLoadInstallWrapperConfiguration(\%hFullWrapperConf, "$FindBin::RealBin/example_InstallWrapper.xml");
is_deeply(\%hFullWrapperConf, \%hExpectedFullWrapperConf, 'InstWrapLoadInstallWrapperConfiguration()');

