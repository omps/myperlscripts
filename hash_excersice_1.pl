#!/usr/bin/perl 
#use strict;
use warnings;

%friends = ('fred' => 'flintstone',
	  'barney' => 'rubble',
	  'wilma' => 'flintstone',
	  );

print "Enter the name of the friend:\n";
#$friend_in = chomp(<STDIN>); ## Chomp cannot modify the STDIN directly, though when passed to the variable it can remove any new line characters.
chomp($friend_in = <STDIN>);
print "$friend_in belongs to $friends{$friend_in}\n";
