#!/usr/bin/perl -I/usr/local/lib
=pod

=head1 NAME

make_page.pl - Make a page for a photo album

=head1 SYNOPSIS

    make_page.pl <in-file>

=head1 DESCRIPTION

The I<make_page.pl> program reads a text file containing
a description of the page and creates a HTML version of
the page with thumbnails of the pictures specified in
the input file.

=head1 INPUT FILE FORMAT

=over 4

=item B<=title> I<Page Title>

Specify the title of the page.  This will be put in
the html title and the first level 1 head.

=item B<=head1> I<text>

=item B<=head2> I<text>

=item B<=head3> I<text>

=item B<=head4> I<text>

=item B<=head5> I<text>

Specify level 1 through 5 head.

=item B<=text>

Start a text section.  Anything that follows is consider
text to be put in the page.

=item B<=photo>

Stat a photograph section.  Any lines that follow are considered
the name of image file.

=back

=head1 EXAMPLES

Sample input file:

    =title My Snapshots
    =head1 Baby
    =text
    Ingesting a Cheerio nasally
    =photo
    p4240093.jpg
    p4240102.jpg
    pc200088.jpg
    pc200090.jpg
    =head1 Dog
    =photo
    p2230148.jpg
    p2250157.jpg
    p2250159.jpg
    p8040360.jpg
    p8040361.jpg
    p8040364.jpg

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

# CONFIGURATION SECTION
use constant ACROSS => 6;	# Number of photos across
use constant X_SIZE => 100;
use constant Y_SIZE => 150;

use POSIX;

use Image::Magick;
use Image::Info qw(image_info);

#
# File format:
#	=title heading/title	-- Head/title of the page
#	=head[1234] 		-- Heading
#	=text 			-- Start text section
#	=photo			-- Start photo section
#	xxxxxxx.jpg		-- Picture
#	text			-- Text


my @photo_list = ();	# List of queued photos

##################################################
# do_thumb($file) -- Create a thumbnail of a file
##################################################
sub do_thumb($)
{
    my $file = shift;	# The file to create 
    			# thumbnail of

    my $image = Image::Magick->new();
    my $status = $image->Read($file);
    if ($status) {
	print "Error $status\n";
	return;
    }

    my $x_scale = X_SIZE / $image->Get('width');
    my $y_scale = Y_SIZE / $image->Get('height');
    my $scale = $x_scale;
    if ($y_scale < $scale) {
	$scale = $y_scale;
    }
    my $new_x = int($image->Get('width') * $scale + 0.5);
    my $new_y = int($image->Get('height') * $scale + 0.5);

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
########################################################
# info_date($file) -- Return the data (from the info section)
#
# Returns the date from the jpeg info or undef if none.
########################################################
sub info_date($)
{
    my $file = shift;

    my $info = image_info($file);
    if (not defined($info)) {
	return (undef);
    }
    if (not defined($info->{DateTime})) {
	return (undef);
    }
    if ($info->{DateTime} eq "0000:00:00 00:00:00") {
	return (undef);
    }
    # This can be formatted better
    return ($info->{DateTime});
}
########################################################
# file_date($file) -- Compute the date from the 
#	file modification date.
#
# Returns date as a string
########################################################
sub file_date($)
{
    my $file = shift;	# The file name

    # File information
    my @stat = stat("$file");

    # Date as a string (f) is the code for file
    my $date = strftime(
	"%a %B %d, %C%y <BR>%r(f)", localtime($stat[9]));

    return ($date);
}
########################################################
# get_date($file) -- Get a date from the file
#
# Returns date as a string
########################################################
sub get_date($) 
{
    my $file = shift;	# The file to get the information on
    my $date;	 # The date we've seen

    $date = info_date($file);
    if (defined($date)) {
	return ($date);
    }

    return (file_date($file));
}

##################################################
# do_file -- Print the cell for a single file
##################################################
sub do_file($)
{
    # The name of the file we are writing
    # (Can be undef for the end of the table)
    my $cur_file = shift;

    if (defined($cur_file)) {
	if (! -f "_thumb/$cur_file") {
	    do_thumb($cur_file);
	}
	print <<EOF;
	<A HREF="$cur_file">
	<IMG SRC=_thumb/$cur_file>
	</A><BR>
EOF
	my $date = get_date($cur_file);
	print "$date<BR>\n";
    } else {
	print "            &nbsp;\n";
    }
}
##################################################
# dump_photo -- Dump the list of photos we've
#	accumulated
##################################################
sub dump_photos() {
    my $i;	# Photo index

    if ($#photo_list < 0) {
	return;
    }
    print "<TABLE>\n";
    while ($#photo_list >= 0) {
	print "    <TR>\n";
	for ($i = 0; $i < ACROSS; $i++) {
	    # The photo we are processing
	    print "        <TD>\n";
	    do_file(shift @photo_list);
	    print "        </TD>\n";
	}
	print "    </TR>\n";
    }
    print "</TABLE>\n";
}

########################################################
if (! -d "_thumb") {
    mkdir("_thumb");
}

# Current mode for non = lines
my $mode = "Photo";	# The current mode (Photo/Text)

# Loop over each line of the input
while (<>) {
    chomp();

    if (/^=title\s+(.*)/) {
	dump_photos();
        print <<EOF;
<HEAD><TITLE>$1</TITLE></HEAD>
<BODY BGCOLOR="#FFFFFF">
<H1 ALIGN="center">$1</H1>
<P>
EOF
	next;
    }
    if (/^=head([1-4])\s+(.*$)/) {
	dump_photos();
        print "<H$1>$2</H$1>\n";
	next;
    }

    if (/^=text/) {
	dump_photos();
        $mode = "Text";
	next;
    }

    if (/^=photo/) {
        $mode = "Photo";
	next;
    }

    if ($mode eq "Photo") {
        if (length($_) == 0) {
	    next;
	}
	if (! -f $_) {
	    die("No such file $_");
	}
	push(@photo_list, $_);
	next;
    }
    if ($mode eq "Text") {
        print "$_\n";
	next;
    }
    die("Impossible mode $mode\n");
}
dump_photos();
