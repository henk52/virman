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


use ConfiguredNetworks;
use Default;
use InstanceConfiguration;
use InfoGather;
use InfoProcessing;
use InfoExecute;
use InstallWrapper;

my $f_szVersion = "0.2.0";



my %f_hVirmanConfiguration;
my $f_szVirmanConfigurationFile = "/etc/virman/default.xml";

my $f_szInstanceNumber = "001";

my $szTemplatePath = "$FindBin::RealBin/../templates";
my $f_szFilesPath = "$FindBin::RealBin/../files";

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

# %hInstanceConfiguration - The data from the instance.xml file.
# %f_hVirmanConfiguration - The data from the /etc/virman/default.xml.
# %f_hMachineConfiguration - the data going into the domain xml file.

IGLoadVirmanConfiguration(\%f_hVirmanConfiguration, $f_szVirmanConfigurationFile);

$f_hVirmanConfiguration{'FilesPath'} = $f_szFilesPath;

my $szXmlConfigurationFilename = "$f_hVirmanConfiguration{'InstanceCfgBasePath'}/${szDomainName}/${szDomainName}.xml";

if ( ! -f "$szXmlConfigurationFilename" ) {
  die("!!! Domain name '$szDomainName' does not have a role.xml file in $f_hVirmanConfiguration{'RolesRelativePath'}");
}

my %hInstanceConfiguration;
print "III Instance source XML file: $szXmlConfigurationFilename\n";
IGReadInstanceConfiguration(\%hInstanceConfiguration, $szXmlConfigurationFilename);
print "DDD hInstanceConfiguration after call to IGReadInstanceConfiguration()\n";
print Dumper(\%hInstanceConfiguration);

# If an install wrapper has been defined then use it.
if ( exists($hInstanceConfiguration{'InstallWrapper'}) && $hInstanceConfiguration{'InstallWrapper'} ne "" ) {
  my %hInstallWrapperConfiguration;
  InstWrapLoadInstallWrapperConfiguration(\%hInstallWrapperConfiguration, "$f_hVirmanConfiguration{'InstallWrapperPath'}/$hInstanceConfiguration{'InstallWrapper'}.xml");
  print "DDD hInstallWrapperConfiguration after call to InstWrapLoadInstallWrapperConfiguration()\n";
  print Dumper(\%hInstallWrapperConfiguration);
  # Merge the InstallWrapper hash and the instance configuration.
  IPMergeInstanceAndWrapperInfo(\%hInstanceConfiguration, \%hInstallWrapperConfiguration);
  print "DDD hInstanceConfiguration after IPMergeInstanceAndWrapperInfo()\n";
  print Dumper(\%hInstanceConfiguration);
}



IPSetMachineConfiguration(\%f_hMachineConfiguration, \%f_hVirmanConfiguration, \%hInstanceConfiguration, $szDomainName, $f_szInstanceNumber);


# TODO Return the path to the domain xml file.
IEGenerateCloudInitIsoImage(\%hInstanceConfiguration, \%f_hVirmanConfiguration, \%f_hMachineConfiguration, $f_szInstanceNumber);

my $szBackingFileQcow2 = IEGetBackingFile(\%hInstanceConfiguration);

IECreateInstance(\%hInstanceConfiguration, \%f_hVirmanConfiguration, \%f_hMachineConfiguration, $szTemplatePath, $szBackingFileQcow2);

Log("III Done.\n");
