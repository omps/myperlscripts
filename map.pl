#!/usr/bin/perl
=pod

=head1 NAME

map.pl - Display a topographical map or areal photograph

=head1 SYNOPSIS

    map.pl

=head1 DESCRIPTION

The I<map.pl> queries an on-line database containing topographical
map data and areal photographs for all of the United States.  
The user can then pan and zoom the maps.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

use Tk;
use Geo::Coordinates::UTM;
use HTTP::Lite;
use Tk::Photo;
use Tk::JPEG;
use Tk::LabEntry;
use Tk::BrowseEntry;
use Image::Magick;

use map;
use goto_loc;

my $tk_mw;	# Main window
my $tk_canvas;	# Canvas on the main window
my $tk_nav;	# Navigation window

my $goto_long = 0; # Where to go from the entry
my $goto_lat = 0;

# The buttons to display the scale
my @tk_scale_buttons;	

################################################
# do_error -- Display an error dialog
################################################
sub do_error($)
{
    # Error message to display
    my $msg = shift;	

    $tk_mw->messageBox(
	-title => "Error",
	-message => $msg,
	-type => "OK",
	-icon => "error"
    );
}
    
################################################
# get_photo($) -- Get a photo from a URL
################################################
sub get_photo($)
{
    my $url = shift;	# Url to get

    # File containing the data
    my $file_spec = get_file($url);

    my $tk_photo = 
    	$tk_mw->Photo(-file => $file_spec);

    return ($tk_photo);
}

################################################
# paint_map(@maps)
#
# Paint a bitmap on the canvas
################################################
sub paint_map(@)
{
    my @maps = @_;	# List of maps to display

    # Delete all the old map items
    $tk_canvas->delete("map");

    for (my $y = 0; $y < $y_size; ++$y) {
	for (my $x = 0; $x < $x_size; ++$x) {
	    my $url = shift @maps;# Get the URL 
	    # Turn it into a photo
	    my $photo = get_photo($url);
	    $tk_canvas->createImage(
		$x * 200, $y * 200,
		-tags => "map",
		-anchor => "nw",
		-image => $photo);
	}
    }
    $tk_canvas->configure(
	-scrollregion => [ 
		$tk_canvas->bbox("all")]);
}

################################################
# show_map -- Show the current map
################################################
sub show_map()
{
    my @result = map_to_tiles();
    # Repaint the screen
    paint_map(@result);
}
################################################
# do_move($x, $y) -- Move the map in 
# 	the X and Y direction
################################################
sub do_move($$)
{
    my $x = shift;	# Amount to move in X tiles
    my $y = shift;	# Amount to move in Y tiles

    move_map($x, $y);
    show_map();
}
################################################
# change_type -- Toggle the type of the map
################################################
sub change_type() {
    toggle_type();
    set_scale($scale);
    show_map()
}
################################################
# set_scale($new_scale) -- 
#	Change the scale to a new value
################################################
sub set_scale($) {
    # The scale we want to have
    my $new_scale = shift;	

    if (not set_map_scale($new_scale)) {
	return;
    }
    $scale = $new_scale;
    for (my $i = 0; 
    	$i <= $#tk_scale_buttons; ++$i) {

	if (($i + 10) == $scale) {
	    $tk_scale_buttons[$i]->configure(
		-background => "green"
	    );
	} else {
	    # The background
	    my $bg = "white";
	    if (not scale_exists($i + 10)) {
		$bg = "gray";
	    }
	    $tk_scale_buttons[$i]->configure(
		-background => $bg
	    );
	}
    }
    show_map();
}
################################################
# change_canvas_size -- 
#	Change the size of the canvas
################################################
sub change_canvas_size()
{
    if ($x_size <= 0) {
	$x_size = 1;
    }
    if ($y_size <= 0) {
	$y_size = 1;
    }
    $tk_canvas->configure(
	-width => $x_size * 200, 
	-height => $y_size * 200);
    show_map();
}
# The name of the image file to save
my $save_image_name = "map_image"; 

