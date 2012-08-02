#!/usr/bin/perl


# Formula for (a+b)^2

    $a = 0;
    $b = 0;
    $result = 0;

# Taking the value of a and b from the command line
print "Enter the value for a: ";
      chomp($a = <STDIN>);
print "Enter the value for b: ";
      chomp($b = <STDIN>);


# applying the formula to get the result.

$result = ($a**2)+(2*$a*$b)+($b**2);

print "$result\n";
