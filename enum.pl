#!/usr/bin/perl
=pod

=head1 NAME

enum.pl - Print out C code to define an enum and printable version of the same

=head1 SYNOPSIS

    enum.pl I<in-file.txt>
	
=head1 DESCRIPTION

The I<enum.pl> reads a set of enumeration values from from a file
and outputs a C B<enum> declaration and a list of strings
called B<enum_to_string> which translates that enum to a string.

=head1 EXAMPLES

=head2 INPUT FILE

File I<names.txt>

    SAM
    JOE
    MAC

=head2 COMMAND

   enum.pl names.txt

=head2 OUTPUT FILE

    enum NAMES {
	SAM,
	JOE,
	MAC,
    };
    static const char* const names_to_string[] = {
	"SAM",
	"JOE",
	"MAC",
    }

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
use strict;
use warnings;

if ($#ARGV != 0) {
    print STDERR "Usage is $0 <input file>\n";
    exit (8);
}

$ARGV[0] =~ /^([^\.]*)/;
my $enum = $1;
my $ENUM = $enum;
$ENUM =~ tr [a-z] [A-Z];

my @words = <>;
chomp(@words);


print "enum $ENUM {\n";
foreach my $cur_word (@words) {
    print "    $cur_word,\n";
}
print "};\n";

print <<EOF;
static const char* const ${enum}_to_string[] = {
EOF
foreach my $cur_word (@words) {
    print "    \"$cur_word\",\n";
}
print "}\n";

