#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use FindBin;

BEGIN{
	  push( @INC, "$FindBin::RealBin",  "$FindBin::RealBin/..");    ## Path to local modules
}
use Test::More tests => 10;

use InstanceConfiguration;

my $xmlTree = InstCfgLoadXml("$FindBin::RealBin/example_InstanceConfiguration.xml");
is($xmlTree->{'Version'}, '0.1.0', 'Was able to read the xml file.');

is(GetBaseDomainName($xmlTree), 'rhel63_x86_64', 'GetBaseDomainName()');

is(GetDescription($xmlTree), 'Monitor machine', 'GetDescription()');
is(GetInstanceType($xmlTree), 't2.micro', 'GetInstanceType()');
is(GetNameOfAdminUserAccount($xmlTree), 'vagrant', 'GetNameOfAdminUserAccount()');

my %ExpectedNetworkConfiguration = (
     '0' => {
                    'Name' => 'inst0',
                    'AutoAssignement' => 'dhcp'
                  },
     '1' => {
                    'Name' => 'inst1',
                    'AutoAssignement' => 'dhcp'
                  },
     '2' => {
                    'Name' => 'inst2',
                   },
     '3' => {
                    'Name' => 'fix1',
                    'AutoAssignement' => 'static',
                    'IpAddress' => '10.1.2.3',
                    'NetMask' => '255.255.255.0'
                   }
   );
my %hActualNetworkConfiguration = InstCfgGetNetworkHash($xmlTree);
is_deeply(\%hActualNetworkConfiguration, \%ExpectedNetworkConfiguration, 'GetNetworkHash().');

is(InstCfgGetInstallWrapper($xmlTree), 'ripwrap', 'InstCfgGetInstallWrapper()');

#print Dumper($xmlTree);

my @arExpectedCommandList = ( 'command1', 'command2');
my @arActualCommandList = InstCfgGetRunCommandsList($xmlTree);
#print Dumper(\@arActualCommandList);
#print Dumper(\@arExpectedCommandList);
is_deeply(\@arActualCommandList, \@arExpectedCommandList, 'InstCfgGetRunCommandsList()');

my %hExpectedFileList = (
    'alpha.tgz' => {
        'SourceType' => 'Base64',
        'DestinationFile' => '/vagrant/alpha.tgz'
    },
    'bravo.tgz' => {
        'SourceType' => 'Base64',
        'DestinationFile' => '/vagrant/bravo.tgz'
    }
    
                        );
my %hActualFileList = InstCfgGetFileProvidedDuringCloudInit($xmlTree);
#print Dumper(\%hActualFileList);
is_deeply(\%hActualFileList, \%hExpectedFileList, 'InstCfgGetFileProvidedDuringCloudInit()');


my %hExpectedConfiguration = (
 'BaseDomainName' => 'rhel63_x86_64',
          'RunCommand' => [
                            'command1',
                            'command2'
                          ],
          'InstallWrapper' => 'ripwrap',
          'FileProvidedDuringCloudInit' => {
                                             'alpha.tgz' => {
                                                            'SourceType' => 'Base64',
                                                            'DestinationFile' => '/vagrant/alpha.tgz'
                                                          },
                                             'bravo.tgz' => {
                                                            'SourceType' => 'Base64',
                                                            'DestinationFile' => '/vagrant/bravo.tgz'
                                                          }
                                           },
          'NameOfAdminUserAccount' => 'vagrant',
          'NetworkConfiguration' => {
                                      '1' => {
                                             'AutoAssignement' => 'dhcp',
                                             'Name' => 'inst1'
                                           },
                                      '3' => {
                                             'Name' => 'fix1',
                                             'NetMask' => '255.255.255.0',
                                             'AutoAssignement' => 'static',
                                             'IpAddress' => '10.1.2.3'
                                           },
                                      '0' => {
                                             'AutoAssignement' => 'dhcp',
                                             'Name' => 'inst0'
                                           },
                                      '2' => {
                                             'Name' => 'inst2'
                                           }
                                    },
          'Description' => 'Monitor machine',
          'ScalarKeyValues' => {
            'AppPuppetClassName' => 'app-tut',
            'Charlie' => 'CValue'            
          },
    );

my %hActualConfiguration;
InstCfgLoadInstanceConfiguration(\%hActualConfiguration, "$FindBin::RealBin/example_InstanceConfiguration.xml");

#print Dumper(\%hActualConfiguration);


is_deeply(\%hActualConfiguration, \%hExpectedConfiguration, 'InstCfgLoadInstanceConfiguration()');



