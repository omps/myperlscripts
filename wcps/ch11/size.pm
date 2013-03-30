use strict;
use warnings;

package size;
require Exporter;

use vars qw/@ISA @EXPORT @format_re/;

@ISA = qw/Exporter/;
@EXPORT = qw/convert_re &BOX_FONT_SIZE &BOX_MARGIN
  &X_CHAR_SIZE &X_MARGIN &Y_NODE_SIZE
  &X_MARGIN &Y_MARGIN &MARGIN
  &X_NODE_SIZE Y_NODE_SIZE
  &X_BRANCH_MARGIN &Y_BRANCH_MARGIN
  &X_TEXT_OFFSET &Y_TEXT_OFFSET
  @format_re layout_array/;

#
# Constants that control the layout
#
# Margin around the graph
use constant MARGIN => 100;	

# Size of a node (X Space)
use constant X_NODE_SIZE => 60;   

# Size of a node (Y Space)
use constant Y_NODE_SIZE => 40;   
#-------------------------------------------
# layout the "ANYOF" node  (ANYOF + text)
#-------------------------------------------
# Size of a character in X dimensions
use constant X_CHAR_SIZE => 7;

#-------------------------------------------
# OPEN  the open (
#-------------------------------------------
# Size of the box around a group
use constant BOX_MARGIN => 50;

# Height of the font used to label boxes
use constant BOX_FONT_SIZE => 15;

# Space between nodes (X)
use constant X_MARGIN => 50;      

# Vertical spacing
use constant Y_MARGIN => 10;      

# Padding for PLUS style nodes (left, right)
use constant PLUS_PAD => 10;

# Space between branches (x)
use constant X_BRANCH_MARGIN => 20;

# Space between branches (y)
use constant Y_BRANCH_MARGIN => 20;

# Space text over this far
use constant X_TEXT_OFFSET => 3;  
use constant Y_TEXT_OFFSET => 3;  

# The regular expression debugging information
my $re_debug;	

sub size_array(\@);
########################################
# size_text -- Compute the size of a 
#	text type node
########################################
sub size_text($)
{
    # Node we want layout information for
    my $node = shift;

    # Get the size of the string argument
    my $length = length($node->{node}->{arg});
    if ($length < 10) {
	$length = 10;
    }
    $node->{x_size} = 
    	$length * X_CHAR_SIZE + X_MARGIN;

    $node->{y_size} = Y_NODE_SIZE;
}
############################################
# size_start -- Layout a start node
############################################
sub size_start($)
{
    # Node we want layout information for
    my $node = shift;

    $node->{x_size} = X_NODE_SIZE + X_MARGIN;
    $node->{y_size} = Y_NODE_SIZE;
}
#-------------------------------------------
# layout the end node
#-------------------------------------------
sub size_end($)
{
    # Node we want layout information for
    my $node = shift;

    $node->{x_size} = X_NODE_SIZE;
    $node->{y_size} = Y_NODE_SIZE;
}
#-------------------------------------------
# layout the "EXACT" node  (EXACT + text)
#-------------------------------------------
sub size_exact($)
{
    # Node we want layout information for
    my $node = shift;

    $node->{x_size} = X_NODE_SIZE + X_MARGIN;
    $node->{y_size} = Y_NODE_SIZE;
}

