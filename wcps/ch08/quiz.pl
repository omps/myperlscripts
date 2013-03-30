#!/usr/bin/perl -T 
=pod

=head1 NAME

quiz.pl - A CGI quiz program.

=head1 SYNOPSIS

    http://www.server.com/cgi-bin/quiz.pl

=head1 DESCRIPTION

The I<quiz.pl> program is designed give the user a quiz.
The input this program is a series of question files in 
the following format:

    =question
    <question page>
    =answer value
    <answer page>
    =answer value
    <answer page>
    =right value
    <answer page for the right answer>

The sections in this file are:

=over 4

=item B<=question>

The text (html format) for the question.

=item B<=answer> I<value>

This entry specifies an incorrect value.  The text that follows
this entry is displayed when the user selects this (wrong) answer.

=item B<=right> I<right>

Same as B<=answer> except this answer is right

=back

=head1 SAMPLE INPUT FILE
 
    =question
    <HEAD><TITLE>Question 1</TITLE></HEAD>
    <H1>Question 1:</H1>
    <P>
    What does the following regular expression mean:
    <pre>
    /\S+/
    </pre>
    <P>
    &nbsp;
    <FORM ACTION="quiz.pl">
    <P>
    <INPUT TYPE="submit" NAME="answer" VALUE="1">
    One or more spaces.<BR>
    <INPUT TYPE="submit" NAME="answer" VALUE="2">
    Zero or more spaces.<BR>
    <INPUT TYPE="submit" NAME="answer" VALUE="3">
    One or more non-space characters.<BR>
    </FORM>

    =answer 1

    <HEAD><TITLE>Wrong</TITLE></HEAD>
    <H1>Wrong</H1>
    <P>
    Lower case 's' (<code>\s</code>) is used to specify 
    spaces.  The regular expression given uses an upper
    case 'S'.  (See <i>perldoc perlre</i> for a reference.)


    =answer 2

    <HEAD><TITLE>Wrong</TITLE></HEAD>
    <H1>Wrong</H1>
    <P>
    The star character (<code>*</code>) denotes zero
    or more characters.  This expression uses the 
    plus (<code>+</code>) character.
    (See <i>perldoc perlre</i> for a reference.)

    =right 3

    <HEAD><TITLE>Right</TITLE></HEAD>
    <H1>Right</H1>

    Go on to the next questions.


=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
#
# File format
#	=question
#	<question page>
#	=answer value
#	<answer page>
#	=answer value
#	<answer page>
#	=right value
#	<answer page for the right answer>
#
use strict;
use warnings;

use CGI::Thin;
use CGI::Thin::Cookies;
use CGI::Carp;
use POSIX;
use HTML::Entities;
use Scalar::Util qw(tainted);
use Storable qw(retrieve nstore);

# Place the questions and session files are
# stored in
my $quiz_dir = "/var/quiz";

# The data from the form
my %cgi_data = Parse_CGI();

# Cookie information
my %cookies = Parse_Cookies();

# The weight from the cookie
my $session_cookie = $cookies{QUIZ};

my $session = undef;	# The session name

# Taint checking and cleaning
if (defined($session_cookie) && 
    ($session_cookie =~ /^$quiz_dir\/session\/session.(\d+)$/)) {
    $session_cookie =~ /(\d+)$/;
    $session = "$quiz_dir/session/session.$1";
} else {
    $session = undef;
}

if (! -f $session) {
    $session = undef;
}
if (not defined ($session)) {
    for (my $i = 0; ; $i++) {
	# Generate a new session
	$session = "$quiz_dir/session/session.$i";
	if (! -f "$quiz_dir/session/session.$i") {
	    last;
	}
    }
}

# The cookie to send to the user
my $cookie;
$cookie = Set_Cookie(
    NAME => "QUIZ",       # Cookie's name
    VALUE => $session,    # Value for the cookie
    EXPIRE => "+3h",      # Keep cookie for 3 hours
);
print "$cookie";
print "Content-type: text/html\n";
print "\n";

my $session_info;
if (-f $session) {
    $session_info = retrieve($session);
} else {
    my @files = glob("$quiz_dir/questions/*");
    $session_info->{files} = [@files];
    $session_info->{mode} = 'question';
}

################################################################
# parse_file($file_name) -- Read and a parse a file
#
# Returns a hash containing the file information
################################################################
sub parse_file($)
{
    my $file_name = shift;

    open IN_FILE, "<$file_name" or
	die("Unable to open $file_name");
    
    my %file_info;	# Information about the file

    my $field;	# Field we are defining
    my $item = undef;# Item we are defining in the fields

    while (my $line = <IN_FILE>) {
	if ($line =~ /^=question/) {
	    $field = 'question';
	    $item = undef;
	} elsif ($line =~ /=answer\s+(\S+)/) {
	    $field = 'answer';
	    $item = $1;
	} elsif ($line =~ /=right\s+(\S+)/) {
	    $field = 'answer';
	    $item = $1;
	    $file_info{right} = $1;
	} else {
	    if (defined($item)) {
		$file_info{$field}->{$item} .= $line;
	    } else {
		$file_info{$field} .= $line;
	    }
	}
    }
    close (IN_FILE);
    return (%file_info);
}

################################################################
# display_done -- Tell the user he's done.
################################################################
sub display_done()
{
    $session_info->{mode} = 'done';
    print <<EOF

<H1>Test Complete</H1>
<P>
Congratulations, you have finished the quiz.

EOF
    #TODO: Need something here to go somewhere else
}
################################################################
# display_question -- Display the current question
################################################################
sub display_question()
{
    if ($#{$session_info->{files}} == -1) {
	display_done();
	return;
    }

    # Information about the file
    my %file_info = parse_file($session_info->{files}->[0]);

    print $file_info{question};
    $session_info->{mode} = 'answer';
}


################################################################
# display_answer -- Display the answer
################################################################
sub display_answer()
{
    # The information from the question file
    my %file_info = parse_file($session_info->{files}->[0]);

    # The answer the user submitted
    my $answer = $cgi_data{answer};

    # Display the answer
    if (defined($file_info{answer}->{$answer})) {
	print $file_info{answer}->{$answer};
    } else {
	print "<H1>Internal error: Undefined answer $answer</H1>\n";
	$answer = "";
    }
    if ($answer eq $file_info{right}) {
	shift @{$session_info->{files}};
    } else {
	my $last = @{$session_info->{files}};
	push(@{$session_info->{files}}, $last);
    }
    $session_info->{mode} = 'question';
    print <<EOF ;
    <FORM ACTION="quiz.pl">
    <INPUT TYPE="submit" NAME="next" VALUE="next">
    </FORM>
EOF
}


if ($session_info->{mode} eq 'answer') {
    display_answer();
} elsif ($session_info->{mode} eq 'question') {
    display_question();
} else {
    display_done();
}

# Store the data for laster use
nstore($session_info, $session);
