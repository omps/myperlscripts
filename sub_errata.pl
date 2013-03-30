#!/usr/bin/perl -T
=pod

=head1 NAME

sub_errata.pl - Submit an errata for a book

=head1 SYNOPSIS

    http://www.server.com/sub_eratta.pl

=head1 DESCRIPTION

The I<sub_errata.pl> displays a form in which the user can submit an errata
for a book.  When the SUBMIT button is pressed an E-Mail is sent to the 
errata collector (hard-coded to B<oualline@www.oualline.com>) and a 
thank you displayed.

=head1 CGI PARAMETERS

The I<sub_errata.pl> takes the following CGI parameters:

=over 4

=item B<user>

The name of the person submitting the errata.

=item B<book>

The name book which has the problem.

=item B<where>

The location of the problem.

=item B<what>

What's wrong.

=back

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use HTML::Entities;

my $collector = "oualline\@www.oualline.com";

# Message to the user (will get overridden)
my $msg = "Internal error";

my $query = new CGI;	# The cgi query

# The name of the user
my $user = $query->param("user");

# The book information from the form
my $book = $query->param("book");

my $where = $query->param("where");
my $what = $query->param("what");
if (defined($query->param("SUBMIT"))) {
    if (not defined($user)) {
	die("Required parameter \$user missing");
    }
    if (not defined($book)) {
	die("Required parameter \$book missing");
    }
    if (not defined($where)) {
	die("Required parameter \$where missing");
    }
    if (not defined($what)) {
	die("Required parameter \$what missing");
    }
}
if (not defined($user)) {
    $user = "";
}
if (not defined($book)) {
    $book = "";
}
if (not defined($where)) {
    $where = "";
}
if (not defined($what)) {
    $what = "";
}

$ENV{PATH} = "/bin:/usr/bin";
delete ($ENV{qw(IFS CDPATH BASH_ENV ENV)});

if (($where ne "") or ($what ne ""))
{
    $book =~ /([a-z]*)/;
    $book = $1;
    if (not $book) {
	$book = "Strange";
    }

    open OUT_FILE, 
      "|mail -s 'Errata for $book' $collector" or
    	die("Could not start the mail program");

    print OUT_FILE "Book: $book\n";
    print OUT_FILE "User: $user\n";
    print OUT_FILE "Location: $where\n";
    print OUT_FILE "Problem:\n";
    print OUT_FILE "$what\n";
    close OUT_FILE;

    $msg = <<EOF;
<P>
Thank you for your submission.   If you have another
errata, fill in the form below.
EOF
}


# Encode the values we are going to print
$user = HTML::Entities::encode($user);
$book = HTML::Entities::encode($book);

print <<EOF;
Content-type: text/html

<HTML>
<HEAD>
    <TITLE>Submit an Errata</title>
</HEAD>

<BODY BGCOLOR="#FFFFFF">
    $msg
    <FORM METHOD="post" ACTION="sub_errata.pl" NAME="errata">
	Book:
	<SELECT NAME="book">
	    <OPTION VALUE="vim">
	        Vim (Vi Improved)
	    </OPTION>
	    <OPTION VALUE="not">
	        How not to Program in C++
	    </OPTION>
	    <OPTION VALUE="perlc">
	        Perl for C Programmer
	    </OPTION>
	    <OPTION VALUE="wcp" SELECTED>
	        Wicked Cool Perl Scripts
	    </OPTION>
	</SELECT>

	<P>Your E-Mail address: 
	    <INPUT TYPE="text" NAME="user" VALUE=$user>
	(optional).</P>

	<P>Location of the error: 
	    <INPUT TYPE="text" NAME="where">
	</P>
	
	<P>Description of the problem:<BR>
	    <TEXTAREA NAME="what" COLS="75" ROWS="10">
	    </TEXTAREA>
	</P>
	<P>
	    <INPUT TYPE="submit" 
	     NAME="Submit" VALUE="Submit">
	</P>
    </FORM>
</BODY>
</HTML>
EOF
