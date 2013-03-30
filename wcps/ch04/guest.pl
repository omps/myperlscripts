#!/usr/bin/perl -T
=pod

=head1 NAME

guest.pl - CGI Guest book

=head1 SYNOPSIS

    http://www.server.com/cgi-bin/server.pl

=head1 DESCRIPTION

The I<guest.pl> script displays a form in which the user can input
his name and E-Mail address.  

When the SUBMIT button is pressed, the script 
records the information in the
file I</tmp/visitor.txt> and displays a message telling the
user how many people have registered.

=head1 CGI PARAMETERS

The I<guest.pl> takes the following CGI parameters:

=over 4

=item B<user>

The user name.

=item B<email>

The E-Mail address.

=back

=head1 BUGS

The parameters are not validated.

The file I</tmp/visitor.txt> is not very well protected against tampering.

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

#
# Configure this for your system
#
# Where the information is collected
my $visit_file = "/tmp/visit.list";

my $query = new CGI;	# The cgi query

# The name of the user
my $user = $query->param("user");

# The email of the user
my $email = $query->param("email");

if (not defined($user)) {
    $user = "";
}
if (not defined($email)) {
    $email = "";
}

# Untaint the environment
$ENV{PATH} = "/bin:/usr/bin";
delete ($ENV{qw(IFS CDPATH BASH_ENV ENV)});

# If there is a user defined, record it
if ($user ne "")
{
    open OUT_FILE, ">>$visit_file" or
    	die("Could write the visitor file");

    print OUT_FILE "$user\t$email\n";

    close OUT_FILE;

    # Turn the user into HTML
    $user = HTML::Entities::encode($user);

    # Get the visitor number from the file
    my $visitor = `wc -l $visit_file`;

    # Remove leading spaces
    $visitor =~ s/^\s+//;

    # Get the number of lines in the file
    my @number = split /\s+/, $visitor;

    print <<EOF ;
Content-type: text/html

<HTML>
<HEAD>
    <TITLE>Guest Book</title>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<P>
Thank you $user.  Your name has been recorded.
<P>
You are visitor number $number[0]
EOF
    exit (0);
}


print <<EOF;
Content-type: text/html

<HTML>
<HEAD>
    <TITLE>Guest Book</title>
</HEAD>

<BODY BGCOLOR="#FFFFFF">
    <P>
    Please sign my guest book:
    <FORM METHOD="post" ACTION="guest.pl" NAME="guest">
	<P>Your name: 
	    <INPUT TYPE="text" NAME="user">
	.</P>

	<P>Your E-Mail address: 
	    <INPUT TYPE="text" NAME="email">
	(optional).</P>

	<P>
	    <INPUT TYPE="submit" 
	     NAME="Submit" VALUE="Submit">
	</P>
    </FORM>
</BODY>
</HTML>
EOF
