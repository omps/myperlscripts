#!/usr/bin/perl -w

$one = 0;
$two = 0;

print ' Enter a range boundry: ';
chomp($one = <STDIN>);
print ' Enter the other range boundry: ';
chomp($two = <STDIN>);

if ($one < $two) {
    @array = ($one .. $two);
} else {
	@array = ($two .. $one);
}

print "@array\n";
