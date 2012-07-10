#!/usr/bin/perl
use warnings;
use strict;
#use Net::SSH(openssh2);
my $host;
my $hostlist = "/home/singho/perlscripts/hostlist";

open HOSTS, $hostlist or die "Unable to open $hostlist: $!\n";

while (<HOSTS>) {
    print "$host\n";
}
