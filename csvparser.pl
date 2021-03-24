#!/usr/bin/env perl
use strict;
use Text::CSV_PP;

my $file=shift @ARGV;
#print "file=$file";
if($file){
    open(IN, "<$file");
}
else{
    open(IN, "<-") or die "can't open $!";
}

my $csv = Text::CSV_PP->new ( ) or die "Cannot use CSV: ".Text::CSV->error_diag ();

while(my $line=<IN>)
{
    chomp($line);
    my $status  = $csv->parse($line);        # parse a CSV string into field            
    my @f = $csv->fields();
    print join("\t",@f)."\n";            
}
close IN;
