#!/usr/bin/perl -T
=pod

=head1 NAME

error_log.pl - Print the last few lines of the Apache error log

=head1 SYNOPSIS

    http://www.server.com/cgi-bin/error-log.pl

=head1 DESCRIPTION

This script is useful in the cases where you have people developing
CGI scripts who are not webmasters and do not have enough privileges
to inspect the Apache error logs directly.

It displays the last few lines of the Apache error log.  This allows the
developer to see the error messages a broken CGI script generates.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;

use CGI::Thin;
use CGI::Carp  qw(fatalsToBrowser);
use HTML::Entities;

use constant DISPLAY_SIZE => 50;


# Call the program to print out the stuff
print <<EOF ;
Content-type: text/html
\n
<HEAD><TITLE>Error Log</TITLE></HEAD>
<BODY BGCOLOR="#FF8080">
<H1>Error Log</H1>
EOF

if (not open IN_FILE, "</var/log/httpd/error_log") {
    print "<P>Could not open error_log\n";
    exit (0);
}
    
     
# Lines from the file
my @lines = <IN_FILE>;

my $start = $#lines - DISPLAY_SIZE + 1;
if ($start < 0) {
    $start = 0;
}
for (my $i = $start; $i <= $#lines; ++$i) {
    print encode_entities($lines[$i]), "<BR>\n";
}
