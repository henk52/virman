#!/usr/bin/perl -w

use strict;

# Purpose: create a machine instance, base on a given base machine and template.
# TODO provide template name in CLI.

# Steps:
#  Generate the machine definition in /opt/gas/


# TODO split this into three PMs: reading data, handling the data, writing the output and generating the actual clone.

use FindBin;
BEGIN{
	  push( @INC, "$FindBin::RealBin" );    ## Path to local modules
}

use Data::Dumper;
use ExecuteAndTrace;
use XML::Simple;


use ConfiguredNetworks;
use Default;
use InstanceConfiguration;
use InfoGather;
use InfoExecute;




my %f_hVirmanConfiguration;
my $f_szVirmanConfigurationFile = "/etc/virman/default.xml";

my $f_szInstanceNumber = "001";

my $szTemplatePath = "$FindBin::RealBin/../templates";
my $szFilesPath = "$FindBin::RealBin/../files";

# TODO C put this in a protected directory.
my $f_szGeneralContainerKeyFile;

# TODO V read this from the /etc/virman/defaults. 
my $szVirshFilePoolPath = '/virt_images';

my %f_hMachineConfiguration;

# TODO V Read the networks that have been configured to validate the ones
#         the apps are asking for.



# ======================================= FUNCTIONS ================================



# ====================================== MAIN ============================================ 

my $szDomainName = shift || die("!!! You must provide a role name.");


# TODO Support list the supported roles.
# TODO Support manual instance number?

IGLoadVirmanConfiguration(\%f_hVirmanConfiguration, $f_szVirmanConfigurationFile);

my $szXmlConfigurationFilename = "$f_hVirmanConfiguration{'InstanceCfgBasePath'}/${szDomainName}/${szDomainName}.xml";

if ( ! -f "$szXmlConfigurationFilename" ) {
  die("!!! Domain name '$szDomainName' does not have a role.xml file in $f_hVirmanConfiguration{'RolesRelativePath'}");
}

my %hInstanceConfiguration;
IGReadInstanceConfiguration(\%hInstanceConfiguration, $szXmlConfigurationFilename);

SetMachineConfiguration(\%f_hMachineConfiguration, \%f_hVirmanConfiguration, \%hInstanceConfiguration, $szDomainName);


# TODO C Read the InstallWrapper is given.
# ReadInsatllWrapper

# TODO C Merge the InstallWrapper hash and the instance configuration.

# TODO Return the path to the domain xml file.
GenerateCloudInitIsoImage(\%hInstanceConfiguration, \%f_hVirmanConfiguration, \%f_hMachineConfiguration, $f_szInstanceNumber);

my $szBackingFileQcow2 = IEGetBackingFile(\%hInstanceConfiguration);

IECreateInstance();

Log("III Done.\n");
