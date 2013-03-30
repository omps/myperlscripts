#!/usr/bin/perl 
=pod

=head1 NAME

sym_check.pl - Find bad symbolic links

=head1 SYNOPSIS

    sym_link.pl <dir> [<dir> ...]

=head1 DESCRIPTION

The I<sym_link.pl> program scans the given directories for broken
symbolic links.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

use File::Find ();

use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, @ARGV);
exit;


sub wanted {
    if (-l $_) {
	my @stat = stat($_);
	if ($#stat == -1) {
	    print "Bad link: $name\n";
	}
    }
}

