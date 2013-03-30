#!/usr/bin/perl
=pod

=head1 NAME

dup_files.pl - Print a list of duplicate files

=head1 SYNOPSIS

    program <dir> [<dir> ...]

=head1 DESCRIPTION

The I<dup_files.pl> scans the files in the specified directories
and prints out the duplicates.

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

###########################################################
# find_dups(@dir_list) -- Return an array containing a list
#	of duplicate files.
###########################################################
sub find_dups(@)
{
    # The list of directories to search
    my @dir_list = @_;

    # If nothing there, return nothing
    if ($#dir_list < 0) {
	return (undef);
    }

    my %files;	# Files indexed by size 

    # Go through the file tree and find all 
    # files with a similar size
    find( sub {
	    -f && 
	    push @{$files{(stat(_))[7]}}, $File::Find::name
	}, @dir_list
    );

    my @result = ();	# The resulting list

    # Now loop through list of files by size and see
    # if the md5 is the same for any of them
    foreach my $size (keys %files) {
	if ($#{$files{$size}} < 1) {
	    next;
	}
	my %md5;	# MD5 -> file name array hash

	# Loop through each file of this size and 
	# compute the MD5 sum
	foreach my $cur_file (@{$files{$size}}) {
	    # Open the file.  Skip the files we can't open
	    open(FILE, $cur_file) or next;
	    binmode(FILE);
	    push @{$md5{
		Digest::MD5->new->addfile(*FILE)->hexdigest}
	    }, $cur_file;
	    close (FILE);
	}
	# Now check for any duplicates in the MD5 hash
	foreach my $hash (keys %md5) {
	    if ($#{$md5{$hash}} >= 1) {
		push(@result, [@{$md5{$hash}}]); 
	    }
	}
    }
    return @result
}

my @dups = find_dups(@ARGV);

foreach my $cur_dup (@dups) {
    print "Duplicates\n";
    foreach my $cur_file (@$cur_dup) {
	print "\t$cur_file\n";
    }
}
