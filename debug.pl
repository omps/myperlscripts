#!/usr/bin/perl -T
=pod

=head1 NAME

debug.pl - Print debug information for a CGI script.

=head1 SYNOPSIS

    http://www.server.com/cgi-bin/debug.pl

=head1 DESCRIPTION

The I<debug.pl> program prints out debugging information 
containing all the CGI parameters and the environment.

Alone it is not all that useful, but the debug subroutine
can be embedded in other scripts and thus provide lots of useful
information for CGI debugging.

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

#
# debug -- print debugging information to the screen
#
sub debug()
{
    print "<H1>DEBUG INFORMATION</H1>\n";
    print "<H2>Form Information</H2>\n";
    my %form_info = Parse_CGI();
    foreach my $cur_key (sort keys %form_info) {
	print "<BR>";
	if (ref $form_info{$cur_key}) {
	    foreach my $value (@{$form_info{$cur_key}}) {
		print encode_entities($cur_key), " = ", 
		      encode_entities($value), "\n";
	    }
	} else {  
	    print encode_entities($cur_key), " = ", 
		  encode_entities(
		      $form_info{$cur_key}), "\n";
	}
    }
    print "<H2>Environment</H2>\n";
    foreach my $cur_key (sort keys %ENV) {
	print "<BR>";
	print encode_entities($cur_key), " = ", 
	encode_entities($ENV{$cur_key}), "\n";
    }
}

# Call the program to print out the stuff
print "Content-type: text/html\n";
print "\n";
debug();
