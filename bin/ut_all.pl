#!/usr/bin/perl -w

use strict;

use Test::Harness;

my @arTestFiles = qw(
  unit_tests/ConfiguredNetworks.t
  unit_tests/InstanceConfiguration.t
  unit_tests/Default.t
                  );

runtests(@arTestFiles);

