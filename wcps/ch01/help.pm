use strict;
use warnings;

INIT {
   if (($#ARGV == 0) && ($ARGV[0] eq "--help")) {
       system("perldoc $0");
       exit (0);
   }
}

1;
