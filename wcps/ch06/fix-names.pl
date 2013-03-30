#!/usr/bin/perl
=pod

=head1 NAME

fix_names.pl - Fix bad file names

=head1 SYNOPSIS

    fix_name.pl <file> [<file> ...]

=head1 DESCRIPTION

The I<fix_names.pl> command renames files with bad names into ones with good names.

=head1 AUTHOR

Steve Oualline, E<lt>oualline@www.oualline.comE<gt>.

=head1 COPYRIGHT

Copyright 2005 Steve Oualline.
This program is distributed under the GPL.  

=cut
foreach my $file_name (@ARGV)
{
    # Compute the new name
    my $new_name = $file_name;

    $new_name =~ s/[ \t]/_/g;
    $new_name =~ s/[\(\)\[\]<>]/x/g;
    $new_name =~ s/[\'\`]/=/g;
    $new_name =~ s/\&/_and_/g;
    $new_name =~ s/\$/_dol_/g;
    $new_name =~ s/;/:/g;

    # Make sure the names are different
    if ($file_name ne $new_name)
    {
	# If a file already exists by that name
	# compute a new name.
	if (-f $new_name) 
	{
	    my $ext = 0;

	    while (-f $new_name.".".$ext)
	    {
	        $ext++;
	    }
	    $new_name = $new_name.".".$ext;
	}
	print "$file_name -> $new_name\n";
	rename($file_name, $new_name);
    }
}
