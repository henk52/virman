#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Text::Template;
use FindBin;

my $szTemplatePath = "$FindBin::RealBin/../templates";

my $szVirshFilePoolPath = '/virt_images';

my %hMachineConfiguration;

$hMachineConfiguration{'szFedoraBaseName'} = 'baseks';

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

print "DDD szTemplateFile: $szTemplateFile\n";
print "DDD template: $template\n";
print Dumper($template);

my $szResult = $template->fill_in(HASH => \%hMachineConfiguration);
 print $szResult ;
 
