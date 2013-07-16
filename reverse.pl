#!/usr/bin/perl
# reverse.pl
# Reverse the word provided in standard input

print "Enter a word to be reversed: ";
my $word = <STDIN>;
chomp($word);
my $reverse = reverse($word);
#print "reverse($word)\n"
print "$reverse\n";
