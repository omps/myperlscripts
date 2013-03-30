#/usr/bin/perl
#use strict;
#use warnings;

while ($_ = <>) {
	my ($name,$pass,$uid,$gid, $gecos,$home,$shell) = split /:/;
	my $passwordhash{$uid} = $name;
}
	%uid_by_name = reverse %passwordhash;
	print "$uid_by_name{0} is $uid_by_name{$name}";

