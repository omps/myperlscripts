#!/usr/bin/perl -T
=pod

=head1 NAME

start-debug.pl - Start the PerlTk debugger and debug hello.pl

=head1 SYNOPSIS

    http://www.server.com/cgi-bin/start-debug.pl

=head1 DESCRIPTION

The I<start-debug> starts the debugger on the perl program I<hello.pl>.
You must be on the server on which the web server is running and you must
be running the X Windows system.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
#
# Allows you to debug a script by starting the 
# interactive GUI debugger on your X screen.
#
use strict;
use warnings;

$ENV{DISPLAY} = ":0.0";	# Set the name of the display
$ENV{PATH}="/bin:/usr/bin:/usr/X11R6/bin:";

system("/usr/bin/perl -T -d:ptkdb hello.pl");
