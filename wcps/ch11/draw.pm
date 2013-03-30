use strict;
use warnings;

package draw;
use GD;
use GD::Arrow;

use size;

require Exporter;
use vars qw/@ISA @EXPORT $image $color_black/;

@ISA = qw/Exporter/;
@EXPORT = qw/draw_re $image $color_black/;

# Thickness of the lines
use constant THICKNESS => 3;	

# Offset for line 2 of a 2 line text field
use constant X_LINE2_OFFSET => 10;

# Offset for line 2 of a 2 line text field
use constant Y_LINE2_OFFSET => 15;

#
# Image variables
#
my $color_white;	# White color
my $color_green;	# The green color
my $color_blue;		# Blue color
my $color_light_green;	# Light green color
################################################
# filled_rectangle -- Draw a filled rectangle at
#		the given location
################################################
sub filled_rectangle($$$$$)
{
    # Corners of the rectangle
    my $x1 = shift;	
    my $y1 = shift;
    my $x2 = shift;
    my $y2 = shift;

    my $color = shift;	# Color for drawing

    if ($main::opt_d) {
	print 
	  "Rectangle($x1, $y1, $x2, $y2, $color)\n";
    }
    $image->filledRectangle(
		$x1, $y1, $x2, $y2, 
		$color);
    $image->setThickness(1);
    $image->rectangle(
		$x1, $y1, $x2, $y2, 
		$color_black);
}

################################################
# arrow -- Draw an arrow from x1,y1 -> x2,y2
#
# All arrows are black
################################################
sub arrow($$$$) {
    my $x1 = shift;	# Start of arrow
    my $y1 = shift;
    my $x2 = shift;	# End of arrow
    my $y2 = shift;

    if ($main::opt_d) {
	print "Arrow($x1, $y1, $x2, $y2)\n";
    }
    # For some reason arrows 
    # tend to point backwards
    my $arrow = GD::Arrow::Full->new(
	-X1 => $x2,
	-Y1 => $y2,
	-X2 => $x1,
	-Y2 => $y1,
	-WIDTH => THICKNESS-1);
    $image->setThickness(1);
    $image->filledPolygon($arrow, $color_black);
}

############################################
# The "PLUS" node
#
#
#     0  1  2    1p 2p  3p (p = +size of child)
#     v  v  v L3 v  v   v
#     .  ---------  .   .
#     . /.   .   .\ .   .
#     ./ .   .   . \    .
# a2  <  .   .   .  > a1.
#     .\ .   .   . /.   .
#     . \+-------+/     .
#  L1--->| child |----->+ L2
#     .  +-------+  .   .
#
# Arc start, end, centers
#
#       a1 / 270  - 180 / (ap*2, y-a)
#       a2 /  90  - 180 / (a0, y-2a), (a2, y-2a)
#
#       L1 (a3, y+2a) (a3p, y+2a)
############################################

