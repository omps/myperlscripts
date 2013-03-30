use strict;
use warnings;

#
# This module contains all the functions that 
# deal with the map server
# and manipulate coordiantes
#

package map;

require Exporter;
use vars qw/@ISA @EXPORT $x_size $y_size $scale/;

@ISA = qw/Exporter/;
@EXPORT=qw/
    $x_size 
    $y_size 
    $scale 
    cache_dir
    get_file 
    get_scale_factor
    get_scales
    init_map 
    map_to_tiles 
    move_map
    scale_exists
    set_center_lat_long 
    set_map_scale
    toggle_type 
/;

use Geo::Coordinates::UTM;
use HTTP::Lite;

use constant MAP_PHOTO => 1;# Areal Photograph
use constant MAP_TOPO => 2;# Topo map 

$x_size = 3;	# Size of the map in X
$y_size = 3;	# Size of the map in Y
$scale = 12;	# Scale for the map

my $map_type = MAP_TOPO;# Type of the map

# Grand Canyon (360320N 1120820W)
# Grand Canyon (36 03 20N      112 08 20W)
my $center_lat = 
    36.0 + 3.0 / 60.0 + 20.0 / (60.0 * 60.0);
my $center_long = 
   -(112.0 + 8.0 / 60.0 + 20.0 / (60.0 * 60.0));

my $cache_dir = "$ENV{HOME}/.maps";

################################################
# convert_fract($) -- Convert 
#			to factional degrees
#
#	Knows the formats:
#		dddmmss
#		dd.ffff		(not converted)
################################################
sub convert_fract($)
{
    my $value = shift;	# Value to convert

    # Fix the case where we have things 
    # like 12345W or 13456S
    if ($value =~ /^([+-]?\d+)([nNeEsSwW])$/) {
	my $code;	# Direction code
	($value, $code) = ($1, $2);
	if (($code eq 's') || ($code eq 'S') || 
	    ($code eq 'W') || ($code eq 'w')) {
	    $value = -$value;
	}
    }
    # Is it a long series of digits 
    # with possible sign?
    if ($value =~ /^[-+]?\d+$/) {
	# USGS likes to squish things to 
	# together +DDDmmSS
	#
	# Get the pieces
	$value =~ /([-+]?)(\d+)(\d\d)(\d\d)/;
	my ($sign, $deg, $min, $sec) = 
		($1, $2, $3, $4);
	
	# Convert to fraction
	my $result = ($deg + ($min / 60.0) + 
	             ($sec / (60.0*60.0)));

	# Take care of sign
	if ($sign eq "-") {
	    return (-$result);
	}
	return($result);
    }
    if ($value =~ /^[-+]?\d*\.\d*$/) {
	return ($value);
    }
    print "Unknown format for ($value)\n";
    return (undef);
}
################################################
# set_center_lat_long($lat, $long) -- 
#	Change the center of a picture
################################################
sub set_center_lat_long($$)
{
    # Coordinate of the map	(latitude)
    my $lat = shift;	

    # Coordinate of the map (longitude)
    my $long = shift;	

    $lat = convert_fract($lat);
    $long = convert_fract($long);

    if (defined($long) and defined($lat)) {
	$center_lat = $lat;
	$center_long = $long;
    }
}

#
# Scales from 
#	http://teraserver.homeadvisor.msn.com/
#		/About/AbuotLinktoHtml.htm
#
# Fields
#	Resolution -- Resolution of the 
#			map in meter per pixel
#	factor -- Scale factor to turn UTM into 
#			tile number
#	doq -- Aerial photo available
#	drg -- Topo map available
#
my %scale_info = (
    10 => {
	resolution => 1, 
	factor     => 200, 
	doq        => 1, 
	drg        => 0
    },
    11 => {
	resolution => 2, 
	factor     => 400, 
	doq        => 1, 
	drg        => 1
    },
    12 => {
	resolution => 4, 
	factor     => 800, 
	doq        => 1, 
	drg        => 1
    },
    13 => {
	resolution =>  8, 
	factor     => 1600, 
	doq        => 1, 
	drg        => 1
    },
    14 => {
	resolution => 16, 
	factor     => 3200, 
	doq        => 1, 
	drg        => 1
    },
    15 => {
	resolution => 32, 
	factor     => 6400, 
	doq        => 1, 
	drg        => 1
    },
    16 => {
	resolution => 64, 
	factor     => 12800, 
	doq        => 1, 
	drg        => 1
    },
    17 => {
	resolution => 128, 
	factor     => 25600, 
	doq        => 0, 
	drg        => 1
    },
    18 => {
	resolution => 256, 
	factor     => 51200, 
	doq        => 0, 
	drg        => 1
    },
    19 => {
	resolution => 512, 
	factor     => 102400, 
	doq        => 0, 
	drg        => 1
    }
);
################################################
# map_to_tiles()
#
# Turn a map into a set of URLs
#
# Returns the url array
################################################
sub map_to_tiles()
{
    my @result;

    # Get the coordinates as UTM
    my ($zone,$easting,$north)=latlon_to_utm(
	'GRS 1980',$center_lat, $center_long);

    # Fix the zone, it must be a number
    $zone =~ /(\d+)/;
    $zone = $1;

    # Compute the center tile number
    my $center_x = 
        int($easting / 
		$scale_info{$scale}->{factor});

    my $center_y = 
        int($north / 
		$scale_info{$scale}->{factor});

    # Compute the starting location
    my $start_x = $center_x - int($x_size / 2);
    my $start_y = $center_y - int($y_size / 2);

    # Compute the ending location
    my $end_x = $start_x + $x_size;
    my $end_y = $start_y + $y_size;

    for (my $y = $end_y-1; $y >= $start_y; --$y) {
	for (my $x = $start_x; 
		$x < $end_x; ++$x) {

	    push (@result, { 
				T => $map_type,  
				S => $scale, 
				X => $x,
				Y => $y,
				Z =>$zone}
	    );
	}
    }
    return (@result);
}

