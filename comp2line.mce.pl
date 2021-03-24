#!/usr/bin/env perl
use strict;
use Getopt::Long;
use MyBase::Usual;
use Data::Dumper;
use List::Uniq qw(:all);
use Storable;
use MCE;
use MCE::Loop;
use MCE::Shared::Minidb;

my $opt_h;
my $opt_q;
my $opt_c=1;
my $opt_db;
my $opt_d=1;
my $opt_excute;
my $opt_delimiter="\t";
my $opt_delimiter1=",";
my $opt_delimiter2=",";
my $u = Usual->new();
my $opt_last;
my $opt_load;
my $opt_save;

GetOptions(
    "q|query=s" => \$opt_q,
    "db=s" => \$opt_db,
    "c|col1=s" => \$opt_c,
    "d|col2=s" => \$opt_d,
    "de|delimiter=s" => \$opt_delimiter,
    "de1|delimiter1=s" => \$opt_delimiter1,
    "de2|delimiter2=s" => \$opt_delimiter2,
    "l|last!" => \$opt_last,
    "h!" => \$opt_h,
    "e|excute!" => \$opt_excute,
    "load!" => \$opt_load,
    "s|save!" => \$opt_save,
    );


if(!$opt_excute){
    $u->printopts2(
	{
	    "q|query=s" => \$opt_q,
	    "c|col1=s" => \$opt_c,
	    "d|col2=s" => \$opt_d,
	    "db=s" => \$opt_db,
	    "de|delimiter=s" => \$opt_delimiter,
	    "de1|delimiter1=s" => \$opt_delimiter1,
	    "de2|delimiter2=s" => \$opt_delimiter2,
	    "l|last!" => \$opt_last,
	    "h!" => \$opt_h,
	    "e|excute!" => \$opt_excute,
	    "load!" => \$opt_load,
	    "s|save!" => \$opt_save,
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

#my @db = <$fh_db>;
#chomp(@db);
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

my $db_hash_ref;
if($opt_save && !$opt_load){
    print STDERR "Saving or loading Hash...";
    #my $n; 
    while(my $db=<$fh_db>){
	#$n++;
	#print int($n/1000000)."\n",if $n%1000000==0;
	my @field=split/$opt_delimiter/, $db;
	
	my $tmp;
	for my $field(@field[@d]){
	    #print "field:$field;here\n";
	    my @tmp1;
	    if($field){@tmp1 = split/$opt_delimiter2/,$field;}
	    #print Dumper(@tmp1);
	    
	    map {s/^ +| +$//g;$tmp->{$_}++;} @tmp1;
	}
	#print Dumper(@tmp);
	foreach my $key(keys %$tmp){
	    push @{$db_hash_ref->{$key}},$db;
	}
    }
    store $db_hash_ref, $opt_db.".hash";
}
elsif($opt_load && -e  $opt_db.".hash"){
    $db_hash_ref = retrieve($opt_db.".hash");
}
else
{
    die "check -load and -save option\n";
}

print STDERR "Finishing loading index...";


my $m=0;
#my $head;
sub _match{
    my ($query,$col1,$db,$col2) = @_;
    @q = @$query;
    @c = @$col1;
    @
    for my $q(@q){
	#print $q,if $q=/^#/;
	my @tmp_q = split/\t/,$q;

	my $a = 0;
	#print Dumper(@tmp_q[@c]);
	for my $field(@tmp_q[@c])
	{
	    my @tmp_sub=split/$opt_delimiter1/,$field;
	    for my $key(@tmp_sub){
		if(exists $db_hash_ref->{$key})
		{
		    $a = 1;
		    if($opt_last)
		    {
			print $q."\t".${$db_hash_ref->{$key}}[0]."\n";
		    }
		    else
		    {
			foreach my $value (@{$db_hash_ref->{$key}}){
			    print $q."\t".$value."\n";
			}
		    }
		    if($opt_last){
			last;
		    }
		}
	    }
	    last,if $a && $opt_last;
	}
	
	if($a==0)
	{
	    $m++;
	    print "$q\tnocommon$m\n";
	}
	#    print Dumper(keys $_);
    }

}
