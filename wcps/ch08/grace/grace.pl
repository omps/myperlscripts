#!/usr/bin/perl
=pod

=head1 NAME

grace.pl - A program for a two year old

=head1 SYNOPSIS

    grace.pl [seq] 

=head1 DESCRIPTION

The I<grace.pl> has two modes of operation.  In normal
mode, pressing a key will display a given image and 
pay a sound.

In sequential mode the system displays a sequence
of images and sounds.

To get out of the program type "exit" in order.

=head1 INPUT FILES

In sequential mode, the file I<seq_key.txt> contains a list
of sounds to play in sequence.  Actually each line of this file
is a system command to play a sound (or multiple sounds).

The file I<seq_image.txt> contains a line of images (one per line)
to display in order.

In normal mode the file I<key.txt> contains a key to sound playing
command mapping.  The key is the first item on the line, the command
taking up the rest of the line.

The I<image.txt> file contains a set of key to image mappings.  Again,
the key is the first field, the image the second.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
#
# Display a big window and let Grace type on it.
# 
# When a key is pressed, display a picture and play
# a sound.
#
# The file cmd.txt contains the sound playing 
# command.
#
# The format of this file is:
#
# key <tab> command
#
# 
use strict;
use warnings;
use POSIX qw(:sys_wait_h);

use Tk;
use Tk::JPEG;

my %sound_list = ();	 # Key -> Command mapping
my %image_list = ();	# List of images to display

# List of sound commands in sequential mode
my @seq_sound_list;

# List of images in sequential mode
my @seq_image_list;	

my $bg_pid = 0;	# Pid of the background process

my $canvas;		# Canvas for drawing
my $canvas_image;	# Image on the canvas

my $mw;			# Main window
my $mode = "???";	# The mode (seq, key, debug)

#
# Called when a child dies.  
# Tell the system that nothing
# is running in background
#
sub child_handler()
{
    my $wait_pid = waitpid(-1, WNOHANG);
    if ($wait_pid == $bg_pid) {
	$bg_pid = 0;
    }
}

# What we have to type to get out of here
my @exit = qw(e x i t);
my $stage = 0;	# How many letters of "exit" typed

my $image_count = -1;	# Current image in seq mode
my $sound_count = -1;	# Current sound in seq mode

####################################################
# get_image($key) -- Get the image to display 
# 
# Make sure it's the right one for the mode
####################################################
sub get_image($)
{
    my $key = shift;	# Key that was just pressed

    if ($mode eq "seq") {
	++$image_count;
	if ($image_count > $#seq_image_list) {
	    $image_count = 0;
	}
	return ($seq_image_list[$image_count]);
    }
    return ($image_list{$key});
}

####################################################
# get_sound($key) -- Get the next sound to play
####################################################
sub get_sound($)
{
    my $key = shift;	# Key that was just pressed

    if ($mode eq "seq") {
	++$sound_count;
	if ($sound_count > $#seq_sound_list) {
	    $sound_count = 0;
	}
	return ($seq_sound_list[$sound_count]);
    }
    return ($image_list{$key});
}
####################################################
# Handle keypresses
####################################################
sub key_handler($) {
    # Widget generating the event
    my ($widget) = @_;	

    # The event causing the problem
    my $event = $widget->XEvent;

    # The key causing the event
    my $key = $event->K();

    if ($exit[$stage] eq $key) {
	$stage++;
    }
    if ($stage > $#exit) {
	exit (0);
    }
    # Lock system until bg sound finishes
    if ($bg_pid != 0) {
        return;
    }

    my $image_name = get_image($key);
    my $sound = get_sound($key);

    #
    # Display Image
    #
    if (defined($image_name)) {
	# Define an image
	my $image = 
	    $mw->Photo(-file => $image_name);

	if (defined($canvas_image)) {
	    $canvas->delete($canvas_image);
	}
	$canvas_image = $canvas->createImage(0, 0, 
	    -anchor => "nw",
	    -image => $image);
    }
    else
    {
	print NO_KEY "$key -- no image\n";
    }
    #
    # Execute command
    #
    if (defined($sound)) {
	if ($bg_pid == 0) {
	    $bg_pid = fork();
	    if ($bg_pid == 0) {
		exec($sound);
	    }
	}
    } else {
	print NO_KEY "$key -- no sound\n";
    }
}

###################################################
# read_list(file)
#
#	Read a list from a file and return the 
#	hash containing the key value pairs.
####################################################
sub read_list($) 
{
    my $file = shift;	# File we are reading
    my %result;		# Result of the read

    open (IN_FILE, "<$file") or 
    	die("Could not open $file");

    while (<IN_FILE>) {
	chomp($_);
	my ($key, $value) = split /\t/, $_;

	$result{$key} = $value;
    }
    close (IN_FILE);
    return (%result);
}

#####################################################
# read_seq_list($file) -- Read a sequential list
####################################################
sub read_seq_list($)
{
    my $file = shift;	# File to read
    my @list;		# Result

    open IN_FILE, "<$file" or 
    	die("Could not open $file");
    @list = <IN_FILE>;
    chomp(@list);
    close(IN_FILE);
    return (@list);
}
#===================================================
$mode = "key";
if ($#ARGV > -1) {
    if ($ARGV[0] eq "seq") {
	$mode = "seq";
    } else {
	$mode = "debug";
    }
}

$SIG{CHLD} = \&child_handler;

if ($mode eq "seq") {
    # The list of commands
    @seq_sound_list = read_seq_list("seq_key.txt");
    @seq_image_list = 
    	read_seq_list("seq_image.txt");
} else {
    # The list of commands
    %sound_list = read_list("key.txt");
    %image_list = read_list("image.txt");
}

# Open the key error file
open NO_KEY, ">no_key.txt" or 
	die("Could not open no_key.txt");


$mw = MainWindow->new(-title => "Graces Program");

# Big main window
my $big = $mw->Toplevel();

#
# Don't display borders
# (And don't work if commented in)
#
#if ($#ARGV == -1) {
#    $big->overrideredirect(1);
#}

$mw->bind("<KeyPress>" => \&key_handler);
$big->bind("<KeyPress>" => \&key_handler);

# Width and height of the screen
my $width = $mw->screenwidth();
my $height = $mw->screenheight();

if ($mode eq "debug") {
    $width = 800;
    $height = 600;
}

$canvas = $big->Canvas(-background => "Yellow",
	-width => $width,
	-height => $height
    )->pack(
	-expand => 1,
	-fill => "both"
    );
$mw->iconify();

if ($mode ne "debug") {
    $big->bind("<Map>" => 
    	sub {$big->grabGlobal();});
}
    
MainLoop();
