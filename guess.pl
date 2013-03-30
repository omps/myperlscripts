#!/usr/bin/perl
=pod

=head1 NAME

guess.pl - Simple guessing game

=head1 SYNOPSIS

    guess.pl

=head1 DESCRIPTION

The I<guess.pl> generates a random number from 1 to 1000 and asks 
the user to guess it.  If the user guesses right the user wins.
If not the interval is revised based on the user's input and
the user can try again.

=head1 EXAMPLES

    guess.pl
    Enter a number between 1 and 1000: 500
    Enter a number between 500 and 1000: 750
    Enter a number between 500 and 750: 575
    Enter a number between 575 and 750: 600
    Enter a number between 600 and 750: 700
    Enter a number between 600 and 700: 650
    Enter a number between 600 and 650: 625
    Enter a number between 600 and 625: 610
    Enter a number between 610 and 625: 620
    Enter a number between 610 and 620: 615
    Enter a number between 615 and 620: 617
    Enter a number between 615 and 617: 616
    You guessed it.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

my $low = 1;		# Current low limit
my $high = 1000;	# Current high limit

# The number the user need to guess
my $goal = int(rand($high))+1;

while (1) {
    print "Enter a number between $low and $high: ";

    # The answer from the user
    my $answer = <STDIN>;
    chomp($answer);

    if ($answer !~ /\d+/) {
	print "Please enter a number only\n";
	next;
    }
    if ($answer == $goal) {
	print "You guessed it.\n";
	exit;
    }
    if (($answer < $low) || ($answer > $high)) {
	print "Please stay between $low and $high.\n";
	next;
    }
    if ($answer < $goal) {
	$low = $answer;
    } else {
	$high = $answer;
    }
}
