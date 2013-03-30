#!/usr/bin/perl
#
# re_graph.pl -- Graph a regular expression
#
=pod

=head1 NAME

re_graph.pl - Graph regular expression

=head1 SYNOPSIS

B<re_graph.pl> 
[B<-d>] 
[B<-o> I<output>] 
[B<-x> I<x-size>]
[B<-y> I<x-size>]
I<regular expression>
[I<string>] 

=head1 DESCRIPTION

The I<re_graph.pl> program graphs regular expressions.  The guts of the 
regular expression engine is a simple state machine.  The various states
and operations in the regular expression parser can be displayed using a 
surprisingly simple diagram.

A few notes on what you are looking at: 

The nodes B<Start> and B<Stop> denote the beginning and end of the regular
expression.  

The solid squares denote atoms.   Lines indicate the next state.
When a line splits, the state machine will take the top line first.
If it's path is blocked it will backup and take the next lower line.
This is repeated until it finds a path to the end or all paths are exhausted.

Brown boxes indicate a grouping operation, i.e. ().  

Green boxes indicate a zero with test.  The state machine will perform the 
test inside the box before moving ahead.

For more information, see the tutorial below.

=head1 OPTIONS

=over 4

=item B<-d>

Turn on debugging.  The debugging output is printed on the console as regular
expressions are compiled.

=item B<-o>I<file>

Specify the output file.  If a regular expression and a string are specified then
there will be one file output for each step in the execution of the match.
In that case the I<file> parameter is a B<printf> style string used to generate
a series of files.  A '%d' link specification should be used to specify the
output file naming template.

Default: re_graph_%02d.png.

=item B<x>I<x-size>

Specify the minimum size of the resulting graphic in the X direction.

=item B<y>I<y-size>

Specify the minimum size of the resulting graphic in the Y direction.

=back

Note: If no regular expressions are specified, a list consisting of the
items in the tutorial is loaded.

=head1 GUI CONTROLS

=over 4 

=item B<Next>

Displays the next regular expression in the list.

=item B<Previous>

Displays the previous regular expression in the list.

=item I<Regular Expression Blank>

This blank contains the regular expression being graphed.

=item B<List>

Pops up a window containing a list of expressions.  You can select an 
expression from this list and press B<OK> to graph it.  You can also
input a regular expression in the blank at the bottom of the window 
and press B<New> to add it to the list.

=item B<Exit>

Exits the program.

=item B<Print>

If it worked, it would print the current graph.  But since it is broken
it won't even show up unless you put the B<-P> switch on the command line.

When pressed it creates a file called I<tmp.ps> which should contain a 
postscript version of your graph.   (It has a few problems that prevent the
output from being what you want.)

=back

=head1 TUTORIAL

This tutorial shows what happens when a set of sample regular expressions
are graphed.  This set of regular expressions closely follows the
Chapter 4 of "Perl for C Programmers" by Steve Oualline.

