#!/usr/bin/perl

while ( $cookie ne 'cookie' ) {
  print 'Give me cookie: ';
  chomp($cookie = <STDIN>);
}
