#!/usr/bin/perl
=pod

=head1 NAME

lang.pl - Language drill

=head1 SYNOPSIS

    lang.pl <word file>

=head1 DESCRIPTION

The I<lang.pl> gives the user a language drill.  The input file 
contains two words, one in English and one in a foreign language.
The first word is printed and the user is asked for the second.

If he gets the word right, it is removed from the list.  If not,
it is moved to the back of the list and he will be asked the word
again later.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

#
# perl lang.pl <flash file>
#
# File format:
#	question<tab>answer
#
if ($#ARGV != 0) {
    print "Usage: is $0 <flash-file>\n";
    exit (8);
}
open IN_FILE, "<$ARGV[0]" or
   die("Could not open $ARGV[0] for reading");

my @list;	# List of questions and answers

#
# Read the stuff in
#
while (<IN_FILE>) {
    chomp;
    my @words = split /\t/;
    if ($#words != 1) {
	die("Malformed input $_");
    }
    push(@list, 
    	{
	    question => $words[0],
	    answer => $words[1]
	});
}

#
# Ask the questions until there are no more
#
while ($#list > -1) {
    print "Question: $list[0]->{question}: ";
    my $answer = <STDIN>;
    chomp($answer);
    if ($answer eq $list[0]->{answer}) {
	print "Right: ",
	    "The answer is $list[0]->{answer}\n";
	shift(@list);
	next;
    }
    print "Wrong: ",
       "The correct answer is $list[0]->{answer}\n";
    # Push the question to the end of the list
    push(@list, shift(@list));
}
print "All done\n";
