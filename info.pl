#!/usr/bin/perl
=pod

=head1 NAME

info.pl - Print the hidden information contained in a JPEG picture

=head1 SYNOPSIS

    info.pl <file> [<file> ...]

=head1 DESCRIPTION

The I<info.pl> program print the hidden information in JPEG file.  This includes
things like the creation time, file source, camera model and so on.

=head1 EXAMPLES

    info.pl p1010017.jpg 
    p1010017.jpg ----------------------------------
	JPEG_Type -> Baseline
	SamplesPerPixel -> 3
	color_type -> YCbCr
	file_ext -> jpg
	file_media_type -> image/jpeg
	height -> 1020
	resolution -> 72 dpi
	width -> 642

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

my %good = (
    'ColorSpace' => 1,
    'ComponentsConfiguration' => 1,
    'DateTime' => 1,
    'DateTimeDigitized' => 1,
    'DateTimeOriginal' => 1,
    'ExifImageLength' => 1,
    'ExifImageWidth' => 1,
    'ExifVersion' => 1,
    'FileSource' => 1,
    'Flash' => 1,
    'FlashPixVersion' => 1,
    'ISOSpeedRatings' => 1,
    'ImageDescription' => 1,
    'InteroperabilityIndex' => 1,
    'InteroperabilityVersion' => 1,
    'JPEG_Type' => 1,
    'LightSource' => 1,
    'Make' => 1,
    'MeteringMode' => 1,
    'Model' => 1,
    'Orientation' => 1,
    'SamplesPerPixel' => 1,
    'Software' => 1,
    'YCbCrPositioning' => 1,
    'color_type' => 1,
    'file_ext' => 1,
    'file_media_type' => 1,
    'height' => 1,
    'resolution' => 1,
    'width' => 1
);

use Image::Info qw(image_info);


foreach my $cur_file (@ARGV) {
    my $info = image_info($cur_file);

    print "$cur_file ----------------------------------\n";
    foreach my $key (sort keys %$info) {
	if ($good{$key}) {
	    print "    $key -> $info->{$key}\n";
	}
    }
}
