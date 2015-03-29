#!/usr/bin/perl -w
use strict;

################################################################################
#
#                         P E R L  U N I T  T E S T  F I L E  
#
################################################################################
#
#   DATE OF ORIGIN  : Mar 18, 2015
#
#----------------------------------- PURPOSE ------------------------------------
#
# This module will 
#
#
################################################################################

use FindBin;

BEGIN {
  unshift( @INC, "$FindBin::RealBin/unit_tests", "$FindBin::RealBin", "$FindBin::RealBin/.." );    ## Path to local modules
}

use Data::Dumper;

use Test::More tests => 2;
#use Test::Exception;

# In the hopes that it will use my unit_test version.
#use ExecuteAndTrace;

# TODO C 'use' the perl module that is to be tested.
use InfoExecute;


# ==============================================================================
#                              V A R I A B L E S
# ==============================================================================



# ==============================================================================
#                                   T E S T S 
# ==============================================================================

# -----------------------------------------------------------------
# ---------------



my %hCombinedInstanceAndWrapperConf = (
                     'BaseDomainName' => 'base',
                     'NetworkConfiguration' => {
                             '0' => {
                             'AutoAssignement' => 'dhcp',
                             'Name' => 'pre0'
                                    }
                     }
                                      );
my %hMachineConfiguration = (
                     'szGuestName' => 'GUEST_NAME',
                     'szIsoImage'  => 'test.iso',
                     'szGuestStorageDevice' => 'guest_device',
                     'szGasBaseDirectory' => '.',
                     'szGuestDriverType' => 'qcow2',
                     'InstanceTempDirectory' => 'tmp_instance'
                            );
my %hVirmanConfiguration = (
                     'SshPath' => '.',
                     'CloudInitIsoFiles' => '.',
                     'FilesPath' => '.'
                           );
my $szInstanceNumber = '008';

my $szSshPubFile = "$hVirmanConfiguration{'SshPath'}/virman.pub";
`touch $szSshPubFile`;

my $szPostConfigTgzFile = "postconfig-0.1.0-noarch.tgz";
`echo "CONTENT" > $szPostConfigTgzFile`;

`mkdir $hMachineConfiguration{'InstanceTempDirectory'}`;

my $nStatus = IEGenerateCloudInitIsoImage(\%hCombinedInstanceAndWrapperConf, \%hVirmanConfiguration, \%hMachineConfiguration, $szInstanceNumber);
is($nStatus, 0, 'superficial test of IEGenerateCloudInitIsoImage()');

my $szBackingFileQcow2 = "backing.qcow2";
my $szTemplatePath = "$FindBin::RealBin/../../templates";

$nStatus = IECreateInstance(\%hCombinedInstanceAndWrapperConf, \%hVirmanConfiguration, \%hMachineConfiguration, $szTemplatePath, $szBackingFileQcow2);
is($nStatus, 0, 'superficial test of IECreateInstance()');

# TODO V Make sure the 'domain'.xml is good.

unlink("virman.pub");
unlink("virman");
unlink("$hMachineConfiguration{'InstanceTempDirectory'}/test.iso");
unlink("$hMachineConfiguration{'InstanceTempDirectory'}/user-data");
unlink("$hMachineConfiguration{'InstanceTempDirectory'}/meta-data");
unlink("$hMachineConfiguration{'InstanceTempDirectory'}/global.yaml");
unlink("$hMachineConfiguration{'InstanceTempDirectory'}/$hMachineConfiguration{'szGuestName'}.xml");
`rmdir $hMachineConfiguration{'InstanceTempDirectory'}`;

unlink("$szSshPubFile");
unlink("$szPostConfigTgzFile");

