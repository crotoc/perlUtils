#!/usr/bin/env perl
use strict;
use Getopt::Long;
use MyBase::Usual;

my $opt_h;
my $opt_q;
my $opt_c=1;
my $opt_db;
my $opt_d=1;
my $opt_excute;
my $opt_delimiter1="\t";
my $opt_delimiter2=",";
my $u = Usual->new();
my $opt_last;

GetOptions(
    "q|query=s" => \$opt_q,
    "db=s" => \$opt_db,
    "c|col1=s" => \$opt_c,
    "d|col2=s" => \$opt_d,
    "de1|delimiter1=s" => \$opt_delimiter1,
    "de2|delimiter2=s" => \$opt_delimiter2,
    "l|last!" => \$opt_last,
    "h!" => \$opt_h,
    "e|excute!" => \$opt_excute,
    );


if(!$opt_excute){
    $u->printopts2(
	{
	    "q|query=s" => \$opt_q,
	    "c|col1=s" => \$opt_c,
	    "d|col2=s" => \$opt_d,
	    "db=s" => \$opt_db,
	    "de1|delimiter1=s" => \$opt_delimiter1,
	    "de2|delimiter2=s" => \$opt_delimiter2,
	    "l|last!" => \$opt_last,
	    "h!" => \$opt_h,
	    "e|excute!" => \$opt_excute,
	}
	);
    print "type -e to run\n";
    exit 0;
}

$opt_db || die "Need -db";
my $fh_db;
if($opt_db)
{
    open($fh_db,"<$opt_db");
}
else{
    open($fh_db,"-");
}

my @db = <$fh_db>;
chomp(@db);
#print $db[1];

$opt_q || die "Need -q";
my $fh_q;
if($opt_q && $opt_q ne "-")
{
    open($fh_q,"<$opt_q");
}
else{
    open($fh_q,"-");
}

my @q = <$fh_q>;
chomp(@q);


my @d;
if(!$opt_d){
    my $max = `head -n1 $opt_db | perl -F"\t" -lane 'print scalar(\$F);' `;
    chomp($max);
    @d = 1..$max;
}
else{
    @d = $u->colstr2array($opt_d);
}

my @c;
@c = $u->colstr2array($opt_c);

map {$d[$_]-=1} 0..$#d;
map {$c[$_]-=1} 0..$#c;
#print join (":",@d),"\n";
#print join (":",@c),"\n";


#print "here";

my $m=0;
for my $q(@q)
{
    my @tmp_q = split/\t/,$q;
    my $a=0;
    #print $q,"\t";#,$q_lc,"\t",$a,"\t";
    for(@tmp_q[@c]){
	my $q_lc = lc($_);
	#print "\tq:$q_lc\t";
	for my $db(@db)
	{
	    my $c=0;
	    #print $db;
	    my @field=split/$opt_delimiter1/, $db;
	    my @tmp;
	    my @tmp1;
	    #print join (":",@field[@d]),"\n";
	    for my $field(@field[@d]){
		@tmp1 = split/$opt_delimiter2/,$field;
		map {s/^ +| +$//g} @tmp1;
		push @tmp,@tmp1;
	    }
	    
	    #print join (":",@tmp)."\n";
	    for my $next_db(@tmp)
	    {
		if ($q_lc eq lc($next_db))
		{
		    $c=1;
		    last;
		}
	    }
	    
	    if($c==1)
	    {
		print "$q\t$db\n";
		$a=1;
		if($opt_last){
		    last;
		}
	    }
	}
	if($a==1)
	{
	    last;
	}
    }
    if($a==0)
    {
    	$m++;
    	print "$q\tnocommon$m\n";
    }
}

