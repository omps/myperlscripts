#/bin/env perl
use strict;
use warnings;
# Excersice 1 
# Q1 . Program to compute the circumfrence of the circle.

#$radius=12.5;
#$pi=3.14;
#$result= 2 * ($pi * $radius);
#print "Circumfrence of the circle is: $result\n";


# Excercise 2.
# Q2. Modify the program to accept the value of the radius.

# $pi = 3.14;
# print "Enter the radius:";
# chomp($radius = <STDIN>);
# #chmop($radius);
# $result = 2 * ($pi * $radius);
# print "Circumfrence of the circle with $radius is: $result\n";


# Excercise 3.
# Q3. If the user enters anything less than 0, the circumfrence should be 0 than negative.

# $pi = 3.14;
# print "Enter the radius: ";
# chomp($radius = <STDIN>);
# if ($radius le '0') {
#   print "Since, the radius is 0 or less than 0; the circle circumference is 0 too.\n";
# } else {
#   $result =  2 * ($pi * $radius);
#   print "The circumference of the circle with $radius is: $result\n";
# }

# Q4. Enter 2 nos. (input taken from keyborad) and print the multiplication of it.

# print "Enter the first no.: ";
# chomp($number1 = <STDIN>);
# print "Enter the second no.: ";
# chomp($number2 = <STDIN>);
# $result = $number1 * $number2;
# print " The multiplication of $number1 and $number2 is: $result\n";

# Q5. program to take input from stdin and print no. of times the string is entered.
print "the string: ";
my $string = <STDIN>;
print "the no.: ";
chomp(my $number = <STDIN>);
my $result = $number x $string;
#my $result = $string x $number;
print "the result is:\n$result";
