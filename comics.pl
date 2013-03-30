#!/usr/bin/perl 
=pod

=head1 NAME

comics.pl - Download comics from the Internet

=head1 SYNOPSIS

    comics.pl

=head1 DESCRIPTION

The I<comics.pl> reads the file I<comics.txt> for information on the location
of comic strips on the Internet.  Any new ones are downloaded and stored
in the directory I<comics>.

The format of the I<comics.txt> file is:

	<name>	<top-url>	<pattern>

(Each field is separated from the next by a tab.)

Where:

=over 4

=item I<name>

Is the name of the comic. This will be used as the root of the file name when the comic is written.

=item I<top-url>

The url of the web page containing the comic.  (Not the image, the text page which contains the image.)

=item I<pattern>

A regular expression to use when searching the web page for images.

=back

The program writes out the comics to the directory I<comics>.  It writes out information
as to which comics have been seen into the file I<comics.info>

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

use LWP::Simple;
use HTML::SimpleLinkExtor;
use URI;
use POSIX;

# Information on the comics
my $in_file = "comics.txt";	

# File with last download info
my $info_file = "comics.info";	

my %file_info;	# Information on the last download

#############################################################
# do_file($name, $page, $link, $index)
#
# Download the given link and store it in a file.
#	If multiple file are present, 
#		$index should be different
#	for each file.
#############################################################
sub do_file($$$$)
{
    my $name = shift;	# Name of the file
    my $page = shift;	# The base page
    my $link = shift;	# Link to grab
    my $index = shift;	# Index (if multiple files)

    # Try and get the extension of the file from the link
    $link =~ /(\.[^\$\.]*)$/;

    # Define the extension of the file
    my $ext;
    if (defined($1)) {
	$ext = $1;
    } else {
	$ext = ".jpg";
    }
  
    my $uri = URI->new($link);
    my $abs_link = $uri->abs($page);

    # Get the heading information of the link
    # (and the modification time goes into $2);
    my @head = head($abs_link->as_string());
    if ($#head == -1) {
	print "$name Broken link: ", 
	    $abs_link->as_string(), "\n";
	return;
    }
    if (defined($file_info{$name})) {
    	# If we've downloaded this one before
	if ($head[2] == $file_info{$name}) {
	    print "Skipping $name\n";
	    return;
	}
    }
    # Set the file information
    $file_info{$name} = $head[2];

    # Time of the last modification
    my $time = asctime(localtime($head[2]));
    chomp($time);	# Stupid POSIX hack

    print "Downloading $name (Last modified $time)\n";
    # The raw data from the page
    my $raw_data = get($abs_link->as_string());
    if (not defined($raw_data)) {
	print "Unable to download link $link\n";
	return;
    }
    my $out_name;	 # Name of the output file

    if (defined($index)) {
	$out_name = "comics/$name.$index$ext";
    } else {
	$out_name = "comics/$name$ext";
    }
    if (not open(OUT_FILE, ">$out_name")) {
	print "Unable to create $out_name\n";
	return;
    }
    binmode OUT_FILE;
    print OUT_FILE $raw_data;
    close OUT_FILE;
}

#------------------------------------------------------------
open INFO_FILE, "<$info_file";
while (1) {
    my $line = <INFO_FILE>;	# Get line from info file

    if (not defined($line)) {
	last;
    }
    chomp($line);
    # Get the name of the the and the last download
    my ($name, $time) = split /\t/, $line;
    $file_info{$name} = $time;
}
close INFO_FILE;
     
open IN_FILE, "<$in_file" 
    or die("Could not open $in_file");


while (1) {
    my $line = <IN_FILE>;	# Get line from the input
    if (not defined($line)) {
	last;
    }
    chomp($line);

    # Parse the information from the config file
    my ($name, $page, $pattern) = split /\t/, $line;

    # If the input is bad, fuss and skip
    if (not defined($pattern)) {
	print "Illegal input $line\n";
	next;
    }

    # Get the text page which points to the image page
    my $text_page = get($page);

    if (not defined($text_page)) {
	print "Could not download $page\n";
	next;
    }

    # Create a decoder for this page
    my $decoder = HTML::SimpleLinkExtor->new();
    $decoder->parse($text_page);

    # Get the image links
    my @links = $decoder->img();
    my @matches = grep /$pattern/, @links;

    if ($#matches == -1) {
	print "Nothing matched pattern for $name\n";
	print "	Pattern: $pattern\n";
	foreach my $cur_link (@links) {
	    print "	$cur_link\n";
	}
	next;
    }
    if ($#matches != 0) {
	print "Multiple matches\n";
	my $index = 1;
	foreach my $cur_link (@matches) {
	    print "	$cur_link\n";
	    do_file($name, $page, $cur_link, $index);
	    ++$index;
	}
	next;
    }
    # One match
    do_file($name, $page, $matches[0], undef);
}

open INFO_FILE, ">$info_file" or
   die("Could not create $info_file");

foreach my $cur_name (sort keys %file_info) {
    print INFO_FILE "$cur_name	$file_info{$cur_name}\n";
}
close (INFO_FILE);
