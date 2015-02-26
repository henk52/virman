package ExecuteAndTrace;
use strict;       # Be strict on the syntax and semantics, var must be defined prior to use.
use vars qw(@ISA @EXPORT $VERSION);
use Exporter;
use Carp;
use Data::Dumper;
use POSIX;

use YAML::XS qw/LoadFile Dump/;


$VERSION = 0.2.0;
@ISA = ('Exporter');

# List the functions and var's that must be available.
# If you want to create a global var, create it as 'our'
@EXPORT = qw(
                &DieIfExecuteFails
                &Log
                &LogOnly
            );

my $f_szDataDirectory = "/var/log";
my $f_szLogFileName = "virman.log";

# -----------------------------------------------------------------
# ---------------
sub DieIfExecuteFails {
  my $szCmd = shift;

  # TODO V die on empty command.

  my @arOutput = `$szCmd`;
  if ( $? != 0 ) {
    confess("!!! operaiont failed: @arOutput");
  }
} # end DieIfExecuteFails


sub GetTimeStamp {
  return( strftime("%Y%m%d%H%M", localtime(time)) );
}
 
 
sub Log {
  my $szLogMessage = shift;
  my $szTimeStamp = GetTimeStamp();
 
  `echo "$szTimeStamp:$szLogMessage" >> $f_szDataDirectory/$f_szLogFileName`;
  print "$szTimeStamp:$szLogMessage\n";
}
 
sub LogOnly {
  my $szLogMessage = shift;
  my $szTimeStamp = GetTimeStamp();
 
  `echo "$szTimeStamp:$szLogMessage" >> $f_szDataDirectory/$f_szLogFileName`;
}

# This ends the perl module/package definition.
1;

