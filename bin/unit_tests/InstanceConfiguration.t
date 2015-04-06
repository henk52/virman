#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use FindBin;

BEGIN{
	  push( @INC, "$FindBin::RealBin",  "$FindBin::RealBin/..");    ## Path to local modules
}
use Test::More tests => 9;

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
my $refarActualCommandList = InstCfgGetRunCommandsList($xmlTree);
#print Dumper(\@arActualCommandList);
#print Dumper(\@arExpectedCommandList);
is_deeply($refarActualCommandList, \@arExpectedCommandList, 'InstCfgGetRunCommandsList()');

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


