#!/usr/bin/perl
=pod

=head1 NAME

mass-rename.pl - Perform a mass rename

=head1 SYNOPSIS

    mass-rename.pl [-n] [-v] [-e'/<old>/<new>/'] <file> [<file> ...]

=head1 DESCRIPTION

The I<mass-rename.pl> program renames all the files listed on 
the command using the substitute command specified by the 
B<-e> option.

=head1 OPTIONS

=over 4

=item B<-n>

Don't really do the rename.  (Suggest adding B<-v> when using this
option.)

=item B<-v>

Print what's going on.

=item B<-e/>I<old>B</>I<new>B</>

The Perl substitution used to perform the mass rename.

=back

=head1 EXAMPLES

An example of how to use the program to do something is:

        mass-rename.pl -v -e'/jpeg$/jpg/' *.jpeg
	foo.jpeg -> foo.jpg

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

use Getopt::Std;
use vars qw/$opt_n $opt_v $opt_e/;

if (not getopts("nve:")) {
    die("Bad options");
}
if (not defined($opt_e)) {
    die("Required option -e missing");
}

foreach my $file_name (@ARGV)
{
    # Compute the new name
    my $new_name = $file_name;

    # Perform the substitution
    eval "\$new_name =~ s$opt_e";

    # Make sure the names are different
    if ($file_name ne $new_name)
    {
	# If a file already exists by that name
	# compute a new name.
	if (-f $new_name) 
	{
	    my $ext = 0;

	    while (-f $new_name.".".$ext)
	    {
	        $ext++;
	    }
	    $new_name = $new_name.".".$ext;
	}
	if ($opt_v) {
	    print "$file_name -> $new_name\n";
	}
	if (not defined($opt_n)) {
	    rename($file_name, $new_name);
	}
    }
}

