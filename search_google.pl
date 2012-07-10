#!/usr/bin/perl -w
use strict;
require LWP::UserAgent;

my $ua = LWP::UserAgent->new;

$ua->timeout(10);
$ua->env_proxy;

my $response = $ua->get('http://search.cpan.org');

if ($response->is_success) {
    print $response->decoded_content;
}
else {
    die $response->staus_line;
}
