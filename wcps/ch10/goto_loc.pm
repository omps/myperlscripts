use strict;
use warnings;

#
# This module contains the information needed to go
# to a named location
#


package goto_loc;

use Tk;
use Geo::Coordinates::UTM;
use HTTP::Lite;
use Tk::Photo;
use Tk::JPEG;
use Tk::LabEntry;
use Tk::BrowseEntry;
use Image::Magick;

use map;

require Exporter;
use vars qw/@ISA @EXPORT/;

@ISA = qw/Exporter/;
@EXPORT=qw/goto_loc/;

my $tk_goto_loc;# Goto location popup window
my $place_name;	# Name of the place to go to
my $state;	# State containing the place name

my $tk_mw;	# Main window

#
# The scrolling lists of data
#
# Fields
#   name --  The title of the data
#   index -- Index into the data fields for 
#		the place data
#   width -- Width of the field
#
my @data_list = (
    { 				# 0
	name => "Name",
	index => 2,
	width => 30
    },
    { 				# 1
	name => "Type",
	index => 3,
	width => 10,
    },
    {				# 2
	name => "County",
	index => 4,
	width => 20,
    },
    { 				# 3
	name => "Latitude",
	index => 7,
	width => 10,
    },
    { 				# 4
	name => "Longitude",
	index => 8,
	width => 10,
    },
    { 				# 5
	name => "Elevation",
	index => 15,
	width => 9,
    }
);

# List of states and two character abbreviations
my @state_list = (
    "AK = Alaska",
    "AL = Alabama",
    "AR = Arkansas",
    "AS = American Samoa",
    "AZ = Arizona",
    "CA = California",
    "CO = Colorado",
    "CT = Connecticut",
    "DC = District of Columbia",
    "DE = Delaware",
    "FL = Florida",
    "FM = Federated States of Micronesia",
    "GA = Georgia",
    "GU = Guam",
    "HI = Hawaii",
    "IA = Iowa",
    "ID = Idaho",
    "IL = Illinois",
    "IN = Indiana",
    "IT = All Indian Tribes",
    "KS = Kansas",
    "KY = Kentucky",
    "LA = Louisiana",
    "MA = Massachusetts",
    "MD = Maryland",
    "ME = Maine",
    "MH = Marshall Island",
    "MI = Michigan",
    "MN = Minnesota",
    "MO = Missouri",
    "MP = Northern Mariana Islands",
    "MS = Mississippi",
    "MT = Montana",
    "NC = North Carolina",
    "ND = North Dakota",
    "NE = Nebraska",
    "NH = New Hampshire",
    "NJ = New Jersey",
    "NM = New Mexico",
    "NV = Nevada",
    "NY = New York",
    "OH = Ohio",
    "OK = Oklahoma",
    "OR = Oregon",
    "PA = Pennsylvania",
    "PR = Puerto Rico",
    "PW = Palau, Republic of",
    "RI = Rhode Island",
    "SC = South Carolina",
    "SD = South Dakota",
    "TN = Tennessee",
    "TX = Texas",
    "UT = Utah",
    "VA = Virginia",
    "VI = Virgin Islands",
    "VT = Vermont",
    "WA = Washington",
    "WI = Wisconsin",
    "WV = West Virginia",
    "WY = Wyoming"
);

# The window with the places in it
my $tk_place_where;	


################################################
# jump_to_loc -- 
#	Jump to the location specified 
#	in the list box
################################################
sub jump_to_loc()
{
    my $cur_selection = 
        $data_list[0]->{tk_list}->curselection();

    if (not defined($cur_selection)) {
        do_error(
	"You need to select an item to jump to"
	);
	return;
    }
    # Where we're jumping to
    my $lat = 
       $data_list[3]->{tk_list}->get(
	   $cur_selection->[0]);

    my $long = 
        $data_list[4]->{tk_list}->get(
	    $cur_selection->[0]);

    set_center_lat_long($lat, $long);
    ::show_map();
}

################################################
# select_boxes -- Called when a Listbox 
#		gets a selection
#
#	So make everybody walk in lock step
################################################
sub select_boxes($)
{
    # The widget in which someone selected
    my $tk_widget = shift;	

    my $selected = $tk_widget->curselection();

    foreach my $cur_data (@data_list) {
	$cur_data->{tk_list}->selectionClear(
	    0, 'end');

	$cur_data->{tk_list}->selectionSet(
	    $selected->[0]);
    }
}

################################################
# Given a state name, return the 
#	file with the information in it
################################################
sub info_file($)
{
    my $state = shift;	# State we have

    # The file we need for this state
    my $file_spec = cache_dir()."/${state}_info.txt";
    return ($file_spec);
}

################################################
# get_place_file($) -- 
#	Get a place information file 
#	for the give state
################################################
sub get_place_file($)
{
    my $state = shift;	# URL to get

    # The file we need for this state
    my $file_spec = info_file($state);

    if (! -f $file_spec) {
	# Connection to the remote site
	my $http = new HTTP::Lite;

	# The image to get
	my $place_url = 
	  "http://geonames.usgs.gov/".
	  "stategaz/${state}_DECI.TXT";
	print "Getting $place_url\n";

	# The request
	my $req = $http->request($place_url);
	if (not defined($req)) {
	    die("Could not get url $place_url");
	}

	# Dump the data into a file
	my $data = $http->body();
	open (OUT_FILE, ">$file_spec") or 
	   die("Could not create $file_spec");
	print OUT_FILE $data;
	close OUT_FILE;
    }
    return ($file_spec);
}

