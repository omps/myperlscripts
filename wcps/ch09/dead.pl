#!/usr/bin/perl
=pod

=head1 NAME

dead.pl - Identify dead code and variables

=head1 SYNOPSIS

    dead.pl

=head1 DESCRIPTION

The I<deal.pl> reads the I<object_xref.dat> file produced
by I<ox-gen.pl> and prints out all symbols that are not
used.  These symbols indicate code that is not used or should
be made B<static>.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;
use Storable;

# The cross reference data
my $object_xref = retrieve("object_xref.dat");

if (not defined($object_xref)) {
    print "Could not find data file\n";
    exit (8);
}

# Look through each symbol on the command line
foreach my $sym (sort keys %$object_xref) {
    # Get the information about this symbol
    my $info = $object_xref->{$sym};
    my $used = $info->{used};

    if ($#$used == -1) {
	print "$sym\n";
    }
}
