#!/usr/bin/perl
# Script which prompt you for two arrays and then creates a third array that contains only the element prenset in the first two( the intersection of those arrays

$in = ''; #temo input
@array1 =  ();
@array2 = ();
@final = ();

print 'Enter the first array: ';
chomp($in = <STDIN>);
@array1 = split(' ', $in);
print 'Enter the second array: ';
chomp($in = <STDIN>);
@array2 = split(' ', $in);

foreach $el (@array1) {
    foreach $el2 (@array2) {
	if (defined $el2 && el eq $el2) {
	    $final[$#final+1];
	    undef el2;
	    last;
	}
    }
}