################################################
# do_goto_loc -- Goto a given location
################################################
sub do_goto_loc()
{
    if ((not defined($state)) || 
        ($state eq "")) {
	do_error("No state selected");
	return;
    }
    if (not defined($place_name)) {
	do_error("No place name entered");
	return;
    }
    if ($place_name =~ /^\s*$/) {
	do_error("No place name entered");
	return;
    }

    # The state as two character names
    my $state2 = substr($state, 0, 2); 
    get_place_file($state2);

    # The file containing the state information
    my $state_file = info_file($state2);

    open IN_FILE, "<$state_file" or 
        die("Could not open $state_file");

    my @file_data = <IN_FILE>;
    chomp(@file_data);
    close(IN_FILE);

    #TODO: Check to see if anything matched, 
    # if not error

    if (defined($tk_place_where)) {
	$tk_place_where->deiconify();
	$tk_place_where->raise();
    } else {
	# The pick a place screen
	$tk_place_where = $tk_mw->Toplevel(
	      -title => "Goto Selection");

	# Frame in which we place our places
	my $tk_place_frame = 
		$tk_place_where->Frame();

	# The scrollbar for the place list
	my $tk_place_scroll = 
	    $tk_place_where->Scrollbar()->pack(
		-side => 'left', 
		-fill => 'y'
	    );

	# Loop through each item and construct it
	foreach my $cur_data (@data_list) {
	    $cur_data->{tk_frame} = 
	        $tk_place_frame->Frame();

	    $cur_data->{tk_frame}->Label(
		-text => $cur_data->{name}
	    )->pack(
		-side => 'top'
	    );
	    $cur_data->{tk_list} = 
	    	$cur_data->{tk_frame}->Listbox(
		-width => $cur_data->{width},
		-selectmode => 'single',
		-exportselection => 0
	    )->pack(
		-side => "top",
		-expand => 1,
		-fill => "both"
	    );
	    $cur_data->{tk_list}->bind(
		"<<ListboxSelect>>", 
		\&select_boxes);

	    $cur_data->{tk_frame}->pack(
		-side => "left"
	    );

	    # Define how things scroll
	    $cur_data->{tk_list}->configure(
		-yscrollcommand => 
		    [ \&scroll_listboxes, 
		    $tk_place_scroll, 
		    $cur_data->{tk_list}, 
		    \@data_list]);
	}

	# define how the scroll bar works
	$tk_place_scroll->configure(
	    -command => sub {
		foreach my $list (@data_list) {
		    $list->{tk_list}->yview(@_);
		}
	    }
	);
	# Put the frame containing the list 
	# on the screen
	$tk_place_frame->pack(
	    -side => 'top', 
	    -fill => 'both', 
	    -expand => 1);

	$tk_place_where->Button(
	    -text => "Go To",
	    -command => \&jump_to_loc
	)->pack(
	    -side => 'left'
	);
	$tk_place_where->Button(
	    -text => "Close",
	    -command => sub { 
		$tk_place_where->withdraw(); 
	    }
	)->pack(
	    -side => 'left'
	);
    }

    foreach my $cur_result (@file_data) {
	# Split the data up into fields
	# See http://gnis.usgs.gov for field list
	my @data = split /\|/, $cur_result;
	if ($data[2] !~ /$place_name/i) {
	    next;
	}
	foreach my $cur_data (@data_list) {
	    $cur_data->{tk_list}->insert('end', 
	    	$data[$cur_data->{index}]);
	}
    }
    foreach my $cur_data (@data_list) {
	$cur_data->{tk_list}->selectionSet(0);
    }
}

###########################################
# goto_loc -- Goto a named location 
#	(popup the window to ask the name)
###########################################
sub goto_loc($)
{
    $tk_mw = shift;

    if (defined($tk_goto_loc)) {
	$tk_goto_loc->deiconify();
	$tk_goto_loc->raise();
	return;
    }
    $tk_goto_loc = $tk_mw->Toplevel(
	-title => "Goto Location");

    #TODO: Add label
    $tk_goto_loc->BrowseEntry(
	-variable => \$state,
	-choices => \@state_list,
    )->pack(
	-side => "top",
    );

    #TODO: Add place type
    $tk_goto_loc->LabEntry(
	-label => "Place Name: ", 
	-labelPack => [ -side => 'left'],
	-textvariable => \$place_name
    )->pack(
	-side => "top",
	-expand => 1,
	-fill => 'x'
    );
    $tk_goto_loc->Button(
	-text => "Locate",
	-command => \&do_goto_loc
    )->pack(
	-side => 'left'
    );
    $tk_goto_loc->Button(
	-text => "Cancel",
	-command => 
		sub {$tk_goto_loc->withdraw();}
    )->pack(
	-side => 'left'
    );
}

1;
