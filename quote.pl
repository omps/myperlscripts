#!/usr/bin/perl
=pod

=head1 NAME

quote.pl - Get a stock quote from the Internet

=head1 SYNOPSIS

    quote.pl  <symbol> [<symbol> ...]

=head1 DESCRIPTION

The I<quote.pl> gets stock information from the Yahoo finance site.

=head1 EXAMPLES


    quote.pl GOOG
    GOOG Last: 293.50 Day range: 293.28 - 297.41
    Year range: 95.96 - 317.80

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

use Finance::Quote;

if ($#ARGV == -1) {
    print STDERR "Usage is $0 <stock> [<stock> ...]\n";
    exit (8);
}

# Get the quote engine
my $quote = Finance::Quote->new;

# Get the data
my %data = $quote->fetch('usa', @ARGV);

# Print the data
foreach my $stock (@ARGV) {
    my $price = $data{$stock, "price"};
    if (not defined($price)) {
	print "No information on $stock\n";
	next;
    }
    my $day   = $data{$stock, "day_range"};
    my $year  = $data{$stock, "year_range"};
    if (not defined($day)) { 
	$day = "????";
    }
    if (not defined($year)) { 
	$year = "????";
    }

    print "$stock Last: $price Day range: $day\n";
    print "Year range: $year\n";
}
