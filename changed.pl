#!/usr/bin/perl
=pod

=head1 NAME

changed.pl - Print a list of the files that have changed.

=head1 SYNOPSIS

    changed <dir> [<dir> ...]

=head1 DESCRIPTION

The I<changed.pl> looks through the directories specified on the command line
and tells you which files have been created, deleted, or changed since the
last time it was run.

=head1 FILES

=item I<.changed.info>

The file containing the checksums of all the files contained in the 
last run.  This file will be compared against the current run 
in order to compute the change list.

=head1 BUGS

The name of the information file (I<.changed.info>) is hardcoded.
This means that you must run the program from the same directory each 
time and must specify the same directory list on the command
line each time.  (If you don't you get invalid results.)

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;
use File::Find;
use Digest::MD5;
use Storable qw(nstore retrieve);

# File in which to store the change information
my $info_file_name = ".change.info";

########################################################
# md5(file) -- Give a file, return the MD5 sum
########################################################
sub md5($)
{
    my $cur_file = shift;

    open(FILE, $cur_file) or return ("");
    binmode(FILE);
    my $result = Digest::MD5->new->addfile(*FILE)->hexdigest;
    close (FILE);
    return ($result);
}

# Hash reference containing the existing data
#	key -- file name
#	value -- MD5 sum
my $file_info;
# Hash of the "real" data
my %real_info;

# The list of directories to search
my @dir_list = @ARGV;

#
# Check for an existing information file and 
# read it if there is one.
if (-f $info_file_name) {
    $file_info = retrieve($info_file_name);
}

# If nothing there, return nothing
if ($#dir_list < 0) {
    print "Nothing to look at\n";
    exit (0);
}

# Go through the file tree and store the information on the 
# files.
find( sub {
	-f && ($real_info{$File::Find::name} = md5($_));
    }, @dir_list
);

#
# Check for changed, added files
# (clear any entries from the stored information for
# any files we found.)
foreach my $file (sort keys %real_info) {
    if (not defined($file_info->{$file}))  {
	print "New file: $file\n";
    } else {
	if ($real_info{$file} ne $file_info->{$file}) {
	    print "Changed: $file\n";
	}
	# else the same
	delete $file_info->{$file};
    }
}

#
# All file information for existing files has been
# removed from the information data.  So what's
# left is information on deleted files.
#
foreach my $file (sort keys %$file_info) {
    print "Deleted: $file\n";
}

nstore \%real_info, $info_file_name;
