#!/usr/bin/perl


use strict;
use warnings;

# Q1 Chapter 4, create subroutine total.
sub total {
my $result = 0;
foreach (@_) {
  $result += $_;
  }
$result;
}

# With nos. given in the code.
my @fred = qw/1 3 5 7 9/;
my $fred_total = &total(@fred);
print "The total of \@fred is $fred_total\n";

# With nos. to be taken from STDIN.
# print "Enter some nos.:";
# my @user_no = <STDIN>;
# my $user_total = &total(@user_no);
# print "The total of \@user_no is $user_total\n";


# Q2 Chapter 4. Sum of the nos from 1 to 1000.
my @sum_tho = (1 .. 1000);
my $total_tho = &total(@sum_tho);
print "Total of \@sum_tho is $total_tho\n";


# Q3. nos. above the average no.

sub average {
  if (@_ == 0) { return }
  my $sum = 0;
  my $noofele = @_;
  foreach ( @_ ) {
    $sum += $_;
  }
 $sum / $noofele;
}

sub max {
  my ($max_so_far) = shift @_;
  foreach (@_) {
    if ($_ > $max_so_far) {
      $max_so_far = $_;
    }
  }
  $max_so_far;
}

# sub above_average {
# #  my $result = &average(@_);
#   my $noofele = @_;
#   my $mean = &average(@_);
#   if ( $mean < $noofele ) {
#     ++$mean..$noofele;
#   } else {
#     &max(@_);
#   }
# }


my @fred1 = &above_average(1..10);
print "\@fred1 is @fred1\n";

my @barney = above_average(100,1..10);
print "\@barney is @barney\n";

#sub max {
#my $result = &average(1..10);
# my $tot = &total(1..10);

#print "Average for \$tot is $result\n";

## Above average another approach.

sub above_average {
 my  $average = &average(@_);
  my @list;
  foreach my $element (@_) {
    if ($element > $average ) {
      push @list, $element;
    }
  }
@list;
}

## Question 4. subroutine to greet a person.
  
use 5.010;

sub greet {
  state @names;
  my $name = shift;
  print "Hi $name!";
  if ( @names ) {
    print "i have seen: @names!\n";
  } else {
    print "you are the first person here!\n";
  }
  push @names, $name;
}

&greet('Fred');
&greet('Barney');
&greet('Wilma');
&greet('Betty');