################################################
# get_file($) -- Get a photo file from an URL
#
################################################
sub get_file($)
{
    my $url = shift;	# URL to get

    # The name of the file we are going to 
    # write into the cache
    my $file_spec = 
       "$cache_dir/t=$url->{T}_s=$url->{S}_".
	       "x=$url->{X}_y=$url->{Y}_".
	       "z=$url->{Z}.jpg";
    if (! -f $file_spec) {
	# Connection to the remote site
	my $http = new HTTP::Lite;

	# The image to get
	my $image_url = 
	   "http://terraserver-usa.com/tile.ashx?".
	   "T=$url->{T}&S=$url->{S}&".
	   "X=$url->{X}&Y=$url->{Y}&Z=$url->{Z}";
	print "Getting $image_url\n";

	# The request
	my $req = $http->request($image_url);
	if (not defined($req)) {
	    die("Could not get url $image_url");
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
# toggle_type -- Change the map type
################################################
sub toggle_type()
{
    if ($map_type == MAP_TOPO) {
	if ($scale_info{$scale}->{doq}) {
	    $map_type = MAP_PHOTO;
	}
    } else {
	if ($scale_info{$scale}->{drg}) {
	    $map_type = MAP_TOPO;
	}
    }
}

################################################
# get_scale_factor -- Get the current scale factor
################################################
sub get_scale_factor()
{
    return ($scale_info{$scale}->{factor});
}

################################################
# set_map_scale($scale) -- Set the scale of the map
#
# Returns 
#	true if the scale was set, 
#	false if it's not possible to set 
#		the scale to the give value
################################################
sub set_map_scale($)
{
    # The scale we want to have
    my $new_scale = shift;	

    if (not defined($scale_info{$new_scale})) {
	return(0);
    }
    if ($map_type == MAP_TOPO) {
	if (not $scale_info{$new_scale}->{drg}) {
	    return(0);
	}
    } else {
	if (not $scale_info{$new_scale}->{doq}) {
	    return(0);
	}
    }
    $scale = $new_scale;
    return (1);
}

################################################
# scale_exists($scale)
#
# Return true if the scale exists for 
#	this type of map
#################################################
sub scale_exists($)
{
    my $test_scale = shift;	# Scale to check 

    if ($map_type == MAP_TOPO) {
	if (not $scale_info{$test_scale}->{drg}) {
	    return (0);
	}
    } else {
	if (not $scale_info{$test_scale}->{doq}) {
	    return (0);
	}
    }
    return (1);
}
################################################
# get_scales -- Return an array of possible scales
################################################
sub get_scales()
{
    return ( sort {$a <=> $b} keys %scale_info);
}
################################################
# move_map($x, $y) -- Move the map in 
# 	the X and Y direction
################################################
sub move_map($$)
{
    my $x = shift;	# Amount to move in X tiles
    my $y = shift;	# Amount to move in Y tiles

    my ($zone,$east,$north)=
        latlon_to_utm('GRS 1980',
		$center_lat, $center_long);

    $east -= $x * get_scale_factor();
    $north -= $y * get_scale_factor();

    ($center_lat, $center_long) = 
        utm_to_latlon('GRS 1980', 
		$zone, $east, $north);
}
################################################
# cache_dir -- Return the cache directory
################################################
sub cache_dir()
{
    return($cache_dir);
}
################################################
# init_map -- Init the mapping system.
################################################
sub init_map()
{
    if (! -d $cache_dir) {
	if (not mkdir($cache_dir, 0755)) {
	    die("Could not create cache directory");
	}
    }
}

1;