#------------------------------------------
# Draw the plus type node
#------------------------------------------
sub draw_plus($)
{
    # The node we are drawing
    my $cur_node = shift;       

    layout_array(
        $cur_node->{x_loc} + 
	    $cur_node->{arc_size} * 1,
        $cur_node->{y_loc},
        $cur_node->{y_size},
        @{$cur_node->{children}});

    draw_node_array($cur_node->{children});

    # The place we start drawing from (X)
    my $from_x = $cur_node->{x_loc};

    # The current middle of the item (Y)
    my $y = $cur_node->{y_loc} + 
    	int($cur_node->{y_size}/2);

    # Size of an arc
    my $arc_size = $cur_node->{arc_size};

    # Size of the child
    my $child_x = $cur_node->{child_x};

    # Debugging
    if (0) {
        for (my $debug_x = 0; 
	     $debug_x < 5; 
	     $debug_x++) {
            $image->line(
                    $from_x +
		        $arc_size * $debug_x,
		    $y - $arc_size*2,
                    $from_x + 
			$arc_size * $debug_x,
		    $y + $arc_size*2,
		    $color_black
                    );
        }

        for (my $debug_x = 3; 
	     $debug_x < 7; 
	     $debug_x++) {
            $image->line(
                    $from_x + $child_x +
		    	$arc_size * $debug_x,
				$y - $arc_size*2,
                    $from_x + $child_x +
		    	$arc_size * $debug_x,
				$y + $arc_size*2,
                    $color_green
		);
        }
    }

    my $flip = 1;       # Flipping factor
    if ($cur_node->{min_flag}) {
        $flip = -1;
    }

    $image->setThickness(THICKNESS);
    # First arc (a1)
    $image->arc(
            $from_x + $child_x + $arc_size,
	    $y - $arc_size * $flip,
	    $arc_size *2, $arc_size *2,
	    270, 90,
	    $color_black);

    $image->arc(
            $from_x + $arc_size * 1,
	    	$y - $arc_size * $flip,
	    $arc_size *2, $arc_size *2,
	    90, 270,
	    $color_black);

    # Draw (L1)
    arrow(
            $from_x, $y,
            $from_x + $arc_size * 1, $y
    );

    # Draw (L2)
    arrow(
            $from_x + $child_x + $arc_size * 1, 
	    $y,
            $from_x + $child_x + $arc_size * 2, 
	    $y
    );

    # Draw (L3)
    arrow(
            $from_x + $child_x + $arc_size * 1,
	    $y - $arc_size * 2,
            $from_x + $arc_size * 1, 
	    $y - $arc_size * 2
    );


    # Text to display for the current node
    my $text = $cur_node->{node}->{text_label};
    if ($cur_node->{min_flag}) {
	$text .= "?";
    }

    $image->string(
	    gdMediumBoldFont,
            $from_x + $child_x + $arc_size * 2,
	    	$y - $arc_size * 2,
            $text,
	    $color_blue);

    $cur_node->{left_x} = $from_x;
    $cur_node->{left_y} = $y;

    $cur_node->{right_x} = 
    	$from_x + $cur_node->{child_x} +
		$cur_node->{arc_size} * 2;

    $cur_node->{right_y} = $y;
}
############################################
# The "STAR" node
#
#
#			(p = +size of child)
#     0  1  2    3       p3 p4  p5 
#     v  v  v    v   L2  v  v   v
#     .  -----------------  .   .
#     . /.  .    .       .\ .   .
#     ./ .  .    .       . \    .
# a6  <  .  .    .    a5 .  >   .
#     .\ .  .    .       . /.   .
#     . \.  . .  +-------+/     .
#  L3----------->| child |- .   +
#     .  .\ . j  +-------+  .a4/.
#     .  . \a1   .       .  . / .
#     .  .  \    .       .  ./  .
#     .  .  |    .       .  |   .
#     .  .  .\   .       . /   .
#     .  .  a2\  .       ./a3  .
#     .  .  .  \---------
#           ^    ^    L1
#           2    3
#
# Arc / swing / center
#       a1 / 270  - 0   / (a1,  y + a)
#       a2 /  90  - 180 / (a3,  y + a)
#       a3 /   0  - 90  / (p3,  y + a)
#       a4 / 180  - 270   / (a4p, y)
#
#       a5 / 270  - 90  / (p3, y-a)
#       a6 /  90  - 270 / (a1, y-a)
#
#       L1 (a3, y+2a) (a3p, y+2a)
############################################

