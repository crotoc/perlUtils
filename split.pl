#!/usr/bin/env perl
use strict;
use MyBase::Usual;
use Getopt::Long;


my $opt_in;
my $opt_n;
my $opt_h;
my $opt_col;
my $opt_out;
my $opt_excute='';


GetOptions(
    "i|in=s" => \$opt_in,
    "o|out=s" => \$opt_out,
    "n=i" => \$opt_n,
    "h!"=> \$opt_h,
    "col=i"=>\$opt_col,
    "e|excute" => \$opt_excute,
    );

sub usage
{print "$0 -i <> -n <> -o <>\n";exit 0;}

&usage if $opt_h;
my $u=MyBase::Usual->new();

if(!$opt_excute){
    $u->printopts2(
	{"i|in=s" => \$opt_in,
	 "o|out=s" => \$opt_out,
	 "n=i" => \$opt_n,
	 "h!"=> \$opt_h,
	 "col=i"=>\$opt_col,
	 "e|excute" => \$opt_excute,
	});
    print "Add -e to excute\n";
    exit '0';
}


die "specify n",if !$opt_n;
my $file = $opt_in;
my $nentry= $opt_n;
if($file=~/\.gz/){
    open(M,"zcat $file |");
    
}
elsif($file eq "-")
{
    open(M,"-|");
}
else{
    open(M,"<$file");
}   
chomp(my @map=<M>);
close M;

my $total = scalar(@map);

my $tc = 0;
my $c = 0;
my $fc = 1;

if(!$opt_out){if($opt_in=~/.*\/(.*)/){$opt_out=$1}else{$opt_out=$opt_in}}
my $gf="$opt_out.$fc";
#print "$gf\n";
open(GF,">$gf");

foreach(@map){
    $c++;$tc++;

    if($c<=$opt_n){
	print GF $_,"\n";
    }
    else
    {
	#print $c;
	$c=1;
	close(GF);
	$gf="$opt_out.".(int($tc/$opt_n)+1);
	#print $gf;
	open(GF,">$gf");
	print GF $_,"\n";
    }
}

