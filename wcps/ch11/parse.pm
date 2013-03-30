#
# parse_re -- Parse a regular exprssion
#
use strict;
use warnings;

package parse;
require Exporter;

use English;

use vars qw/@ISA @EXPORT/;

@ISA = qw/Exporter/;
@EXPORT = qw/parse_re/;

################################################
# parse_re -- Parse a regular expression 
#    and return an array of parsed data
################################################
sub parse_re($)
{
    # The regular expression to use
    my $quote_re = shift;

    $quote_re =~ s/\\/\\\\/g;

    # The command to get the debug output
    my $cmd = <<EOF ;
perl 2>&1 <<SHELL_EOF
use re 'debug';
/$quote_re/;
SHELL_EOF
EOF

    # The raw debug output
    my @raw_debug = `$cmd`;

    if ($main::opt_d) {
        print @raw_debug;
    }

    if ($CHILD_ERROR != 0) {
    my $cmd = <<EOF ;
perl 2>&1 <<SHELL_EOF
use re 'debug';
/ERROR/;
SHELL_EOF
EOF
        @raw_debug = `$cmd`;
        if ($CHILD_ERROR != 0) {
            die("Could not run perl");
        }
    }

    my @re_debug = ();     # The regular expression
    push(@re_debug, {
            node => 0,
            type => "Start",
            next => 1
            });
    foreach my $cur_line (@raw_debug) {
        if ($cur_line =~ /^Compiling/) {
            next;
        }
        if ($cur_line =~ /^\s*size/) {
            next;
        }
        #                 +++---------------------------------- Spaces
        #                 ||| +++------------------------------ Digits
        #                 |||+|||+----------------------------- Group $1
        #                 ||||||||                              (Node)
        #                 ||||||||
        #                 ||||||||+---------------------------- Colon
        #                 |||||||||+++------------------------- Spaces
        #                 ||||||||||||
        #                 |||||||||||| +++--------------------- Word chars
        #                 ||||||||||||+|||+-------------------- Group $2
        #                 |||||||||||||||||                       (Type)
        #                 |||||||||||||||||
        #                 |||||||||||||||||+++----------------- Spaces
        #                 ||||||||||||||||||||
        #                 |||||||||||||||||||| ++--------------- Any char str
        #                 ||||||||||||||||||||+||+-------------- Group $3
        #                 ||||||||||||||||||||||||               (arg)
        #                 ||||||||||||||||||||||||------------- Lit <>
        #                 ||||||||||||||||||||||||
        #                 ||||||||||||||||||||||||+++---------- Spaces
        #                 |||||||||||||||||||||||||||
        #                 |||||||||||||||||||||||||||   ++----- Any char str
        #                 |||||||||||||||||||||||||||++ || ++-- Lit ()
        #                 ||||||||||||||||||||||||||||| || ||   (next state)
        #                 |||||||||||||||||||||||||||||+||+||-- Group $4
        if ($cur_line =~ /\s*(\d+):\s*(\w+)\s*(.*)\s*\((.*)\)/) {
            push(@re_debug, {
                    node => $1,
                    type => $2,
                    raw_type => $2,
                    arg => $3,
                    next => $4
                    });
            next;
        }
        if ($cur_line =~ /^anchored/) {
            next;
        }
        if ($cur_line =~ /^Freeing/) {
            last;
        }
    }
    return (@re_debug);
}