#-----------------------------------------
# Draw the star type node
#-----------------------------------------
sub draw_star($)
{
    # The node we are drawing
    my $cur_node = shift;       

    layout_array(
        $cur_node->{x_loc} + 
	    $cur_node->{arc_size} * 3,
        $cur_node->{y_loc},
        $cur_node->{y_size},
        @{$cur_node->{children}});

    # The place we start drawing from (X)
    my $from_x = $cur_node->{x_loc};

    # The current middle of the item (Y)
    my $y = int($cur_node->{y_loc} + 
    	$cur_node->{y_size}/2);

    # Size of an arc
    my $arc_size = $cur_node->{arc_size};

    # Size of the child
    my $child_x = $cur_node->{child_x};

    # Debugging
    if (0) {
        for (my $debug_x = 0; 
		$debug_x < 5; 
		$debug_x++) {
            $image->line(
                    $from_x + 
		    $arc_size * $debug_x,
			$y - $arc_size*2,
                    $from_x + 
		    	$arc_size * $debug_x,
		    $y + $arc_size*2,
		    $color_black
		);
        }

        for (my $debug_x = 3; 
		$debug_x < 7; 
		$debug_x++) {
            $image->line(
                    $from_x + $child_x +
		    	$arc_size * $debug_x,
				$y - $arc_size*2,
                    $from_x + $child_x +
		    	$arc_size * $debug_x,
				$y + $arc_size*2,
                    $color_green
		);
        }
    }

    my $flip = 1;       # Flipping factor
    if ($cur_node->{min_flag}) {
        $flip = -1;
    }

    $image->setThickness(THICKNESS);
    if ($flip == 1) {
	# First arc (a1)
	$image->arc(
		$from_x + $arc_size, 
		$y + $arc_size,
		$arc_size * 2, $arc_size * 2,
		270,  0,
		$color_black);

	# Second arc (a2)
	$image->arc(
		$from_x + $arc_size * 3, 
		$y + $arc_size,
		$arc_size * 2, $arc_size * 2,
		90, 180,
		$color_black);
    } else {
	# First arc (a1)
	$image->arc(
		$from_x + $arc_size, 
		$y - $arc_size,
		$arc_size * 2, $arc_size * 2,
		0, 90,
		$color_black);

	# Second arc (a2)
	$image->arc(
		$from_x + $arc_size * 3, 
		$y - $arc_size,
		$arc_size * 2, $arc_size * 2,
		180, 270,
		$color_black);
    }

    if ($flip > 0)  {
	# Third arc (a3)
	$image->arc(
		$from_x + $child_x + 
		    $arc_size * 3,
		$y + $arc_size,
		$arc_size * 2, $arc_size * 2,
		0, 90,
		$color_black);

	# Fourth arc (a4)
	$image->arc(
		$from_x + $child_x + 
		    $arc_size * 5,
		$y + $arc_size,
		$arc_size * 2, $arc_size * 2,
		180, 270,
		$color_black);
    } else {
	# Third arc (a3)
	$image->arc(
		$from_x + $child_x + 
			$arc_size * 3,
		$y - $arc_size,
		$arc_size * 2, $arc_size * 2,
		270, 0,
		$color_black);

	# Fourth arc (a4)
	$image->arc(
		$from_x + $child_x + 
		    $arc_size * 5,
		$y - $arc_size,
		$arc_size * 2, $arc_size * 2,
		90, 180,
		$color_black);
    }

    # Fifth arc (a5)
    $image->arc(
            $from_x + $child_x + $arc_size * 3,
	    	$y - $arc_size * $flip,
	    $arc_size * 2, $arc_size * 2,
	    270, 90,
	    $color_black);

    # Sixth arc (a6)
    $image->arc(
            $from_x + $arc_size,
	    	$y - $arc_size * $flip,
	    $arc_size * 2, $arc_size * 2,
	    90, 270,
	    $color_black);

    # L1
    arrow(
            $from_x + $arc_size * 3,
	    	$y + $arc_size * 2 * $flip,
            $from_x + $arc_size * 3 + $child_x,
		$y + $arc_size * 2 * $flip);

    # L2
    arrow(
            $from_x + $arc_size * 3 + $child_x,
	    	$y - $arc_size * 2 * $flip,
            $from_x + $arc_size * 1,
	    	$y - $arc_size * 2 * $flip);

    # Draw (L3)
    arrow(
            $from_x, $y,
            $from_x + $arc_size * 3, $y);


    $image->string(
	    gdMediumBoldFont,
            $from_x + $child_x + $arc_size * 4,
	    	$y - $arc_size * 2,
            ($cur_node->{min_flag}) ? "*?" : "*",
	    $color_black);


    draw_node_array($cur_node->{children});

    $cur_node->{left_x} = $from_x;
    $cur_node->{left_y} = $y;

    $cur_node->{right_x} = 
    	$from_x + $cur_node->{child_x} +
	$cur_node->{arc_size} * 5;

    $cur_node->{right_y} = $y;
}

