#!/usr/bin/perl
=pod

=head1 NAME

stuck.pl - Find and kill stuck processes

=head1 SYNOPSIS

    stuck.pl

=head1 DESCRIPTION

The I<stuck.pl> locates and kills stuck processes.  A stuck process
is one which has consumed more than 60 minutes (I<$max_time>) of CPU.

The process is first killed nicely (SIGTERM), but if it stays around
it is killed hard (SIGKILL).

Note: There is a list in the program of processes which are allowed
to run a long time.  You may want to customize this list for your system.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;
#
# Kill stick processes
#
# A stuck process is one that accumulates over an
# hour of CPU time
#
# NOTE: This program is designed to be nice.
# 	It will send a "nice" kill (SIGTERM) to the process
#	which asks the process to terminate.  If you change
#	this to 'KILL' (SIGKILL) the process will be FORCED
#	to terminate.
#
#	Also no killing is done without operator interaction.
#	
#	If you find that some "user" routinely gets a process
#	stuck, then you may wish to change this and always 
#	kill his long running processes automatically.
#
my $max_time = 60*60;	# Max time a process can have 
			# In seconds

# Process names which are allowed to last a long time
my %exclude_cmds = (
    # Avoid KDE stuff, they really take time
    'kdeinit:' => 1,	
    '/usr/bin/krozat.kss' => 1
);	
# Users to avoid killing
my %exclude_users = (
    root => 1,
    postfix => 1
);
# Use the PS command to get bad people
#WARNING: Linux specific ps command
my @ps = `ps -A -eo cputime,pcpu,pid,user,cmd`;
shift @ps;	# Get rid of the title line
chomp(@ps);

# Loop through each process
foreach my $cur_proc (@ps) {

    # The fields of the process (as names)
    my ($cputime,$pcpu,$pid,$user,$cmd) = 
	split /\s+/, $cur_proc;

    $cputime =~ /(\d+):(\d+):(\d+)/;
    # CPU time in seconds instead of formatted
    my $cpu_seconds = $1*60*60 + $2*60 + $3;

    if ($cpu_seconds < $max_time) {
	next;
    }

    if (defined($exclude_users{$user})) {
	print "User excluded: $cur_proc\n";
	next;
    }

    if (defined($exclude_cmds{$cmd})) {
	print "User excluded: $cur_proc\n";
	next;
    }

    # Someone's stuck.  Ask for the kill
    print "STUCK: $cur_proc\n";
    print "Kill? ";
    my $answer = <STDIN>;

    if ($answer =~ /^[Yy]/) {
	# We kill nicely.  
	kill 'TERM', $pid;
	print "Sent a TERM signal to the process\n";
    }
}
