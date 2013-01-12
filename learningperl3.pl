#/usr/bin/perl

use strict;
use warnings;

# print "Enter the name of the rocks: ";
# my @rocks = <STDIN>;
# my @result = reverse(@rocks);

# print "I have\n", @result;


# my @names = qw/fred betty barney dino wilma pebbles bamm-bamm/;
# print "Enter the no.: ";
# chomp(my @num = <STDIN>);
# foreach my $result (@num) {
#   print $names[$result - 1];
# }

# Q3. Chapter 3.
print "Enter the strings: \n";
# Output is sorted, line-by-line
# my @strings = <STDIN>;
# print sort(@strings);
# Output in one line.
chomp(my @strings = <STDIN>);
foreach (@strings) {
  print " ", $_;
}
print "\n";
