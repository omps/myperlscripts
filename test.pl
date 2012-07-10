#!/usr/bin/perl5.14.2
use warnings;
#@arrayname = qw/1,2,3,4,5,6,7,8,9/;
#    $numlist = @arryname;
#print $numlist;

# Example 2


 @t =(1, 2, 3); 
$t[5] = 6;     # Here we have inserted an element to the array.
# print "@t\n"; # it will print 2 undefined element 1 2 3   6
# # perl will give a warning in case of undefined elements.
 # if (!defined $t[3]) {
 #     print "Element 3 is undefined. \n";
 # }

# alternatively we can use the undef function.
# We still see the element in the printout, to delete this undef element we need to explicitly delete it.
# if (!defined $t[4]) {
#     undef ($t[4]); # here $t is the $array and 4 is the $index
# }

# undef can be used inside or outside the array, example of using it inside the array
#@holeinthemiddle = (1, 2, undef, undef, undef, 6);
#print "@holeinthemiddle\n";


# Finding the end of the array
# Perl gives you the index of the last element in the array, with $#arrayname. With this index no. we can create a simple loop that goes from index0 to the last index.
# to print content of an array, one element per line.
# Unhash line 10 and line 11
# $i = 0;
# while ( $i <= $#t ) {
#     print $t[$i++], "\n";
# }

# if you get warning for uninitialized values unhash line 14,15,16


# to find length of an array
$numelement = @t;
print "$numelement \n";


# sorting
$t[4] = 4;
$t[3] = 5;
$t[6] = 55345;
$t[7] = 98;
print "unsorted:@t \n";
@sortednums = sort @t;
print "sorted:@sortednums \n";

# Sorting in numerical order
@ordered = sort { $a <=> $b } @t;
print "ordered: @ordered\n";

# Processing the elements of an array line by line.
foreach $u (@t) {
  print "$u \n";
  }
