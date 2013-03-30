#!/usr/bin/perl
=pod

=head1 NAME

remind.pl - Remind you about important dates

=head1 SYNOPSIS

    remind.pl [<calendar file>]

=head1 DESCRIPTION

The I<remind.pl> program reads the I<calender-file> (default=C<$HOME/.calendar>)
and tells you about any important dates which are coming up.

=head1 FILE FORMAT

The format of each entry in the file is:

	date	delta	event

Where

=over 4

=item I<date>

Is a date such as "Jan 1, 2005".  It can be in any format that the Time::ParseDate
can understand.

=item I<delta>

This tells remind when to inform you about an event.  A positive number (+I<nnn>) tells
remind to remind you before the event occurs.   If the event is less that I<nnn> days
you will be reminded.  This is for things like birthdays and appointments which are
coming up.

A negative number (-I<nnn>) tells the program to remind you for I<nnn> days after an
event occurs.  This is for things like rebates so you can tell how long a rebate has
been outstanding.

=head1 EXAMPLES

Today is July 26, 2005.  Our calendar file contains:

    #
    # Sample Calendar Files
    #
    July 14	-100	Rebate Seagate $10
    July 14	-100	Rebate Seagate $40
    July 12 	-100	Rebate Costco $50
    Aug 1	+30	Wife's birthday

If we run remind.pl on this file we get:

    -12 Rebate Seagate $10
    -12 Rebate Seagate $40
    -14 Rebate Costco $50
    6 Wife's birthday

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
#
# Usage: remind.pl [<calendar-file>]
#
# File format:
#	date<tab>delta<tab>Event
#
# 	Date -- a date
#	delta -- 
#		-xxx -- Remind after the event for xxx days
#		+xxx -- Remind before the event for xxx days
use strict;
use warnings;
use Time::ParseDate;
use Date::Calc(qw(Delta_Days));

#############################################################
# time_toYMD($time) -- Convert unit time into a Year, month
#	and day.  Returns an array containing these three 
#	values
#############################################################
sub time_to_YMD($)
{
    my $time = shift;	# Time to convert

    my @local = localtime($time);
    return ($local[5]+1900, $local[4]+1, $local[3]);
}
#------------------------------------------------------------
#
my $in_file = $ENV{'HOME'}."/calendar";

if ($#ARGV == 0) {
    $in_file = $ARGV[0];
}
if ($#ARGV > 0) {
    print STDERR "Usage: $0 [calendar-file]\n";
}

open IN_FILE, "<$in_file" or
   die("Unable to open $in_file for reading");

# Today's date as days since 1970
my @today_YMD = time_to_YMD(time());

while (<IN_FILE>) {
    # Lines that begin with "#" are comments
    if ($_ =~ /^\s+#/) {
	next;
    }
    # Blank lines don't count
    if ($_ =~ /^\s*$/) {
	next;
    }
    # The data on the line
    my @data = split /\t+/, $_, 3;
    if ($#data != 2) {
	next;	# Silently ignore bad lines
    }
    my $date = parsedate($data[0]);
    if (not defined($date)) {
	print STDERR "Can't understand date $data[0]\n";
	next;
    }
    my @file_YMD= time_to_YMD($date);
    # Difference between now and the date specified
    my $diff = Delta_Days(@today_YMD, @file_YMD);
    if ($data[1] > 0) {
	if (($diff >= 0) && ($diff < $data[1])) {
	    print "$diff $data[2]";
	}
    } else {
	if (($diff < 0) && ($diff < -($data[1]))) {
	    print "$diff $data[2]";
	}
    }
}
