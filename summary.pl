#!/usr/bin/perl
=pod

=head1 NAME

summary.pl - Print a summary of the apache logs

=head1 SYNOPSIS

    summary.pl <file> [<file> ...]

=head1 DESCRIPTION

The I<summary.pl> reads the Apache access logs and prints a summary 
of the information in them.


=head1 EXAMPLES

        summary.pl /var/log/httpd/access*
	Top hosts accessing the system
	Hits    Who
	4458    207.46.98.144
	1745    64.242.88.50
	1648    128.194.135.83
	1362    210.173.179.39
	1318    200.55.147.70
	1054    209.218.171.51
	794     193.22.65.1
	725     207.68.146.56
	688     65.214.44.161
	672     210.173.179.68
	Top URLs accessed
	Hits    What
	23276   /vim-cook.html
	9170    /robots.txt
	7579    /style/index.html
	6036    /
	5815    /style/
	3599    /style/styleTOC.pdf
	3335    /style/c01.pdf
	3045    /sw/index.html
	2774    /style/c02.pdf
	2759    /style/c07.pdf


=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
#
# summary.pl -- Print a summary of the apache logs.
#
# Summary includes top urls accessed
#	and the top people who accessed the site (by access)
#
# Usage:
#	summary.pl <access_log> [<access_log> ...]
#
use strict;
use warnings;

my %access_count;	# Key -> who, value => count
my %page_count;		# Key -> Page, value => count

while (<>) {
    # Skip unknown lines
    #            +++----------------------- Non-spaces
    #           +|||+---------------------- Put in $1
    #           |||||++++------------------ All but "
    #           |||||||||  +++++----------- All but "
    #           ||||||||| +|||||+---------- Put in $2
    #           |||||||||+|||||||+--------- Inside ""
    #           ||||||||||||||||||--------- One+ digits
    #           ||||||||||||||||||+++------ Spaces
    #           ||||||||||||||||||||| +++-- One+ digits
    #           |||||||||||||||||||||+|||+- Result in $3
    if ($_ !~ /(\S+)[^"]*"([^"]*)"\s*(\d+)/) {
	next;
    }
    my $host = $1;	# The accessing host
    my $access = $2;	# The url fetched
    my $error_code = $3;# The error code 

    if ($error_code != 200) {
	next;	# Skip all access that are not OK
    }
    # Turn the info into parts we can use
    my @access_info = split /\s+/, $access;

    $access_count{$host}++;
    $page_count{$access_info[1]}++;
}
my @access_array;	# Access list as an array

# Turn access hash into an array
foreach my $access (keys %access_count) {
    push(@access_array, {
	host => $access,
	count => $access_count{$access}
    });
}

# Get the "top" items
my @access_top = 
    sort { $b->{count} <=> $a->{count} } @access_array;

print "Top hosts accessing the system\n";
print "Hits	Who\n";
for (my $i = 0; $i < 10; ++$i) {
    if (not defined($access_top[$i])) {
	last;
    }
    print "$access_top[$i]->{count}\t",
    	"$access_top[$i]->{host}\n";
}
#----------------------------------------------------------
my @page_array;	# Page list as an array

# Turn page hash into an array
foreach my $page (keys %page_count) {
    push(@page_array, {
	url => $page,
	count => $page_count{$page}
    });
}

# Get the "top" items
my @page_top = 
    sort { $b->{count} <=> $a->{count} } @page_array;

print "Top URLs accessed\n";
print "Hits	What\n";
for (my $i = 0; $i < 10; ++$i) {
    if (not defined($page_top[$i])) {
	last;
    }
    print "$page_top[$i]->{count}\t$page_top[$i]->{url}\n";
}