############################################
# Branch nodes
############################################
#-------------------------------------------
# draw_branch -- Draw a branch structure
#-------------------------------------------
sub draw_branch($)
{
    # Node we want layout information for
    my $cur_node = shift;

    # Location where we draw the branches
    my $x_loc = $cur_node->{x_loc} + 
    	X_BRANCH_MARGIN;

    my $y_loc = $cur_node->{y_loc};

    foreach my $cur_child (
	    @{$cur_node->{choices}}
	) {
        layout_array(
            $x_loc + X_BRANCH_MARGIN,
            $y_loc,
            $cur_child->[0]->{row_y_size},
            @{$cur_child});

        $y_loc += $cur_child->[0]->{row_y_size} +
		Y_BRANCH_MARGIN;
        draw_node_array($cur_child);
    }

    # Largest right x of any node
    my $max_x = 0;      

    foreach my $cur_child (
		@{$cur_node->{choices}}) {

        # Last node on the string of children
        my $last_node = 
	    $cur_child->[$#{$cur_child}];

        if ($last_node->{right_x} > $max_x) {
            $max_x = $last_node->{right_x};
        }
    }
    foreach my $cur_child (
		@{$cur_node->{choices}}
	    ) {
        # Last node on the 
	# string of children
        my $last_node = 
	     $cur_child->[$#{$cur_child}];

        if ($last_node->{right_x} < $max_x) {
            $image->line(
                    $last_node->{right_x},
		    $last_node->{right_y},
                    $max_x, 
		    $last_node->{right_y},
		    $color_black);
        }
    }

    my $left_x = $cur_node->{x_loc};
    my $right_x = $cur_node->{x_loc} +
    	$cur_node->{x_size} - X_MARGIN;

    my $y = $cur_node->{y_loc} + 
    	($cur_node->{y_size} / 2);

    foreach my $cur_child (
		@{$cur_node->{choices}}
	) {
        # Create a branch line to the item
	# in the list of nodes
        $image->line(
                $left_x, $y,
                $cur_child->[0]->{left_x},
		$cur_child->[0]->{left_y},
		$color_black);

        # The last node on the list
        my $last_child = 
	    $cur_child->[$#$cur_child];

        # Line from the last node 
	# to the collection point
        $image->line(
                $max_x, $last_child->{right_y},
                $right_x, $y,
		$color_black);
    }

    $cur_node->{left_x} = $left_x;
    $cur_node->{left_y} = $y;

    $cur_node->{right_x} = $right_x;
    $cur_node->{right_y} = $y;
}



############################################
# draw a start or end node
############################################
sub draw_start_end($)
{
    my $cur_node = shift;
    my $node_number = $cur_node->{node}->{node};

    filled_rectangle(
            $cur_node->{x_loc}, 
	    $cur_node->{y_loc},
            $cur_node->{x_loc} + X_NODE_SIZE,
            $cur_node->{y_loc} + Y_NODE_SIZE,
            $color_green);

    $cur_node->{text} = $image->string(
	    gdSmallFont,
            $cur_node->{x_loc} + X_TEXT_OFFSET,
            $cur_node->{y_loc} + Y_TEXT_OFFSET,

            $cur_node->{node}->{type},
	    $color_black);

    $cur_node->{left_x} = $cur_node->{x_loc};

    $cur_node->{left_y} =
    	$cur_node->{y_loc} + Y_NODE_SIZE / 2;

    $cur_node->{right_x} = 
    	$cur_node->{x_loc} + X_NODE_SIZE;

    $cur_node->{right_y} =
    	$cur_node->{y_loc} + Y_NODE_SIZE / 2;
}

#-------------------------------------------
# draw_exact($node) -- Draw a "EXACT" re node
#-------------------------------------------
sub draw_exact($)
{
    my $cur_node = shift;       # The node
    my $node_number = $cur_node->{node}->{node};

    filled_rectangle(
            $cur_node->{x_loc}, 
	    $cur_node->{y_loc},
            $cur_node->{x_loc} + 
	    	$cur_node->{x_size} -
	    	X_MARGIN,
            $cur_node->{y_loc} + Y_NODE_SIZE,
            $color_green);

    $image->string(
	    gdSmallFont,
            $cur_node->{x_loc} + X_TEXT_OFFSET,
            $cur_node->{y_loc} + Y_TEXT_OFFSET,
	    "$cur_node->{node}->{type}",
	    $color_black);

    $image->string(
	    gdSmallFont,
            $cur_node->{x_loc} +
	    	X_TEXT_OFFSET + X_LINE2_OFFSET,
            $cur_node->{y_loc} +
	    	Y_TEXT_OFFSET + Y_LINE2_OFFSET,
	    "$cur_node->{node}->{arg}",
	    $color_black);

    $cur_node->{left_x} = $cur_node->{x_loc};

    $cur_node->{left_y} =
    	$cur_node->{y_loc} + Y_NODE_SIZE / 2;

    $cur_node->{right_x} = 
        $cur_node->{x_loc} + X_NODE_SIZE;

    $cur_node->{right_y} =
    	$cur_node->{y_loc} + Y_NODE_SIZE / 2;
}
#-------------------------------------------
# draw_ref($node) -- Draw a "REF" re node
#-------------------------------------------
sub draw_ref($)
{
    my $cur_node = shift;       # The node
    my $node_number = $cur_node->{node}->{node};

    filled_rectangle(
            $cur_node->{x_loc}, 
	    $cur_node->{y_loc},
            $cur_node->{x_loc} + X_NODE_SIZE,
            $cur_node->{y_loc} + Y_NODE_SIZE,
            $color_light_green);

    $cur_node->{text} = $image->String(
	    gdSmallFont,
            $cur_node->{x_loc} + X_TEXT_OFFSET,
            $cur_node->{y_loc} + Y_TEXT_OFFSET,
            "Back Reference:\n".
	    "  $cur_node->{node}->{ref}",
	    $color_black);

    $cur_node->{left_x} = $cur_node->{x_loc};

    $cur_node->{left_y} =
    	$cur_node->{y_loc} + Y_NODE_SIZE / 2;

    $cur_node->{right_x} = 
        $cur_node->{x_loc} + X_NODE_SIZE;

    $cur_node->{right_y} = 
        $cur_node->{y_loc} + Y_NODE_SIZE;
}
#-------------------------------------------
# draw the () stuff
#-------------------------------------------
sub draw_open($$)
{
    my $cur_node = shift;       # The node

    $image->setStyle(
	$color_black, $color_black,
		$color_black, $color_black, 
		$color_black,
	$color_white, $color_white,
		$color_white, $color_white, 
		$color_white
    );
    $image->rectangle(
            $cur_node->{x_loc},
		$cur_node->{y_loc} + 
		BOX_FONT_SIZE,
            $cur_node->{x_loc} +
	    	$cur_node->{x_size} - 
		X_MARGIN,
            $cur_node->{y_loc} + 
	    	$cur_node->{y_size},
            gdStyled);

    $image->string(
	    gdSmallFont,
            $cur_node->{x_loc}, 
	    $cur_node->{y_loc},
            $cur_node->{text},
	    $color_black);

    layout_array(
        $cur_node->{x_loc} + 
		BOX_MARGIN/2,
        $cur_node->{y_loc} + 
		BOX_MARGIN/2 + BOX_FONT_SIZE,
        $cur_node->{y_size} - 
		BOX_MARGIN - BOX_FONT_SIZE,
        @{$cur_node->{children}});

    draw_node_array($cur_node->{children});

    $cur_node->{left_x} = $cur_node->{x_loc};
    $cur_node->{left_y} = $cur_node->{y_loc} +
    	($cur_node->{y_size} + BOX_FONT_SIZE)/2;

    $cur_node->{right_x} = $cur_node->{x_loc} +
    	$cur_node->{x_size} - X_MARGIN;

    $cur_node->{right_y} = $cur_node->{left_y};

    # Child we are drawing arrows to / from
    my $child = $cur_node->{children}->[0];
    $image->line(
            $cur_node->{left_x}, 
	    $cur_node->{left_y},
            $child->{left_x}, 
	    $child->{left_y},
	    $color_black
    );
    $child =
       $cur_node->{children}->[
	   $#{$cur_node->{children}}
       ];

    $image->line(
            $child->{right_x}, 
	    $child->{right_y},
            $cur_node->{right_x}, 
	    $cur_node->{right_y},
	    $color_black
    );
}

my %draw_node = (
    "ANYOF" => \&draw_exact,
    "BOL"   => \&draw_start_end,
    "EOL"   => \&draw_start_end,
    "SPACE"   => \&draw_start_end,
    "NSPACE"   => \&draw_start_end,
    "DIGIT"   => \&draw_start_end,
    "BRANCH"=> \&draw_branch,
    "END"   => \&draw_start_end,
    "EXACT" => \&draw_exact,
    "IFMATCH"  => \&draw_open,
    "OPEN"  => \&draw_open,
    "PLUS"  => \&draw_plus,
    "REF"   => \&draw_ref,
    "REG_ANY" => \&draw_start_end,
    "STAR"  => \&draw_star,
    "Start" => \&draw_start_end,
    "UNLESSM"  => \&draw_open
);

##############################################
# draw_node_array -- draw an array of nodes
##############################################
sub draw_node_array($)
{
    my $array = shift;
    #
    # Draw Nodes
    #
    foreach my $cur_node (@$array) {
        if (not defined(
	    $draw_node{
		$cur_node->{node}->{type}})) {

            die("No draw function for ".
		    "$cur_node->{node}->{type}");
        }
        $draw_node{
	    $cur_node->{node}->{type}}(
		$cur_node
	    );
    }
    #
    # Loop through all the things 
    # (except the last) and
    # draw arrows between them
    #
    for (my $index = 0; 
         $index < $#$array; 
	 ++$index) {

        my $from_x = $array->[$index]->{right_x};
        my $from_y = $array->[$index]->{right_y};

        my $to_x = $array->[$index+1]->{left_x};
        my $to_y = $array->[$index+1]->{left_y};

        arrow(
	    $from_x, $from_y,
	    $to_x, $to_y
        );
    }
}
##############################################
# draw_re -- Draw the image
##############################################
sub draw_re($)
{
    # Formatted expression
    my $format_re = shift;	

    # Background color
    $color_white =
	$image->colorAllocate(255,255,255);
    $color_black = $image->colorAllocate(0,0,0);
    $color_green = $image->colorAllocate(0, 255, 0);
    $color_blue = $image->colorAllocate(0, 0, 255);
    $color_light_green =
	    $image->colorAllocate(0, 128, 0);
    # Draw the top level array
    #	(Which recursively draws 
    #    all the enclosed elements)
    draw_node_array($format_re);
    # Make all the canvas visible
}
