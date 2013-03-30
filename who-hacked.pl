#!/usr/bin/perl
=pod

=head1 NAME

who-hacked.pl - Print a list of people who tried to hack your system

=head1 SYNOPSIS

    who-hacked.pl <rror-log> [<file>...]

=head1 DESCRIPTION

The I<who-hacked.pl> program analyzes the error logs and prints a list
of people who tried to break into the system.

The program uses a simple technique to detect hacking
entries, specifically

1) Attempts to access any URL with the word "winnt" in it.

2) Attempts to access a cgi script which doesn't exist.

=head1 NOTE 

There are better security solutions out there.
You may want to check out http://www.snort.org for 
one.

=head1 EXAMPLE

    who-hacked.pl /var/log/httpd/error*
    561 192.168.0.30     vcr.oualline.com
     16 69.46.195.55     --unknown--
      8 66.193.160.126   --unknown--
      7 208.34.72.10     --unknown--
      6 66.193.231.55    shiva.gameanon.net
      5 65.207.49.69     host69.aetherquest.com
      4 212.253.2.202    --unknown--
      1 67.127.197.89    adsl-67-127-197-89.dsl.lsan03.pacbell.net
      1 208.57.32.21     san-cust-208.57.32.21.mpowercom.net
      1 218.1.164.46     --unknown--
      1 207.192.252.238  cm-207-192-252-238.stjoseph.mo.npgco.com
      1 64.79.3.92       Host03.ImageSnap.Com
      1 202.107.202.14   --unknown--
      1 207.192.241.9    --unknown--

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut

#
# Print out a list of who tried to hack
# the system.
#
# Uses a simple technique to detect hacking
# entries, specifically
#
# 1) Attempts to access any URL with the word
#	"winnt" in it.
# 2) Attempts to access a cgi script which doesn't
# 	exist.

# 
# Usage:
#	who_hacked <error_log> [<error_log> ...]

use strict;
use warnings;
use Socket;	# For AF_INET

my %hackers;	# Who hacked

while (<>) {
    $_ =~ /client ([^\]]*)\]/;
    my $who = $1;		# who hacked us

    # Did someone try to get to the NT stuff
    if ($_ =~ /winnt/) {
	$hackers{$who}++;
	next;
    }

    # Did someone try to exploit a bad URL
    if ($_ =~ /cgi-bin/) {
	$hackers{$who}++;
	next;
    }

    # Did someone try the %2E trick
    if ($_ =~ /%2E/) {
	$hackers{$who}++;
	next;
    }
}

my @hack_array;	# Hackers as an array

# Turn page hash into an array
foreach my $hacker (keys %hackers) {
    push(@hack_array, {
	hacker => $hacker,
	count => $hackers{$hacker}
    });
}

# Get the "top" hackers
my @hack_top = 
    sort { $b->{count} <=> $a->{count} } @hack_array;

for (my $i = 0; $i < 25; ++$i) {
    if (not defined($hack_top[$i])) {
	last;
    }
    # Turn address into binary
    my $iaddr = inet_aton($hack_top[$i]->{hacker});

    # Turn address into name (and stuff)
    my @host_info = gethostbyaddr($iaddr, AF_INET);

    # Handle bad names
    if (not defined($host_info[0])) {
	@host_info = "--unknown--";
    }
    printf "%3d %-16s %s\n", $hack_top[$i]->{count}, 
    	$hack_top[$i]->{hacker}, $host_info[0];
}
