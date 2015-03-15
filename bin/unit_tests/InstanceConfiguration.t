#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use FindBin;


use Test::More tests => 7;

use InstanceConfiguration;

my $xmlTree = InstCfgLoadXml("$FindBin::RealBin/example_InstanceConfiguration.xml");
is($xmlTree->{'Version'}, '0.1.0', 'Was able to read the xml file.');

is(GetBaseDomainName($xmlTree), 'rhel63_x86_64', 'GetBaseDomainName()');

is(GetDescription($xmlTree), 'Monitor machine', 'GetDescription()');
is(GetInstanceType($xmlTree), 't2.micro', 'GetInstanceType()');
is(GetNameOfAdminUserAccount($xmlTree), 'vagrant', 'GetNameOfAdminUserAccount()');

my %ExpectedNetworkConfiguration = (
     'default' => {
                    'Index' => 0,
                    'AutoAssignement' => 'dhcp'
                  },
     'configuration' => {
                    'Index' => 1,
                    'AutoAssignement' => 'dhcp'
                  },
     'internal' => {
                    'Index' => 2,
                   }
   );
my %hActualNetworkConfiguration = InstCfgGetNetworkHash($xmlTree);
is_deeply(\%hActualNetworkConfiguration, \%ExpectedNetworkConfiguration, 'GetNetworkHash().');

is(InstCfgGetInstallWrapper($xmlTree), 'ripwrap', 'InstCfgGetInstallWrapper()');
