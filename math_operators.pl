#!/usr/bin/perl -w

print "Enter a number: "; # on this no. the normal mathmatical operations will be done.
chomp($n = <STDIN>);
$add = $n + $n; # this should be double the value
$subtract = $n - $n; # this should be 0
$multiply = $n * $n; # this should be the no. of times the no.
$divide = $n / $n; # this should be 1
$exp = $n**$n; # this should be no of times the no. is
$mod = $n % 6; # this should be the remainder

print "$n + $n equals to $add\n";
print "$n - $n equals to $subtract\n";
print "$n multiplied by $n equals to $multiply\n";
print "$n when divided by itself($n) the value will be equal to 1($divide).\n";
print "$n to the power of $n, the result is $exp\n";
print "when $n is divided byy 6 the remainder is $mod\n";
