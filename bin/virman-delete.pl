#!/usr/bin/perl -w

use strict;

# Purpose: create a machine instance, base on a given base machine and template.
# TODO provide template name in CLI.

# Steps:
#  Generate the machine definition in /opt/gas/


use Data::Dumper;
use Text::Template;
use FindBin;
use ExecuteAndTrace;
use Sys::Virt;
use Sys::Virt::Domain;
use XML::Simple;

my $szTemplatePath = "$FindBin::RealBin/../templates";

my $szDomainName = shift || die("!!! You must provide the name of the domain to delete");

# TODO Support --eradicate that will 0 the storage before removing it?

my $szVirshFilePoolPath = '/virt_images';

my %hMachineConfiguration;

# TODO Verify that the domain name exists.

my $uri = 'qemu:///system';
my $vmm = Sys::Virt->new(uri => $uri);
my $dom = $vmm->get_domain_by_name($szDomainName);
my $flags=0;
my $xml = $dom->get_xml_description($flags);
my  $ref = XMLin($xml);


print "---------------------\n";

if ( $dom->is_active() ) {
  print "III Destroy the domain.\n";
  $dom->destroy();
}
  
  print "III undefine the domain $szDomainName.\n";
  $dom->undefine();
 
  my $szBackingFileQcow2 = $ref->{'devices'}{'disk'}{'source'}{'file'};
  print "III remove the storage for $szDomainName - $szBackingFileQcow2\n";
  unlink($szBackingFileQcow2);

Log("III Done.\n");
