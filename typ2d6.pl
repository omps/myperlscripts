#/usr/bin/perl -w

use strict;
my @nums = qw/4 5 8 0 3 6/;

my $i = 0;
while ($i <= $#nums) {
  print $nums[$i++],"\n";
}
