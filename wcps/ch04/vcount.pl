#!/usr/bin/perl -T
=pod

=head1 NAME

vcount.pl - Visitor counter

=head1 SYNOPSIS

    <IMG SRC="http://www.server.com/cgi-bin/vcount.pl">

=head1 DESCRIPTION

The I<vcount.pl> creates an image which can be used as a visitor counter.
This script is not called directory but used to create an counter image
to be embedded in a web page.

The file I</var/visit/vcount.num> contains the visitor counter.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;
use GD;

# The file containing the visitor number
my $num_file = "/var/visit/vcount.num";

# Number to use for counter
my $num = 0;
if (-f $num_file) {
    if (open IN_FILE, "<$num_file") {
	$num = <IN_FILE>;
	chomp($num);
	close(IN_FILE);
    }
}

print "Content-type: image/png\n\n";

my $font = gdGiantFont;
my $char_x = $font->width;
my $char_y = $font->height;

my $picture_x = (1 + $char_x) * length($num) + 1;
my $picture_y = (1 + $char_y);

my $image = new GD::Image($picture_x, $picture_y);
my $background = $image->colorAllocate(0,0,0);
$image->transparent($background);
my $red = $image->colorAllocate(255,0,0);

$image->string($font, 0, 0, $num ,$red);

print $image->png;
++$num;
if (open OUT_FILE, ">$num_file") {
    print OUT_FILE $num;
}
close OUT_FILE;
