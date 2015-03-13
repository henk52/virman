#!/usr/bin/perl -w

use strict;

use Test::Harness;

my @arTestFiles = qw(
  unit_tests/ConfiguredNetworks.t
                  );

runtests(@arTestFiles);

