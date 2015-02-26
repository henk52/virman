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

my $szTemplatePath = "$FindBin::RealBin/../templates";

my $szVirshFilePoolPath = '/virt_images';

my %hMachineConfiguration;

my $f_szFedoraBaseName = 'baseks';

$hMachineConfiguration{'szGasBaseDirectory'} = '/opt/gas';


$hMachineConfiguration{'szGuestName'} = 'vrouter';
$hMachineConfiguration{'szGuestTitle'} = 'Virtual Router';
$hMachineConfiguration{'szGuestDescription'} = 'Virtual router.';

# The amount of memory allocate to the Guest in KiB.
$hMachineConfiguration{'szGuestMemory'} = '786432';

# file: cqow2
$hMachineConfiguration{'szGuestDiskType'} = 'file';

$hMachineConfiguration{'szGuestDriverType'} = 'qcow2';

$hMachineConfiguration{'szGuestDiskSourceTypeName'} = 'file';
$hMachineConfiguration{'szGuestStorageDevice'} = "${szVirshFilePoolPath}/$hMachineConfiguration{'szGuestName'}.qcow2";

my @arPublicNetworkList = (
  'virbr0',
);
$hMachineConfiguration{'arPublicNetworkList'} = \@arPublicNetworkList;

my @arPrivateNetworkList = (
  'nm',
  'cont1',
  'cont2',
  'zczc',
);

$hMachineConfiguration{'arPrivateNetworkList'} = \@arPrivateNetworkList;


print "---------------------\n";
my $szTemplateFile = "$szTemplatePath/vrouter_xml.tmpl";
#my $szTemplateFile = "$szTemplatePath/test.tmpl";

my $template = Text::Template->new(TYPE => 'FILE', SOURCE => "$szTemplateFile")
         or die "Couldn't construct template: $Text::Template::ERROR";

#print "DDD szTemplateFile: $szTemplateFile\n";
#print "DDD template: $template\n";
#print Dumper($template);

my $szResult = $template->fill_in(HASH => \%hMachineConfiguration);
# print $szResult ;
 
print "III Writing: $hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml\n";
open (OUTPUT_TEMPLATE, ">$hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml") || die("!!! failed to open file for write: $hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml - $!");
print OUTPUT_TEMPLATE "$szResult";
close(OUTPUT_TEMPLATE);

# TODO Also support LVM.
if ( $hMachineConfiguration{'szGuestDriverType'} eq 'qcow2' ) {
  print "III Cloning $f_szFedoraBaseName for use by $hMachineConfiguration{'szGuestName'}\n";
  DieIfExecuteFails("virt-clone --connect qemu:///system --original $f_szFedoraBaseName --name $hMachineConfiguration{'szGuestName'} --file $hMachineConfiguration{'szGuestStorageDevice'}");

  print "III Create the instance of $hMachineConfiguration{'szGuestName'}\n";
  DieIfExecuteFails("virsh define --file $hMachineConfiguration{'szGasBaseDirectory'}/$hMachineConfiguration{'szGuestName'}.xml");
}

# TODO Generate the configuration ISO image.
# Provide the image to the container, or should that be part of the XML generation?

print "III Done.\n";
