#!/usr/bin/perl
=pod

=head1 NAME

disk.pl - Write out a warning to all users when the disk space drops too low

=head1 SYNOPSIS

    disk.pl <fs> [<fs> ...]

=head1 DESCRIPTION

The I<disk.pl> examines the given disks and writes out a message
using I<wall> if the space falls below the minimum (5%).

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

use Filesys::DiskSpace;

my $space_limit = 5;	# Less than 5%, scream

if ($#ARGV == -1) {
    print "Usage is $0 <fs> [<fs>....]\n";
    exit (8);
}

# Loop through each directory in the 
# list.
foreach my $dir (@ARGV) {
    # Get the file system information
    my ($fs_type, $fs_desc, $used, 
        $avail, $fused, $favail) = df $dir;
    
    # The amount of free space
    my $per_free = (($avail) / ($avail+$used)) * 100.0;
    if ($per_free < $space_limit) {
	# Taylor this command to meet your needs 
	my $msg = sprintf(
	  "WARNING: Free space on $dir ".
	      "has dropped to %0.2f%%", 
	  $per_free);
	system("wall '$msg'");
    }
}