my $tk_save_image;	# The save image popup

use Image::Magick;
################################################
# do_save_image -- 
#	Save the image as a file 
#	(actually do the work)
################################################
sub do_save_image()
{
    if ($save_image_name !~ /\.(jpg|jpeg)$/) {
	$save_image_name .= ".jpg";
    }

    # List of tiles to write
    my @tiles = map_to_tiles();

    # The image array
    my $images = Image::Magick->new();

    # Load up the image array
    foreach my $cur_tile (@tiles) {
	# The file containing the tile
	my $file = get_file($cur_tile);

	# The result of the read
	my $result = $images->Read($file);
	if ($result) {
	    print 
	      "ERROR: for $file -- $result\n";
	}
    }

    # Put them together
    my $new_image = $images->Montage(
	geometry => "200x200",
    	tile => "${x_size}x$y_size");

    my $real_save_image_name = $save_image_name;
    if ($save_image_name =~ /%d/) {
	for (my $i = 0; ; ++$i) {
	    $real_save_image_name = 
	        sprintf($save_image_name, $i);
	    if (! -f $real_save_image_name) {
		last;
	    }
	}
    }
    # Save them
    $new_image->Write($real_save_image_name);
    $tk_save_image->withdraw();
    $tk_save_image = undef;
}

################################################
# save_image -- Display the save image popup
################################################
sub save_image()
{
    if (defined($tk_save_image)) {
	$tk_save_image->deiconify();
	$tk_save_image->raise();
	return;
    }
    $tk_save_image = $tk_mw->Toplevel(
	-title => "Save Image");

    $tk_save_image->LabEntry(
	-label => "Name: ", 
	-labelPack => [ -side => 'left'],
	-textvariable => \$save_image_name
    )->pack(
	-side => "top",
	-expand => 1,
	-fill => 'x'
    );
    $tk_save_image->Button(
	-text => "Save",
	-command => \&do_save_image
    )->pack(
	-side => 'left'
    );
    $tk_save_image->Button(
	-text => "Cancel",
	-command => 
	    sub {$tk_save_image->withdraw();}
    )->pack(
	-side => 'left'
    );
}
################################################
# print_image -- 
#	Print the image to the default printer
#	(Actually save it as postscript)
################################################
sub print_image()
{
    # List of tiles to write
    my @tiles = map_to_tiles();

    # The image array
    my $images = Image::Magick->new();

    # Load up the image array
    foreach my $cur_tile (@tiles) {
	# The file containing the tile
	my $file = get_file($cur_tile);

	# The result of the read
	my $result = $images->Read($file);
	if ($result) {
	    print 
	      "ERROR: for $file -- $result\n";
	}
    }

    # Put them together
    my $new_image = $images->Montage(
	geometry => "200x200",
    	tile => "${x_size}x$y_size");

    my $print_file;	# File name for printing

    for (my $i = 0; ; ++$i) {
	if (! -f "map.$i.ps") {
	    $print_file = "map.$i.ps";
	    last;
	}
    }
    # Save them
    $new_image->Set(page => "Letter");
    $new_image->Write($print_file);
    $tk_mw->messageBox(
	-title => "Print Complete",
	-message => 
      "Print Done.  Output file is $print_file",
	-type => "OK",
	-icon => "info"
    );
}
################################################
# goto_lat_long -- Goto the given location
################################################
sub goto_lat_long()
{
    set_center_lat_long($goto_lat, $goto_long);
}


################################################
# scroll_listboxes -- Scroll all the list boxes
#	(taken from the O'Reilly book 
#	with little modification)
################################################
sub scroll_listboxes
{
    my ($sb, $scrolled, $lbs, @args) = @_;

    $sb->set(@args);
    my ($top, $bottom) = $scrolled->yview();
    foreach my $list (@$lbs) {
	$list->{tk_list}->yviewMoveto($top);
    }
}

