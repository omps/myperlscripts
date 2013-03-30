#!/usr/bin/perl
=pod

=head1 NAME

lock-out.pl - Lock out people who are hacking

=head1 SYNOPSIS

    lock-out.pl <error-log>

=head1 DESCRIPTION

The I<lock-out.pl> program watches the error log and locks out anyone who
is trying to penetrate your system.

The offending system is locked out by adding an entry to the routing table:

    /sbin/route add <ip> reject

Note: There may be other ways of doing this, but this is the one used by this script.

The program uses a simple technique to detect hacking
entries, specifically

1) Attempts to access any URL with the word "winnt" in it.

2) Attempts to access a cgi script which doesn't exist.

=head1 NOTE 

There are better security solutions out there.
You may want to check out http://www.snort.org for 
one.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
# WARNING: There are many different ways to lock
# a system out.  This script use 
#	/sbin/route add <ip> reject
# Adjust this command to suit your system.
#
#
# When someone tries to hack us, lock him out
# of the system for 30 minutes.
#
# Lockout is accomplished by setting the route
# for the bad systems to an impossible value
#
#
# Uses a simple technique to detect hacking
# entries, specifically
#
# 1) Attempts to access any URL with the word
#	"winnt" in it.
# 2) Attempts to access a cgi script which doesn't
# 	exist.

# 
# Note: There are better security solutions out there.
# You may want to check out http://www.snort.org for 
# one.



# 
# Usage:
#	lock-out.pl <error_log> 
#	(Assumes that error_log is still being written)

use strict;
use warnings;
use File::Tail;
use Socket;	# For AF_INET

use constant JAIL_TIME => (30*60);	# 30 minutes
use constant TIMEOUT => (30);		# Check every 30 sec.

# Key -> Who hacked, value => Time left in route jail
my %hackers;	

#
# Lock out a user by sending all his packets to nowhere
#
sub lock_out($) {
    my $who = shift;	# Who to lock out

    # Put the IP address in jail
    $hackers{$who} = time() + JAIL_TIME;
    my $now = localtime;	# The time now
    print "$now Locking out $who\n";
    system("/sbin/route add $who reject");
}
#
# Unlock a user by removing a lock
#
sub unlock_out($) {
    my $who = shift;	# Who to not lock out

    my $now = localtime;	# The time now
    print "$now Unlocking out $who\n";
    system("/sbin/route del $who reject");
}
#
# Return the name of a hacker if this is a hack entry
#
sub is_hacker($)
{
    my $line = shift;	# Line from the log


    $line =~ /client ([^\]]*)\]/;
    my $who = $1;		# who hacked us

    # Did someone try to get to the NT stuff
    if ($line =~ /winnt/) {
	return ($who);
    }

    # Did someone try to exploit a bad URL
    if ($line =~ /cgi-bin/) {
	return ($who);
    }
    # Did someone try the %2E trick
    if ($line =~ /%2E/) {
    	return ($who);
	next;
    }
    return (undef);
}
#------------------------------------------------------------
if ($#ARGV != 0) {
    print "Usage is $0 <error-log>\n";
    exit (8);
}

my $in_file = File::Tail->new(name => $ARGV[0]);

while (1) {
    my $nfound;		# Number of FDs on which 
    			# select found something
    my $timeleft;	# Time left in the timeout
    my @pending;	# File::Tail items with input pending

    # Wait for I/O from the log file, or a timeout
    ($nfound, $timeleft, @pending) = File::Tail::select(
	undef, undef, undef, TIMEOUT, $in_file);

    if ($#pending != -1) {
	# Read the line from the file
	my $line = $pending[0]->read();	

	# Get who(if anyone) hacked us
	my $who = is_hacker($line);
	if (defined($who)) {
	    lock_out($who);
	}
    }
    # Check to see if anyone should come back
    foreach my $who (keys %hackers) {
	if ($hackers{$who} < time()) {
	    unlock_out($who);
	    delete $hackers{$who};
	}
    }
}

