#!/usr/bin/perl
=pod

=head1 NAME

temp.pl - Temperature conversion program

=head1 SYNOPSIS

    temp.pl  I<temp>(C|F)

=head1 DESCRIPTION

The I<temp.pl> converts Fahrenheit to Centigrade and vice versa.
For example 32 degrees Fahrenheit (32F) is 0 Centigrade (0C).

=head1 EXAMPLES

    temp.pl 72F
    72 F => 22.2222222222222 C

=head1 BUGS

The formatting of the output could be better.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
# convert Centigrade to Fahrenheit
# or vice versa.
use strict;
use warnings;

if (($#ARGV != 0) || ($ARGV[0] !~ /^([\-+]?\d+)([CcFf])$/)) {
    print STDERR "Usage: $0 <deg>[C|F]\n";
    exit (8);
}

my $temp = $1;
my $type = $2;

my $result;
my $result_type;

if (($type eq "C") || ($type eq "c")) {
    $result = (9.0/5.0) * $temp + 32.0;
    $result_type = "F";
} else {
    $result = (5.0/9.0) * ($temp - 32.0);
    $result_type = "C";
}
print "$temp $type => $result $result_type\n";


    
