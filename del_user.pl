#!/usr/bin/perl
=pod

=head1 NAME

del_user.pl - Delete a user

=head1 SYNOPSIS

    del_user.pl <user>

=head1 DESCRIPTION

The I<del_user.pl> delete a user.  There are other Linux / UNIX scripts
however this one may be customized.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;
use Fcntl ':flock'; # import LOCK_* constants

if ($#ARGV != 0) {
    print STDERR "Usage is $0 <user>\n";
    exit (8);
}

my $user = $ARGV[0];

sub edit_file($)
{
    my $file = shift;

    open IN_FILE, "<$file" or 
	die("Could not open $file for input");

    open OUT_FILE, ">$file.new" or 
	die("Could not open $file.new for output");

    while (1) {
	my $line = <IN_FILE>;
	if (not defined($line)) {
	    last;
	}
	if ($line =~ /^$user/) {
	    next;
	}
	print OUT_FILE $line;
    }
    close (IN_FILE);
    close (OUT_FILE);
    unlink("$file.bak");
    rename("$file", "$file.bak");
    rename("$file.new", $file);
}

my @info = getpwnam($user);
if (@info == -1) {
    die("No such user $user");
}

open PW_FILE, "</etc/passwd" or 
    die("Could not read /etc/passwd");

# Lock the file for the duration of the program
flock PW_FILE, LOCK_EX;

edit_file("/etc/group");
edit_file("/etc/shadow");

if ($info[7] eq "/home/$user") {
    system("rm -rf /home/$user");
} else {
    print "User has a non-standard home directory.\n";
    print "Please remove manually.\n";
    print "Directory = $info[7]\n";
}
print "User $user -- Deleted\n";

edit_file("/etc/passwd");

flock(PW_FILE,LOCK_UN);
close(PW_FILE);
