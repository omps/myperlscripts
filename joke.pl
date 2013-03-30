#!/usr/bin/perl -T
=pod

=head1 NAME

joke.pl - Display a random joke

=head1 SYNOPSIS

    http://www.server.com/cgi-bin/joke.pl

=head1 DESCRIPTION

The I<joke.pl> uses the I<fortune> program to generate a joke and
then displays the result to the user.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
# Random joke generator
use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use HTML::Entities;

# Untaint the environment
$ENV{PATH} = "/bin:/usr/bin";
delete ($ENV{qw(IFS CDPATH BASH_ENV ENV)});

    print <<EOF ;
Content-type: text/html

<HTML>
<HEAD>
    <TITLE>Random Joke</title>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<P>
EOF

my @joke = `/usr/games/fortune`;
foreach (@joke) {
    print HTML::Entities::encode($_), "<BR>\n";
}
