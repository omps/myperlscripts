#!/usr/bin/perl


use strict;
use warnings;

use LWP::Simple;
use HTML::SimpleLinkExtor;
use URI;
use POSIX;

# Information on comics.

my $in_file = "comics.txt";

# File with last download info.
my $info_file = "comics.info";

my %file_info; # Information on the last download file.

######################
# do_file($name, $page, $link, $index)
#
# Download the given link and store it in a file
#
#    if multiple file are present,
#            $index should be different.
# for each file.

sub do_file($$$$)
  {
    my $name = shift; # Name of file
    my $page = shift; # The base page
    my $link = shift; # Link to grab
    my $index = shift; #Index (if multiple files)

# Try and get the extension of the file from the link.
    $link =~ /(\.[^\$\.]*)$/;

# Define extension of the file.

    my $ext;
    if (defined($1)) {
      $ext = 1;
    } else {
      $ext = ".jpg";
    }
    
    my $uri = URI->new($link);
    my $abs_link = $uri->abs($page);
    
    # Get the heading information of the link.
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
    my $time = asctime(locatime($head[2]));
    chomp($time); #POSIX time hack

    print "Downloading $name (Last modified $time)\n";
    
    # The raw data from the page
    my $raw_data = get($abs_link->as_string());
    if (not defined($raw_data)) {
      print "Unable to donwload the $link\n";
      return;
    }

    my $out_name; # Name of the output file

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

#-------------------------------
open INFO_FILE, "<info_file";
while (1) {
  my $line =<INFO_FILE>; # Get line from info file

  if (not define($line)) {
    last;
  }

  chomp($line);
  #get the name and time of the last downloaded
  my ($name, $time) = split /\t/, $line;
  file_info{$name} = $time;
}
close INFO_FILE;

open IN_FILE, "<$in_file" or die "couldn't open $in_file: $!\n";

  while (1) {
    my $line = <IN_FILE>; # get line from the input
    if (not defined($line)){
      last;
    }
    chomp($line);
    
    # parse the information from the configuration file.
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
    $decoder->parser($text_page);

    # Get the image links
    my @links = $decoder->img();
    my @matches = grep /$pattern/, @links;

    if ($#matches == -1) {
      print "Nothing matched pattern for $name\n";
      print " Pattern: $pattern\n";
      foreach my $cur_link (@links) {
	print "      $cur_link\n";
      }
      next;
    }
    
    if ($#matches !=0) {
      print "Multiple matches\n";
      my $index = 1;
      foreach my $cur_link (@matches) {
	print "     $cur_link\n";
	do file($name, $page, $cur_link, $index);
	++$index;
      }
      next;
    }

    # One match
    do_file($name, $page, $matches[0], undef);
  }

open INFO_FILE, ">$info_file" or die "Couldn't create $info_file";

  foreach my $cur_name (sort keys my %file_info) {
    print INFO_FILE "$cur_name $file_info($cur_name)\n";
  }

close (INFO_FILE);

