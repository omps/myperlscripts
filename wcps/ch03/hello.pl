#!/usr/bin/perl -T
=pod

=head1 NAME

hello.pl - CGI Hello World

=head1 SYNOPSIS

    http://www.server.com/cgi-bin/hello.pl

=head1 DESCRIPTION

The I<hello.pl> program prints "Hello World" in a CGI manner.

Although this script is not that useful itself, if you can this script
to run you can be sure your web server is setup to run CGI scripts.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Actually, I'm not sure that something so trivial can be copyrighted.
But if it is the copyright is:

    Copyright 2005 Steve Oualline.
    This program is distributed under the GPL.  

=cut

use strict;
use warnings;

print <<EOF
Content-type: text/html

<HEAD><TITLE>Hello</TITLE></HEAD>
<BODY>
<P>
Hello World!
</BODY>

EOF
