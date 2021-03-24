#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $i = 0;
my $t = 0;
while(<>){
    $t++;
    chomp;
    my @a = split/\t/;
    if($a[0] eq $a[1])
    {$i++;}
}
my $j = $t - $i;

print "Total = $t; Same = $i; Unequal = $j\n";