# Mapping from direction to image names
my %images = (
    ul => undef,
    u => undef,
    ur => undef,
    l => undef,
    r => undef,
    dl => undef,
    d => undef,
    dr => undef,
);

my @key_bindings = (
    { 
	key => "<Key-j>", 
	event => sub{do_move(0, +1)}
    },
    { 
	key => "<Key-k>", 
	event => sub{do_move(0, -1)}
    },
    { 
	key => "<Key-h>", 
	event => sub{do_move(+1, 0)}
    },
    { 
	key => "<Key-l>", 
	event => sub{do_move(-1, 0)}
    },
    { 
	key => "<Key-p>", 
	event => \&print_image
    },
    { 
	key => "<Key-q>", 
	event => sub { exit(0)}
    },
    { 
	key => "<Key-x>", 
	event => sub { exit(0)}
    },
    { 
	key => "<Key-s>", 
	event => \&save_image
    },
);

###############################################
# build_gui -- Create all the GUI elements
###############################################
sub build_gui()
{
    $tk_mw = MainWindow->new(
	-title => "Topological Map");

    my $tk_scrolled = $tk_mw->Scrolled(
	'Canvas',
	-scrollbars => "sw"
    )->pack(
	-fill => "both",
	-expand => 1,
	-anchor => 'n',
	-side => 'top'
    );

    $tk_canvas = 
    	$tk_scrolled->Subwidget('canvas');
    $tk_canvas->configure(
	-height => 600,
	-width => 600
    );
    $tk_canvas->CanvasBind("<Button-1>", 
    	sub {set_scale($scale-1)});

    $tk_canvas->CanvasBind("<Button-2>", 
    	sub {set_scale($scale+1)});

    $tk_canvas->CanvasBind("<Button-3>", 
    	sub {set_scale($scale+1)});

    foreach my $cur_image (keys %images) {
	# The file to put in the image
	my $file_name = "arrow_$cur_image.jpg";

	# Create the image
	$images{$cur_image} = $tk_mw->Photo(
	    -file => $file_name);
    }
    $tk_mw->Button(-image => $images{ul}, 
	-command => sub {do_move(-1, 1)} )->grid(
	    $tk_mw->Button(
		-image => $images{u}, 
		-command => sub {do_move(0, 1)} 
	    ), 
	    $tk_mw->Button(
		-image => $images{ur}, 
		-command => sub {do_move(1, 1)}
	    ),
    	-sticky => "nesw"
    );
    $tk_mw->Button(-image => $images{l}, 
        -command => sub {do_move(-1, 0)} )->grid(
	    $tk_scrolled,
	    $tk_mw->Button(
		-image => $images{r}, 
		-command => sub {do_move(1, 0)}
	    ),
    	-sticky => "nesw"
    );
    $tk_mw->Button(
	-image => $images{dl}, 
	-command => sub {do_move(-1, -1)} 
    )->grid(
	$tk_mw->Button(
	    -image => $images{d}, 
	    -command => sub {do_move(0, -1)} 
	),
	$tk_mw->Button(
	    -image => $images{dr}, 
	    -command => sub {do_move(1, -1)} 
	),
    	-sticky => "nesw"
    );
    $tk_mw->gridColumnconfigure(1, -weight => 1);
    $tk_mw->gridRowconfigure(1, -weight => 1);

    # TODO: Is there some way of 
    # making this on top?
    $tk_nav = $tk_mw->Toplevel(
	-title => "Map Control");

    # Map the keys 
    foreach my $bind (@key_bindings) {
	$tk_mw->bind($bind->{key}, 
		$bind->{event});

	$tk_nav->bind($bind->{key}, 
		$bind->{event});
    }

    # The item to set the scale
    my $tk_scale_frame = $tk_nav->Frame();
    $tk_scale_frame->pack(
	-side => 'top', 
	-anchor => 'w'
    );

    $tk_scale_frame->Button(
	    -text => "+", 
	    -command => sub {set_scale($scale-1)}
	)->pack(
	    -side => 'right'
	);

    # Go through each scale and produce 
    # a button for it.
    foreach my $info (get_scales()) {
	push(@tk_scale_buttons, 
	    $tk_scale_frame->Button(
		-bitmap => "transparent",
		-width => 10,
		-height => 20,
		-command => 
			sub {set_scale($info);}
	    )->pack(
		-side => 'right'
	    ));
    }

    $tk_scale_frame->Button(
	-text => "-", 
	-command => sub {set_scale($scale+1) }
    )->pack(
	-side => 'right'
    );

    $tk_nav->Button(
	-text => "Toggle Type",
	-command => \&change_type
    )->pack(
	-side => "top",
	-anchor => "w"
    );


    # The frame for the X size adjustment
    my $tk_map_x = $tk_nav->Frame()->pack(
	    -side => "top", 
	    -fill => "x", 
	    -expand => 1
	);

    $tk_map_x->Label(
	    -text => "Map Width"
	)->pack(
	    -side => "left"
	);

    $tk_map_x->Button(
	    -text => "+", 
	    -command => sub {
		$x_size++, change_canvas_size()
	    }
	)->pack(
	    -side => "left"
	);
    $tk_map_x->Button(
	    -text => "-", 
	    -command => sub {
		$x_size--, change_canvas_size()
	    }
	)->pack(
	    -side => "left"
	);

    # The frame for the Y size adjustment
    my $tk_map_y = $tk_nav->Frame()->pack(
	-side => "top", 
	-fill => "x", 
	-expand => 1
    );
    $tk_map_y->Label(
	-text => "Map Height"
    )->pack(
	-side => "left"
    );
    $tk_map_y->Button(
	-text => "+", 
	-command => 
	    sub {$y_size++, change_canvas_size()}
    )->pack( 
	-side => "left"
    );
    $tk_map_y->Button(
	-text => "-", 
	-command => 
	    sub {$y_size--, change_canvas_size()}
    )->pack(
	-side => "left"
    );
    $tk_nav->Button(
	-text => "Save Image",
	-command => \&save_image
    )->pack(
	-side => "top",
	-anchor => "w"
    );
    $tk_nav->Button(
	-text => "Print",
	-command => \&print_image
    )->pack(
	-side => "top",
	-anchor => "w"
    );

    # The frame for the lat/log goto button
    my $tk_lat_long = $tk_nav->Frame(
    )->pack( 
	-side => "top",
	-expand => 1,
	-fill => "x"
    );

    $tk_lat_long->Label(
	-text => "Latitude:"
    )->pack(
	-side => "left"
    );
    $tk_lat_long->Entry(
	-textvariable => \$goto_lat,
	-width => 10
    )->pack(
	-side => "left"
    );
    $tk_lat_long->Label(
	-text => "Longitude"
    )->pack(
	-side => "left"
    );
    $tk_lat_long->Entry(
	-textvariable => \$goto_long,
	-width => 10
    )->pack(
	-side => "left"
    );

    $tk_lat_long->Button(
	-text => "Goto Lat / Long",
	-command => \&goto_lat_long
    )->pack(
	-side => "left"
    );
    $tk_nav->Button(
	-text => "Goto Location",
	-command => sub { goto_loc($tk_mw);}
    )->pack(
	-side => "top",
	-anchor => "w"
    );
    $tk_nav->Button(
	-text => "Exit",
	-command => sub {exit(0);}
    )->pack(
	-side => "top",
	-anchor => "w"
    );

    $tk_nav->bind('<Destroy>', sub { exit(0);});
    $tk_nav->raise();
}

init_map();
build_gui();

# Grand Canyon (360320N 1120820W)
set_center_lat_long(360320, -1120820);
set_scale(12);

show_map();
$tk_nav->raise();

MainLoop();
