#!/usr/bin/perl

# Operators and precedence.

$sum = (4 +4) / 4;
print "$sum\n";

$number = 10;
$number++;
print "$number\n";


$number = 10;
--$number;
print "$number\n";

$letter = "A";
$letter++;
print "$letter\n";

$sum = 2 ** 3; 
print "$sum\n";

$sum = 10 % 3;
print "$sum\n";

# The output of the belwo will be 3.33...
## We will  use integer to ignore the decimal place.
use integer;
$sum = 10 / 3;
print "$sum\n";

# Now the eqality operators.
# notice how the strings are used with eq as an operator whereas in  number the operator is ==
$number = 10;
if ($number == 10) {
    print "10\n";
}

$word = "hello";
if ($word eq "hello") {
    print "Hello\n";
}

# Inequality operators.
# Notice the operators used in each case
$number = 190;
if ($number != 10) {
    print "Not 10\n";
}

$word = "Hello";
if ($word ne "hello") {
    print "Not Hello\n";                                                            
}

# While loop
$count = 1;
while ($count <= 10 ) {
    print "Hello\n";
    $count++;
}

@array = qw(frog dog bird cat elephant);
$count = 0; # arrays are indexed from zeros.
  while ($count <= 4) {
print "$array[$count]\n";
$count++;
}




# Until loop, it is reverse to the while loop, hence meaning until the condition is true, keep doing this.
@array = qw(frog dog bird cat elephant);
$count = 0;
until (($array[$count] eq "bird")) {
print "$array[$count]\n";
$count++;
}
