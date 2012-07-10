use warnings;
$input = ''; # temporary input
@nums = (); #array of nos. since the array will be built eventally from $input hence it is left blank for now.
$count = 0; # Count of no., nothing is in array right now so is 0 now.
$sum = 0; #sum of numbers;
$avg = 0; #average
$med = 0; #median

while () {
    print "Enter a number: \n";
    chomp($input = <STDIN>);
    if ( $input ne '') {
	$nums[$count] = $input; # Here for each input we are putting it in slot in array.
	$count++; # $count is doing double duty here not only counting the total nos. and incrementing but also acting as an index. hence we are using this as index before incrementing it, so we have to correctly start the index with 0.
	$sum += $input;
    }
    else { last; }
}

@nums = sort {$a <=> $b} @nums; #sorting is done here. $a and $b are local to sort
$avg = $sum / $count; # Calculates the average
$med = $nums[$count /2]; # Calculates the  median. to find the median we just have to divide the $count by 2 and use the middle value as the index to the array. In case of a floating point result, the value will be truncated to an integer.

print "\n Total count of nos.: $count \n";
print "Total Sum of nos: $sum\n";
print "Minimum No.: $nums[0]\n";
print "Maximum No.: $nums[$#nums]\n"; #here the $# variable is taking the index as the end of the array.
printf("Average (mean): %.2f\n", $avg);
print "Median: $med\n";
