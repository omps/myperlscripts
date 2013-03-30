#!/usr/bin/perl
=pod

=head1 NAME

thumb.pl - Generate thumbnails of pictures

=head1 SYNOPSIS

    thumb.pl <file> [<file> ...]

=head1 DESCRIPTION

The I<thumb.pl> generates a set of thumbnails for the 
given pictures.  The results are stored in the I<_thumb>
directory.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

use Image::Magick;
use constant X_SIZE => 100;
use constant Y_SIZE => 150;

sub do_file($)
{
    my $file = shift;	# The file to create 
    			# thumbnail of

    my $image = Image::Magick->new();
    my $status = $image->Read($file);
    if ($status) {
	print "Error $status\n";
	return;
    }
    print "Size ", $image->Get('width'), " x ", 
    	$image->Get('height'), "\n";

    my $x_scale = X_SIZE / $image->Get('width');
    my $y_scale = Y_SIZE / $image->Get('height');
    my $scale = $x_scale;
    if ($y_scale < $scale) {
	$scale = $y_scale;
    }
    print "Scale $scale (x=$x_scale, y=$y_scale)\n";
    my $new_x = int($image->Get('width') * $scale + 0.5);
    my $new_y = int($image->Get('height') * $scale + 0.5);
    print "New $new_x, $new_y\n";

    $status = $image->Scale(
	width => $new_x, height => $new_y);

    if ($status) {
	print "$status\n";
    }
    $status = $image->Write("_thumb/$file");
    if ($status) {
	print "Error $status\n";
    }
}

if (! -d "_thumb") {
    mkdir("_thumb");
}
foreach my $cur_file (@ARGV) {
    do_file($cur_file);
}
