#!/usr/bin/perl -w

use strict;
my $in = '';               # Temporary input.
my %names = ();             # Hash of names.
my $fn = '';                # Temp firstname.
my $ln = '';               # Temp lastname.

while () {
  print "Enter a name (first and last): ";
  chomp($in = <STDIN>);
  if ($in ne '') {
    ($fn, $ln) = split(' ', $in);
    $names{$ln} = $fn;
  }
  else { last };
}

foreach my $lastname (sort keys %names) {
  print "$lastname, $names{$lastname}\n";
}