################################################
# size_open -- Size the open ( -- Actually
#	the entire (....) expression
################################################
sub size_open($)
{
    # The node we want to size
    my $node = shift;   

    # Compute the size of the children
    my ($x_size, $y_size) =
    	size_array(@{$node->{children}});

    # We add X_MARGIN because we 
    # must for all nodes
    #
    # We subtract X_MARGIN because one too many
    # is added in our children
    #
    # Result is nothing

    $node->{x_size} = $x_size + BOX_MARGIN;

    $node->{y_size} = 
        $y_size + BOX_MARGIN + BOX_FONT_SIZE;
}
#------------------------------------------
# size_plus -- Compute the size of 
#		a plus/star type node
#------------------------------------------
sub size_plus($)
{
    # Node we want layout information for
    my $node = shift;

    # Compute the size of the children
    my ($x_size, $y_size) =
    	size_array(@{$node->{children}});

    # Arc size is based on the 
    # Y dimension of the children
    $node->{arc_size} = 
    	int($y_size/4) + PLUS_PAD;

    $node->{child_x} = $x_size - X_MARGIN;

    $node->{x_size} = 
        $node->{child_x} +
	$node->{arc_size} * 2 + X_MARGIN;

    $node->{y_size} = 
        $y_size + $node->{arc_size} * 2;
}
#-----------------------------------------
# size_star -- Compute the size of 
#	a star type node
#-----------------------------------------
sub size_star($)
{
    # Node we want layout information for
    my $node = shift;

    # Compute the size of the children
    my ($x_size, $y_size) =
    	size_array(@{$node->{children}});

    # Arc size is based on the 
    # Y dimension of the children
    $node->{arc_size} = 
	int($y_size/4) + PLUS_PAD;

    $node->{child_x} = $x_size - X_MARGIN;

    $node->{x_size} = $node->{child_x} +
    	$node->{arc_size} * 5 + X_MARGIN;

    $node->{y_size} = $y_size +
    	$node->{arc_size} * 2 + Y_MARGIN;
}
#-------------------------------------------
# layout a branch node
#-------------------------------------------
sub size_branch($)
{
    # Node we want layout information for
    my $node = shift;

    my $x_size = 0;     # Current X size
    my $y_size = 0;     # Current Y size

    foreach my $cur_choice (
		@{$node->{choices}}) {

        # The size of the current choice
        my ($x_choice, $y_choice) =
		size_array(@{$cur_choice});

        if ($x_size < $x_choice) {
            $x_size = $x_choice;
        }
        if ($y_size != 0) {
            $y_size += Y_BRANCH_MARGIN;
        }
        $cur_choice->[0]->{row_y_size} = 
		$y_choice;

        $y_size += $y_choice;
    }
    $x_size += 2 * X_BRANCH_MARGIN + X_MARGIN;
    $node->{x_size} = $x_size;
    $node->{y_size} = $y_size;
}
# Functions used to compute the sizes 
# of various elements
my %compute_size = (
    "ANYOF" => \&size_text,
    "BOL" => \&size_exact,
    "SPACE" => \&size_exact,
    "NSPACE" => \&size_exact,
    "DIGIT" => \&size_exact,
    "BRANCH"=> \&size_branch,
    "END"   => \&size_end,
    "EOL" => \&size_exact,
    "EXACT" => \&size_exact,
    "IFMATCH"  => \&size_open,
    "OPEN"  => \&size_open,
    "PLUS"  => \&size_plus,
    "REF"   => \&size_exact,
    "REG_ANY" => \&size_exact,
    "STAR"  => \&size_star,
    "Start" => \&size_start,
    "UNLESSM"  => \&size_open
);
################################################
# do_size($cur_node) -- 
#	Compute the size of a given node
################################################
sub do_size($);
sub do_size($)
{
    my $cur_node = shift;

    if (not defined(
	    $compute_size{
		$cur_node->{node}->{type}})) {

        die("No compute function for ".
	    	"$cur_node->{node}->{type}");
        exit;
    }
    $compute_size{
	$cur_node->{node}->{type}}($cur_node);
}
################################################
# $new_index = parse_node($index, 
#		$array, $next, $close)
#
#       -- Parse a single regular expression node
#       -- Stop when next (or end) is found
#       -- Or when a close ")" is found
################################################
sub parse_node($$$$);
sub parse_node($$$$)
{
    # Index into the array
    my $index = shift;          

    # Array to put things on
    my $array = shift;          

    my $next = shift;           # Next node

    # Looking for a close?
    my $close = shift;          

    my $min_flag = 0;           # Minimize flag
    while (1) {
        if (not defined($re_debug->[$index])) {
            return ($index);
        }
        if (defined($next)) {
            if ($next <= 
	    	$re_debug->[$index]->{node}) {

                return ($index);
            }
        }
        if ($re_debug->[$index]->{type} =~ 
		/CLOSE(\d+)/) {
            if (defined($close)) {
                if ($1 == $close) {
                    return ($index + 1);
                }
            }
        }
        if ($re_debug->[$index]->{type} eq 
		"MINMOD") {
            $min_flag = 1;
            $index++;
            next;
        }
#--------------------------------------------
        if (($re_debug->[$index]->{type} eq 
		"IFMATCH") ||
            ($re_debug->[$index]->{type} eq 
	    	"UNLESSM")) {
            if ($re_debug->[$index]->{arg} !~ 
	    	/\[(.*?)\]/) {
                die("IFMATCH/UNLESSM funny ".
		     "argument ".
		     "$re_debug->[$index]->{arg}");
            }
	    # Ending text (= or !=)
            my $equal = "!=";   

            if ($re_debug->[$index]->{type} eq 
		    "IFMATCH") {
                $equal = "=";
            }
            # Flag indicating the next look ahead
            my $flag = $1;

	    # Text to label this box
            my $text;           

            if ($flag eq "-0") {
                $text = "$equal ahead";
            } elsif ($flag eq "-0") {
                $text = "$equal behind";
            } elsif ($flag eq "-1") {
                $text = "$equal behind";
            } else {
                die("Unknown IFMATCH/UNLESSM ".
		    	"flag text $flag");
                exit;
            }
            push(@{$array}, {
		node => $re_debug->[$index],
		text => $text,
	        children => []
	    });

            $index = parse_node($index+1,
		$$array[$#$array]->{children},
		$re_debug->[$index]->{next}, 
		undef);
            next;
        }
#-----------------------------------------
        if ($re_debug->[$index]->{type} =~ 
		/OPEN(\d+)/) {

            my $paren_count = $1;
            $re_debug->[$index]->{type} = "OPEN";
            push(@{$array}, {
		node => $re_debug->[$index],
		paren_count => $paren_count,
		text => "( ) => \$$paren_count",
	       children => []
	   });

            $index = parse_node($index+1,
		$$array[$#$array]->{children},
		undef, $paren_count);
            next;
        }
#-----------------------------------------
        if ($re_debug->[$index]->{type} =~ 
		/REF(\d+)/) {

            my $ref_number = $1;
            $re_debug->[$index]->{type} = "REF";
            push(@{$array}, {
		node => $re_debug->[$index],
		ref => $ref_number,
	       children => []
	   });

            ++$index;
            next;
        }
#-----------------------------------------
        if ($re_debug->[$index]->{type} eq 
	        "BRANCH") {

            push(@{$array}, {
		node => $re_debug->[$index],
	       choices => []
	    });

            my $choice_index = 0;
            while (1) {
                # Next node in this series
                my $next = 
		    $re_debug->[$index]->{next};

                $$array[$#$array]->
		   {choices}[$choice_index] = [];

                $index = parse_node($index+1,
		    $$array[$#$array]->
		    	{choices}[$choice_index],
		    $next, undef);

                if (not defined(
			  $re_debug->[$index])) {
                    last;
                }

                if ($re_debug->[$index]->{type} ne 
			"BRANCH") {
                    last;
                }
                $choice_index++;
            }
            next;
        }
#--------------------------------------------
        if (($re_debug->[$index]->{type} eq 
	        "CURLYX") |
	    ($re_debug->[$index]->{type} eq 
	        "CURLY")) {

	    # Min number of matches
            my $min_number;     

	    # Max number of matches
            my $max_number;     

            if ($re_debug->[$index]->{arg} =~
			/{(\d+),(\d+)}/) {
                $min_number = $1;
                $max_number = $2;
            } else {
                die("Funny CURLYX args ".
		    "$re_debug->[$index]->{arg}");
                exit;
            }

	    my $star_flag = ($min_number == 0);

	    my $text = "+";
	    if ($min_number == 0) {
		$text = "*";
	    }
	    if (($max_number != 32767) ||
			($min_number > 1)) {

		$text = 
		    "{$min_number, $max_number}";
		if ($max_number == 32767) {
		    $text = "min($min_number)";
		}
	    }
	    # Node that's enclosed 
	    # inside this one
	    my $child = {
		node => {
		    type => 
		       ($star_flag) ? 
		       	 "STAR" : "PLUS",
		    raw_type => 
		       $re_debug->[$index]->{type},
		    arg => 
		        $re_debug->[$index]->{arg},
		    next =>
		       $re_debug->[$index]->{next},
		    text_label => 
		        $text
		},
		min_flag => $min_flag,
		children => [],
	    };

	    push(@{$array}, $child);

	    $index = parse_node($index+1,
		    $child->{children},
		    $re_debug->[$index]->{next}, 
		    undef);
	    next;
        }
#-----------------------------------------
        if (($re_debug->[$index]->{type} eq "CURLYM") ||
            ($re_debug->[$index]->{type} eq "CURLYN")) {

            my $paren_count;    # () number

	    # Min number of matches
            my $min_number;     

	    # Max number of matches
            my $max_number;     

            if ($re_debug->[$index]->{arg} =~
		  /\[(\d+)\]\s*{(\d+),(\d+)}/) {
                $paren_count = $1;
                $min_number = $2;
                $max_number = $3;
            } else {
                die("Funny CURLYM args ".
		    "$re_debug->[$index]->{arg}");
                exit;
            }
	    # Are we doing a * or +
	    # (anything else is just too hard_

	    my $star_flag = ($min_number == 0);

	    # The text for labeling this node
	    my $text = "+";
	    if ($min_number == 0) {
		$text = "*";
	    }
	    if (($max_number != 32767) ||
			($min_number > 1)) {

		$text = 
		   "{$min_number, $max_number}";

		if ($max_number == 32767) {
		    $text = "min($min_number)";
		}
	    }

	    # Node that's enclosed 
	    # inside this one
	    my $child = {
		node => {
		    type => 
		        ($star_flag) ? 
			    "STAR" : "PLUS",
		    raw_type => 
		       $re_debug->[$index]->{type},
		    arg => 
		        $re_debug->[$index]->{arg},
		    next => 
		       $re_debug->[$index]->{next},
		    text_label => 
		        $text
		},
		min_flag => $min_flag,
		children => [],
	    };
	    $min_flag = 0;

	    # The text for labeling this node
	    $text = "( ) => \$$paren_count";
	    if ($paren_count == 0) {
		$text = '( ) [no $x]';
	    }
	    push(@{$array},
	    {
		node => {
		    type => 
		        "OPEN",
		    raw_type => 
		       $re_debug->[$index]->{type},
		    arg => 
		        $re_debug->[$index]->{arg},
		    next => 
		        $re_debug->[$index]->{next}
		},
		paren_count => $paren_count,
		text => $text,
		children => [$child]
	    });

	    $index = parse_node($index+1,
		    $child->{children},
		    $re_debug->[$index]->{next}, 
		    undef);
	    next;
        }
#-----------------------------------------
        if ($re_debug->[$index]->{type} eq 
		"STAR") {
            push(@{$array},
		{
		    node => {
			%{$re_debug->[$index]},
			-text_label => "+"
		   },
		   min_flag => $min_flag,
		   children => []
	       });
            $min_flag = 0;

	    # Where we go for the next state
            my $star_next;

            if (defined($next)) {
                $star_next = $next;
            } else {
                $star_next = 
		    $re_debug->[$index]->{next};
            }

            $index = parse_node($index+1,
		$$array[$#$array]->{children},
		$star_next, undef);
            next;
        }
#-----------------------------------------
        if ($re_debug->[$index]->{type} eq 
		"PLUS") {
            push(@{$array},
		{
		    node => {
			%{$re_debug->[$index]},
			text_label => "+"
		    },
		    min_flag => $min_flag,
		    children => []
	       });
            $min_flag = 0;
            $index = parse_node($index+1,
		$$array[$#$array]->{children},
		$re_debug->[$index]->{next}, 
		undef);
            next;
        }
#-----------------------------------------
        # Ignore a couple of nodes
        if ($re_debug->[$index]->{type} eq 
		"WHILEM") {
            ++$index;
            next;
        }
        if ($re_debug->[$index]->{type} eq 
		"SUCCEED") {
            ++$index;
            next;
        }
        if ($re_debug->[$index]->{type} eq 
		"NOTHING") {
            ++$index;
            next;
        }
        if ($re_debug->[$index]->{type} eq 
		"TAIL") {
            ++$index;
            next;
        }
        push(@$array, {
	    node => $re_debug->[$index]});

        if ($re_debug->[$index]->{type} eq "END") {
            return ($index+1);
        }
        $index++;

    }
}

################################################
# size_array(\@array) -- Compute the size of
#			an array of nodes
#
# Returns
#       (x_size, y_size) -- Size of the elements
#
#       x_size -- Size of all the elements in X
#               (We assume they are 
#			laid out in a line)
#       y_size -- Biggest Y size 
#			(side by side layout)
#################################################
sub size_array(\@)
{
    # The array
    my $re_array = shift;       

    # Size of the array in X
    my $x_size = 0;             

    # Size of the elements in Y
    my $y_size = 0;             

    foreach my $cur_node(@$re_array) {
        do_size($cur_node);
        $x_size += $cur_node->{x_size};
        if ($y_size < $cur_node->{y_size}) {
            $y_size = $cur_node->{y_size};
        }
    }
    return ($x_size, $y_size);
}
################################################
# layout_array($x_start, $y_start, 
#	$y_max, \@array)
#
# Layout an array of nodes
################################################
sub layout_array($$$\@)
{
    # Starting point in X
    my $x_start = shift;        

    # Starting point in Y
    my $y_start = shift;        

    # largest Y value
    my $y_max = shift;          

    # The data
    my $re_array = shift;       

    foreach my $cur_node (@$re_array) {
        $cur_node->{x_loc} = $x_start;
        $cur_node->{y_loc} = $y_start +
	    int(($y_max - 
	         $cur_node->{y_size})/2);
        $x_start += $cur_node->{x_size};
    }
}

################################################
# convert_re -- Convert @re_debug -> @format_re
#
# The formatted re node contains layout 
# information as well as information on 
# nodes contained 
# inside the current one.
################################################
sub convert_re($)
{
    # The regular expression information
    $re_debug = shift;

    # Clear out old data
    @format_re = ();

    parse_node(0, \@format_re, undef, undef);
    #
    # Compute sizes of each node
    #
    my ($x_size, $y_size) = 
    	size_array(@format_re);

    #
    # Compute the location of each node
    #
    layout_array(MARGIN, 
	MARGIN, $y_size, 
	@format_re
    );
    return (MARGIN + $x_size, MARGIN + $y_size);
}

