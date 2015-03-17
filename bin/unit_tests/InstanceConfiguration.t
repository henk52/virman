#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use FindBin;

BEGIN{
	  push( @INC, "$FindBin::RealBin",  "$FindBin::RealBin/..");    ## Path to local modules
}
use Test::More tests => 7;

use InstanceConfiguration;

my $xmlTree = InstCfgLoadXml("$FindBin::RealBin/example_InstanceConfiguration.xml");
is($xmlTree->{'Version'}, '0.1.0', 'Was able to read the xml file.');

is(GetBaseDomainName($xmlTree), 'rhel63_x86_64', 'GetBaseDomainName()');

is(GetDescription($xmlTree), 'Monitor machine', 'GetDescription()');
is(GetInstanceType($xmlTree), 't2.micro', 'GetInstanceType()');
is(GetNameOfAdminUserAccount($xmlTree), 'vagrant', 'GetNameOfAdminUserAccount()');

my %ExpectedNetworkConfiguration = (
     '0' => {
                    'Name' => 'default',
                    'AutoAssignement' => 'dhcp'
                  },
     '1' => {
                    'Name' => 'configuration',
                    'AutoAssignement' => 'dhcp'
                  },
     '2' => {
                    'Name' => 'internal',
                   }
   );
my %hActualNetworkConfiguration = InstCfgGetNetworkHash($xmlTree);
is_deeply(\%hActualNetworkConfiguration, \%ExpectedNetworkConfiguration, 'GetNetworkHash().');

is(InstCfgGetInstallWrapper($xmlTree), 'ripwrap', 'InstCfgGetInstallWrapper()');
