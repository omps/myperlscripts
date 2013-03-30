#!/usr/bin/perl

use LWP::Simple;

$url = 'http://www.linux.com';

my $content = get $url or die "Couldn't get to the content: $\n";;

print "$content";
