#!/usr/env perl
use strict;
use warnings;
my $n = 0;
## subroutine Example
sub marine {
  $n += 1;
  print "Hello, Sailor number $n!\n";
}

&marine;
&marine;
&marine;