The set of regular expressions used for this tutorial is:

    test
    ^Test
    ^ *#
    ^[ \t]*#
    ^\s*#
    ([^#]*)(#.*)
    a|b
    ^(([^#"]*|".*")*)(#.*)
    ^((?:[^#"]*|".*?")*)(#.*)
    ^((?:[^#"]*|".*?(?<!\\)")*)(#.*)

Let's take a look at the graphs produced by these expressions.

=over 4

=item B</test/>

This is a very simple expression.  It matches "test" anywhere on the line.
If you look at the graph of this expression, it consists of three nodes "Start",
"EXACT <test>" and "END".   

The "Start" node indicates the start of the regular expression.  

The "EXACT <test>" node tells the engine that the text must match the
text "test" exactly.   

The "END" node indicates the end of the regular expression.  If you reach
the "END" node, a successful match was found.

Flow is a straight line from "Start", through the "EXACT" check, to end.

=item B</^Test/>

A new item was added with this expression, an anchor.  It's named BOL 
(Beginning of line) and shows up as an additional node.

=item B</^ *#/>

Now we start having fun.  This expression matches anything that consists
of a start of line (^), a bunch of spaces ( *), and a sharp (#).

The way the state machine works it that it starts at "Start" and works
it's way through the nodes.  You'll notice that between "BOL" and
"EXACT < >" there's a fork in the road.  

The state machine will take the top branch if possible.  So if the next
character is a space, the system will take the top branch and match the
"EXACT < >" node.  If not, the bottom branch is taken and we wind up
at the "EXACT <#>" node. 

If there's no path to the "END", then we don't have a match.

=item B</^[ \t]*#/>

This is the same as the previous example, except the space was replaced
by a character set.  We call the set "space and tab".  The system translates
this into "\11\40".  It's the same thing, suitable obfuscated for computer
work.

=item B</^\s*#/>

Again, the middle as been replace by another token.  In this case it's 
the SPACE token which matches any whitespace.

=item B</([^#]*)(#.*)/>

This expression introduces us to the grouping operators.  They show as the 
big brown boxes.

The other change is that we use the expression [^#], which matches anything
except a hash mark.  Perl changes this to a "ANYOF" clauses which matches
all characters except the single one we don't want.  

Note: This ANYOF node overflows the size of the box.  This is a know bug.

=item B</a|b/>

Now we introduce the concept of a selection of two different atoms.  Note that
the branch arrows are drawn smaller to make them stand out.

=item B</^(([^#"]*|".*")*)(#.*)/>

See the book for what this regular expression tries to match.

This expression adds nested grouping, and some additional stuff that we've seen
before.

=item B</^((?:[^#"]*|".*?")*)(#.*)/>

This is like the previous example, except what was the $2 grouping has been
replaced by the "Group no $" operator (?:...).  Notice that the line around
the second group has disappeared and what was $3 is now $2.

(In future versions of this graphing tool we will graph the invisible group
operator.  We just did figure out how to do it yet.)

Also notice the use of the "*?" operator.  Remember when going through
the nodes, when a branch is encountered, the system will try and take
the top one first.


=item B</^((?:[^#"]*|".*?(?<!\\)")*)(#.*)/>

The grand finale.  One new type of node has been introduced: (?<!\\).  This is 
the negative look-behind.  It's the red box on the screen.  When the state machine
sees this, it matches the text behind the current location marker against the
indicated text and if it fails then a match against the next node is possible.
(Boy does this not translate into English well.)

Basically the clause in question looks for a double quoted string ("xxx"), but
will ignore a double quote it's escaped ("xxx\"yyy").

=back

=head1 BUGS / LIMITATIONS

This will not graph all the regular expressions.  Some of the more advanced
features of the engine are just not handled.

We currently "graph" the "group, no $1" (?:..) operator by displaying nothing.
A box should be put around the expression.

Better use of color can be made.   Specifically all the nodes do not
have to be green.  Come to think of it they call don't have to be
rectangles either.

Sometimes the lines connecting one section to another take some strange
twists.

=head1 LICENSE

Licensed under the GPL.  (See the end of the source file for a copy).

=head1 AUTHOR

Steve Oualline (oualline@www.oualline.com)

=cut
use strict;
use warnings;

use IO::Handle;
use English;
use GD;
use GD::Arrow;

use parse;
use size;
use draw;

# Label location 
use constant LABEL_LOC_X => 50;	
use constant LABEL_LOC_Y => 50;	

# Location of progress msg
use constant PROGRESS_X => 50;	
use constant PROGRESS_Y => 70;	

# Length of the yellow arrow
use constant YELLOW_ARROW_SIZE => 25;
use constant YELLOW_ARROW_WIDTH => 5;

use Getopt::Std;

use vars qw/$opt_d $opt_o $opt_x $opt_y/;

STDOUT->autoflush(1);

# Configuration items
my $x_margin = 16;	# Space between items
my $y_margin = 16;	# Space between items

#
# Fields
#       node    -- Node number
#       type    -- Node type (from re debug)
#       arg     -- Argument (optional)
#       next    -- Next node
#

#
# Fields
#       x_size    - Size of the node in X
#       y_size    - Size of the node in Y
#       x_loc     - X Location of the node
#       y_loc     - Y Location of the node
#       node      - Reference to the 
#			node in @re_debug
#       child     - Array of child 
#			nodes for this node
#

# Re we are displaying now
my $current_re;         

my $re_to_add = "";     # Re we are adding


################################################
# usage -- Tell the user how to use us
################################################
sub usage()
{
    print STDERR <<EOF;
Usage is $0 [options] [-o <file>] <re> [<str>]
Options: 
  -d -- Debug
  -x <size> -- Minimum size in X
  -y <size> -- Minimum size in Y
EOF
    exit (8);
}


##############################################
# find_node($state, $node_array) -- Find a node
#	the parsed node tree
#
# Returns the location of the node
##############################################
sub find_node($$);
sub find_node($$)
{
    # State (node number) to find
    my $state = shift;	

    my $array = shift;	# The array to search

    foreach my $cur_node (@$array) {
	if ($cur_node->{node}->{node} == 
		$state) {

	    return ($cur_node->{x_loc}, 
	            $cur_node->{y_loc});

	}
	if (defined($cur_node->{children})) {
	    # Get the x,y to return from
	    # 	the children
	    my ($ret_x, $ret_y) =
	        find_node(
		    $state, 
		    $cur_node->{children});

	    if (defined($ret_x)) {
		return ($ret_x, $ret_y);
	    }
	}
	if (defined($cur_node->{choices})) {
	    my $choices = $cur_node->{choices};
	    foreach my $cur_choice (@$choices) {
		# Get the x,y to return from the
		# 	choice list
		my ($ret_x, $ret_y) =
		    find_node(
			$state, $cur_choice);

		if (defined($ret_x)) {
		    return ($ret_x, $ret_y);
		}
	    }
	}
    }
    return (undef, undef);
}
##############################################
# draw_progress($cur_line, $page)
#
# Draw a progress page
#
# Returns true if the page was drawn
##############################################
sub draw_progress($$$)
{
    my $value = shift;	 # Value to check
    my $cur_line = shift;# Line we are processing
    my $page = shift;    # Page number

    # Check to see if this 
    # is one of the progress lines
    if (substr($cur_line, 26, 1) ne '|') {
	return (0);	# Not a good line
    }
    # Line containing the progress number
    # from the debug output
    my $progress_line = substr($cur_line, 0, 24);

    # Location of the current state information
    my $state_line = substr($cur_line, 27);

    # Extract progress number
    $progress_line =~ /^\s*(\d+)/;
    my $progress = $1;

    # Extract state number
    $state_line =~ /^\s*(\d+)/;
    my $state = $1;

    # Find the location of this node
    # on the graph
    my ($x_location, $y_location) =
	find_node($state, \@format_re);

    if ($opt_d) {
	if (defined($x_location)) {
	    print
		"node $state ".
		"($x_location, $y_location)\n";
	} else {
	    print "node $state not found\n";
	}
    }
    # If the node is not graphable,
    # skip this step
    if (not defined($x_location)) {
	return (0);
    }
    # Create a new image with arrow
    my $new_image =
	GD::Image->newFromPngData(
	    $image->png(0));

    # Create the arrow
    my $arrow = GD::Arrow::Full->new(
	-X1 => $x_location,
	-Y1 => $y_location,
	-X2 => $x_location - YELLOW_ARROW_SIZE,
	-Y2 => $y_location - YELLOW_ARROW_SIZE,
	-WIDTH => YELLOW_ARROW_WIDTH
    );

    $new_image->setThickness(1);

    # Create some colors for
    # the new image
    my $new_color_yellow =
	$new_image->colorAllocate(255, 255, 0);

    my $new_color_black =
	$new_image->colorAllocate(0,0,0);

    # Make the arrow point
    # to the current step
    $new_image->filledPolygon(
	$arrow, $new_color_yellow);

    $new_image->polygon(
	$arrow, $new_color_black);

    # Get the size of the font we are using
    my $char_width = gdGiantFont->width;
    my $char_height = gdGiantFont->height;

    $new_image->filledRectangle(
	PROGRESS_X, PROGRESS_Y,
	PROGRESS_X +
	$progress * $char_width,
	PROGRESS_Y + $char_height,
	$new_color_yellow
    );

    $new_image->string(gdGiantFont,
	PROGRESS_X, PROGRESS_Y,
	$value, $new_color_black);

    # Generate the output file name
    my $out_file =
    sprintf($opt_o, $page);

    open OUT_FILE, ">$out_file" or
    die("Could not open output".
    "file: $out_file");

    binmode OUT_FILE;
    print OUT_FILE $new_image->png(0);
    close OUT_FILE;
    return (1);
}
##############################################
# chart_progress -- Chart the progress of the
#	execution of the RE
##############################################
sub chart_progress()
{
    my $value = $ARGV[0];	# Value to check

    # Value with ' quoted
    my $quote_value = $value;	
    $quote_value =~ s/'/\\'/g;

    # Regular expression 
    my $quote_re = $current_re;
    $quote_re =~ s/\\/\\\\/g;

    my $cmd = <<EOF ;
perl 2>&1 <<SHELL_EOF
use re 'debug';
'$quote_value' =~ /$quote_re/;
SHELL_EOF
EOF

    # The raw debug output
    my @raw_debug = `$cmd`;

    # Go do to the part when the matching starts
    while (($#raw_debug > 0) and
	($raw_debug[0] !~ /^Matching/)) {
	shift(@raw_debug);
    }
    shift(@raw_debug);

    my $page = 1;	# Current output page

    foreach my $cur_line (@raw_debug) {
	# Skip other lines
	if (length($cur_line) < 27) {
	    next;
	}
	if (draw_progress($value, 
		$cur_line, $page)) {
	    ++$page;
	}
    }
}


# -d	-- Print RE debug output and draw output
# -o file -- specify output file (template)
# -x <min-x>
# -y <min-y>
my $status = getopts("df:o:x:y:");
if ($status == 0)
{
    usage();
}

if (not defined($opt_o)) {
    $opt_o = "re_graph_%02d.png";
}

if ($#ARGV == -1) {
    usage();
}
$current_re = shift(@ARGV);

# Compute the regular expression debug information
my @re_debug = parse_re($current_re);

# Conver the data and get the size of the new node
my ($x_size, $y_size) = convert_re(\@re_debug);
$x_size += MARGIN;
$y_size += MARGIN;
if (defined($opt_x)) {
    if ($opt_x > $x_size) {
	$x_size = $opt_x;
    }
}
if (defined($opt_y)) {
    if ($opt_y > $y_size) {
	$y_size = $opt_y;
    }
}

$image = GD::Image->new($x_size, $y_size);

draw_re(\@format_re);

$image->string(gdGiantFont,
    LABEL_LOC_X, LABEL_LOC_Y,
    "Regular Expression: /$current_re/", 
    $color_black);

my $out_file = sprintf($opt_o, 0);
open OUT_FILE, ">$out_file" or
    die("Could not open output file: $out_file");

binmode OUT_FILE;
print OUT_FILE $image->png(0);
close OUT_FILE;

if ($#ARGV != -1) {
    chart_progress();
}
