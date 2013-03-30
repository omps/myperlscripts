#!/usr/bin/perl
=pod

=head1 NAME

dis_user.pl - Disable a user

=head1 SYNOPSIS

    dis_user.pl <user>

=head1 DESCRIPTION

The I<dis_user.pl> command disables a user account.  If he is logged in, he told
that the account is being disabled and given few seconds to get out of town.
Then all his processes are killed and account disabled.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

if ($#ARGV != 0) {
    print STDERR "Usage is $0 <account>\n";
}

my $user = $ARGV[0];

# Get login information
my $uid = getpwnam($user);
if (not defined($uid)) {
    print "$user does not exist.\n";
    exit (8);
}

system("passwd -l $user");
my @who = `who`;
@who = grep /^$user\s/,@who;
foreach my $cur_who (@who) {
    my @words = split /\s+/, $cur_who;
    my $tty = $words[1];

    if (not open(YELL, ">>/dev/$tty")) {
	next;
    }
    print YELL <<EOF ;
*********************************************************
URGENT NOTICE FROM THE SYSTEM ADMINISTRATOR

This account is being suspended.  You are going to be
logged out in 10 seconds.  Please exit immediately.
*********************************************************
EOF
    close YELL;
}
sleep(10);
my @procs = `ps -u $user`;
shift @procs;
foreach my $cur_proc (@procs) {
    $cur_proc =~ /(\d+)/;
    if (defined($1)) {
	print "Killing $1\n";
	kill 9, $1;
    }
}


