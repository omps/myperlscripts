#!/usr/bin/perl
# this script is not working for searching in google, since it requires LWP::UserAgent module. Please refere search_google.pl where i have used LWP::UserAgent module.
use warnings;
use strict;

use LWP::Simple;
print "Enter the thing to search: ";
chomp(my $search = <STDIN>);

my $content = get("http://www.google.com/search?q=");
die "Couldn't get it!" unless defined $content;
my $result = $content . $search;
print $result;
