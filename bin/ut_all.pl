#!/usr/bin/perl -w

use strict;

use Test::Harness;

my @arTestFiles = qw(
  unit_tests/ConfiguredNetworks.t
  unit_tests/InstanceConfiguration.t
  unit_tests/Default.t
  unit_tests/InfoGather.t
  unit_tests/InfoProcessing.t
  unit_tests/InfoExecute.t
  unit_tests/InstallWrapper.t
  unit_tests/GlobalYaml.t
  unit_tests/Common.t
                  );

runtests(@arTestFiles);

