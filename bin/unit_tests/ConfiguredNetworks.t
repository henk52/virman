#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use FindBin;


use Test::More tests => 1;

use ConfiguredNetworks;

my $xmlTree = CfgNetsLoadXml("$FindBin::RealBin/example_ConfiguredNetworks.xml");
is($xmlTree->{'Version'}, '0.1.0', 'Was able to read the xml file.');
