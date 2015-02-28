#!/usr/bin/perl -w
use strict;

use Data::Dumper;

use Sys::Virt;
use Sys::Virt::Domain;
#use XML::Simple qw(:strict);
use XML::Simple;

my $uri = 'qemu:///system';
my $vmm = Sys::Virt->new(uri => $uri);
my $name = 'baseks';
my $dom = $vmm->get_domain_by_name($name);

my $flags=0;
my $xml = $dom->get_xml_description($flags);

#print Dumper($xml);
my  $ref = XMLin($xml);
#print Dumper($ref);
#print Dumper($ref->{'devices'}{'disk'});
# TODO Get the driver to make sure it is a 'qcow2'.
my $szQcow2File = $ref->{'devices'}{'disk'}{'source'}{'file'};

print "QCOW2 file: $szQcow2File\n";
