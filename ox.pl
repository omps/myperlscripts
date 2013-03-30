=pod

=head1 NAME

ox.pl - Print out object cross reference information

=head1 SYNOPSIS

    ox.pl <symbol> [<symbol> ...]

=head1 DESCRIPTION

The I<ox.pl> prints out where a symbol is defined and used.

=head1 FILES

=over 4

=item object_xref.dat

The database containing the symbol information.

=back

=head1 SEE ALSO

L<ox-gen.pl>, L<nm>

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
foreach my $sym (@ARGV) {
     # Get the information about this symbol
     my $info = $object_xref->{$sym};
     if (not defined($info)) {
         print "$sym:   UNDEFINED\n";
         next;
     }
     # Print the information
     print "$sym\n";
     print "    Defined: @{$info->{'defined'}}\n";
     print "    Used: @{$info->{'used'}}\n";
}
