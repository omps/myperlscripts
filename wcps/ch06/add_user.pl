#!/usr/bin/perl
=pod

=head1 NAME

add_user.pl - Add a user to the system

=head1 SYNOPSIS

    add_user.pl

=head1 DESCRIPTION

The I<add_user.pl> creates a Linux user.  The script will ask you 
for a user name, full name, and shell and create the user. 

Note: There are other Linux / UNIX scripts for creating a user.  This
one can be customized to suit your purposes.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;
use Fcntl ':flock'; # import LOCK_* constants

# The file we are going to change
my $pw_file = "/etc/passwd";
my $group_file = "/etc/group";
my $shadow_file = "/etc/shadow";

# Get the login name for the user
my $login;	# Login name
print "Login: ";
$login = <STDIN>;
chomp($login);

if ($login !~ /[A-Z_a-z0-9]+/) {
    die("No login specified");
}

open PW_FILE, "<$pw_file" or die("Could not read $pw_file");
# Lock the file for the duration of the program
flock PW_FILE, LOCK_EX;

# Check login information
my $check_uid = getpwnam($login);
if (defined($check_uid)) {
    print "$login already exists\n";
    exit (8);
}

# Find the highest UID.  We'll be that +1
my @pw_info = <PW_FILE>;

my $uid = 0;	# UID for the user

# Find biggest user
foreach my $cur_pw (@pw_info) {
    my @fields = split /:/, $cur_pw;
    if ($fields[2] > 60000) {
	next;
    }
    if ($fields[2] > $uid) {
	$uid = $fields[2];
    }
}
$uid++;

# Each user get his own group.
my $gid = $uid;

# Default home directory
my $home_dir = "/home/$login";

print "Full Name: ";
my $full_name = <STDIN>;
chomp($full_name);

my $shell = "";	# The shell to use
while (! -f $shell) {
    print "Shell: ";
    $shell = <STDIN>;
    chomp($shell);
}

print "Setting up account for: $login [$full_name]\n";

open PW_FILE, ">>$pw_file" or 
    die("Could not append to $pw_file");
print PW_FILE 
"${login}:x:${uid}:${gid}:${full_name}:${home_dir}:$shell\n";

open GROUP_FILE, ">>$group_file" or 
   die("Could not append to $group_file");
print GROUP_FILE "${login}:x:${gid}:$login\n";
close GROUP_FILE;

open SHADOW, ">>$shadow_file" or 
    die("Could not append to $shadow_file");
print SHADOW "${login}:*:11647:0:99999:7:::\n";
close SHADOW;

# Create the home directory and populate it
mkdir($home_dir);
chmod(0755, $home_dir);
system("cp -R /etc/skel/.[a-zA-Z]* $home_dir");
system("find $home_dir -print ".
       "-exec chown ${login}:${login} {} \\;");

# Set the password for the user
print "Setting password\n";
system("passwd $login");

flock(PW_FILE,LOCK_UN);
close(PW_FILE);
