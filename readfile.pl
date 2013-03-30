#!/bin/env perl

open FILE, "/tmp/test" or die "Can't open file: $!\n";
foreach $line (<FILE>) {
  print "$line";
}

# This same using the while loop.

while (<FILE>) {
print $_;
}
