#!/usr/bin/perl
=pod

=head1 NAME

money.pl - Convert currency from one format to another

=head1 SYNOPSIS

    money.pl I<amount>I<from-code> I<to-code>

    money.pl -l

=head1 DESCRIPTION

Converts currency (i.e. United States Dollars -- USD) to another
currency such as currency such as Canadian dollars -- CAD

If the B<-l> option is used, all the currency codes are listed.

=back

=head1 EXAMPLES

List the codes.

        money.pl -l

Convert 100 dollars from US Dollars to Canadian dollars.

 	money.pl 100USD CAD
	100 USD => 121.84 Canadian Dollars

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
#
# Convert Curran's from one type to another
#
# Usage: money.pl <amount><from-code> <to-code>
#
# Where:
#	<from-code>, <to-code> -- ISO Currency codes
#

# Note: There are other currency modules out there,
# but this one looks like it does the most
#
# The drawback is that you must be connected to the
# Internet to use it.
use Finance::Currency::Convert::XE;

# The object for the converter
my $converter = new Finance::Currency::Convert::XE();

sub usage() {
    print "Usage is $0 <amount><code> <to-code>\n";
    exit (8);
}
if (($#ARGV == 0) && ($ARGV[0] eq "-l")) {
    # Warning: This depends on the internals of the converter
    my $info = $converter->{Currency};
    foreach my $symbol (sort keys %$info) {
	print "$symbol	$info->{$symbol}->{name}\n";
    }
    exit (0);
}
if ($#ARGV != 1) {
    usage();
}

if ($ARGV[0] !~
#      +---------------------------- Begin string
#      | ++++----------------------- Optional sign
#      | ||||+++-------------------- 0 or more digits
#      | |||||||                    (decimal part)
#      | |||||||   ++--------------- Literal "."
#      | |||||||   ||++------------- Digits
#      | |||||||+++|||||+----------- Group but no $x
#      | ||||||||||||||||+---------- 0 or 1 times
#      |+|||||||||||||||||+--------- put in $1
#      |||||||||||||||||||| +++----- One/more non spaces
#      ||||||||||||||||||||+|||+---- Put in $2
#      |||||||||||||||||||||||||+--- End of line
      /^([-+]?\d*(?:\.\d*)?)(\S+)$/) {
    usage();
}
my $amount = $1;	# Amount to convert
my $from_code = $2;	# Code of the original currency
my $to_code = $ARGV[1];	# Code we converting to

# Amount must have at least one digit in it
if ($amount !~ /\d/) {
    usage();
}

my $new_amount = $converter->convert(
                  'source' => $from_code,
                  'target' => $to_code,
                  'value' => $amount,
                  'format' => 'text'
           );

if (not defined($new_amount)) {
    print "Could not convert: " . $converter->error . "\n";
    exit (8);
}

my @currencies = $converter->currencies;

print "$amount $from_code => $new_amount\n";
