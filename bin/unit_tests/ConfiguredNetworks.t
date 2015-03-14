#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use FindBin;


use Test::More tests => 3;

use ConfiguredNetworks;

my $xmlTree = CfgNetsLoadXml("$FindBin::RealBin/example_ConfiguredNetworks.xml");
is($xmlTree->{'Version'}, '0.1.0', 'Was able to read the xml file.');


my @arExpectedListOfBridgeNetworkNames = [ 'default' ];

my @arListOfBridgeNetworkNames = GetListOfBridgeNetworkNames($xmlTree);
is_deeply(@arListOfBridgeNetworkNames, @arExpectedListOfBridgeNetworkNames, 'GetListOfBridgedNetworkNames()');

my @arExpectedListOfInternalNetworkNames = [ 'internal', 'external' ];
my @arListOfInternalNetworkNames = GetListOfInternalNetworks($xmlTree);
is_deeply(@arListOfInternalNetworkNames, @arExpectedListOfInternalNetworkNames, 'GetListOfInternalNetworkNames()');
