#!/usr/bin/env perl
use strict;
use Getopt::Long;
use MyBase::Usual;
use Data::Dumper;
use List::Uniq qw(:all);
use Storable;
use Bundle::Wrapper;
use Pod::Usage;

my $Version=Bundle::Wrapper->date;
my $s=MyBase::Mysub->new();
my %opt;
$opt{q}="-";
$opt{c}=1;
$opt{d}=1;
$opt{query_d1}="\t";
$opt{query_d2}=",";
$opt{db_d1}="\t";
$opt{db_d2}=",";
my $u = MyBase::Usual->new();
$opt{hash}="hash";
$opt{nocomm_string}=undef;
$opt{mode} = "regular";

GetOptions(
    "q|query=s" => \$opt{q},
    "db=s" => \$opt{db},
    "c|col1=s" => \$opt{c},
    "d|col2=s" => \$opt{d},
    "query_d1|=s" => \$opt{query_d1},
    "query_d2|=s" => \$opt{query_d2},
    "db_d1|=s" => \$opt{db_d1},
    "db_d2|=s" => \$opt{db_d2},
    "nocomm_string=s" => \$opt{nocomm_string},
    "hash=s" => \$opt{hash},
    "l|last!" => \$opt{last},
    "ignorecase!" => \$opt{ignorecase},
    "mode=s" => \$opt{mode},
    
    "h!" => \$opt{help},
    "e|excute!" => \$opt{e},
    "load!" => \$opt{load},
    "s|save!" => \$opt{save},
    );

if ($opt{help}) {
    pod2usage(
	verbose => 2,
	exitstatus => 0
	);
}

if ($opt{version}) {
    print $Version;
    exit 0;
}

if(!$opt{e}){
    $s->opt_print(\%opt);
    print "Add -e to excute\n";
    exit '0';
}


$opt{db} || die "Need -db";
my $fh_db;
if($opt{db})
{
    open($fh_db,"<$opt{db}");
}
else{
    open($fh_db,"-");
}

#my @db = <$fh_db>;
#chomp(@db);
#print $db[1];

$opt{q} || die "Need -q";
my $fh_q;
if($opt{q} && $opt{q} ne "-")
{
    open($fh_q,"<$opt{q}");
}
else{
    open($fh_q,"-");
}

my @q = <$fh_q>;
chomp(@q);


my @d;
if(!$opt{d}){
    my $max = `head -n1 $opt{db} | perl -F"\t" -lane 'print scalar(\$F);' `;
    chomp($max);
    @d = 1..$max;
}
else{
    @d = $u->colstr2array($opt{d});
}

my @c;
@c = $u->colstr2array($opt{c});

map {$d[$_]-=1} 0..$#d;
map {$c[$_]-=1} 0..$#c;

sub format_hash{
    my $db_hash_ref;
    my $ncol_db;
    while(my $db=<$fh_db>){
	chomp($db);
	#$n++;
	#print int($n/1000000)."\n",if $n%1000000==0;
	my @field=split/$opt{db_d1}/, $db,-1;
	push @{$db_hash_ref->{"ncol"}},scalar(@field),if ! exists $db_hash_ref->{"ncol"};
	
	my $tmp;
	for my $field(@field[@d]){
	    #print "field:$field;here\n";
	    my @tmp1;
	    if($field){@tmp1 = split/$opt{db_d2}/,$field,-1;}
	    #print Dumper(@tmp1);
	    
	    map {s/^ +| +$//g;my $key=undef;if($opt{ignorecase}){$key = lc($_)}else{$key=$_}$tmp->{$key}++;} @tmp1;
	}
	#print Dumper($tmp);
	foreach my $key(keys %$tmp){
	    push @{$db_hash_ref->{$key}},$db;
	}
    }
    return $db_hash_ref;
}

sub format_hash_multipleCol{
    my $db_hash_ref;
    my $ncol_db;
    while(my $db=<$fh_db>){
	chomp($db);
	#$n++;
	#print int($n/1000000)."\n",if $n%1000000==0;
	my @field=split/$opt{db_d1}/, $db,-1;
	push @{$db_hash_ref->{"ncol"}},scalar(@field),if ! exists $db_hash_ref->{"ncol"};
	
	my $tmp;
	my $key = join ":",@field[@d];
	push @{$db_hash_ref->{$key}},$db;
    }
    return $db_hash_ref;
}


my %routine = ( regular => \&format_hash,
		ncol => \&format_hash_multipleCol
    );
        

my $db_hash_ref;
if($opt{save} && (!$opt{load} || ! -e  $opt{db}.".$opt{hash}")){
    print STDERR "MSG: Saving Hash...\n";
    $db_hash_ref = $routine{$opt{mode}}->();
    store $db_hash_ref, $opt{db}.".$opt{hash}";
}
elsif($opt{load} && -e  $opt{db}.".$opt{hash}"){
    print STDERR "MSG: loading hash....\n";
    $db_hash_ref = retrieve($opt{db}.".$opt{hash}");
}
elsif(!$opt{save}  && !$opt{load}){
    $db_hash_ref = $routine{$opt{mode}}->();
    print STDERR "MSG: Don't save hash...\n";
}
else
{
    die "check -load and -save option\n";
}

print STDERR "Finishing loading index...\n";

#print Dumper($db_hash_ref);

# foreach(keys %db_hash_ref)
# {
#     if($db_hash_ref{$_}==11){print $_."\n";}
# }

#print join ("\n",@{$db_hash_ref{ENSG00000145241}}),"\n";
#print Dumper($db_hash_ref->{"ncol"});
#print Dumper($db_hash_ref);
my $m=0;
#my $head;
for my $q(@q){
    #print $q,if $q=/^#/;
    my @tmp_q = split/$opt{query_d1}/,$q,-1;
    $q=~s/$opt{query_d1}/\t/g, if $opt{query_d1} ne "\t";
    my $a = 0;
    #print Dumper(@tmp_q[@c]);
    if($opt{mode} eq "regular"){
	for my $field(@tmp_q[@c])
	{
	    my @tmp_sub=split/$opt{query_d2}/,$field,-1;
	    for my $key(@tmp_sub){
		#print Dumper($key);
		#print Dumper($db_hash_ref->{$key});
		if($opt{ignorecase}){$key=lc($key)}
		if(exists $db_hash_ref->{$key})
		{
		    $a = 1;
		    if($opt{last})
		    {
			my $best= &whichisbest($db_hash_ref->{$key},\@d,$key);
			#print Dumper($best);
			print $q."\t".${$db_hash_ref->{$key}}[$best]."\n";
		    }
		    else
		    {
			foreach my $value (@{$db_hash_ref->{$key}}){
			    print $q."\t".$value."\n";
			}
		    }
		    if($opt{last}){
			last;
		    }
	    }
	    }
	    last,if $a && $opt{last};
	}
    }elsif($opt{mode} eq "ncol"){
	my $key = join ":",@tmp_q[@c];
	if(exists $db_hash_ref->{$key})
	{
	    $a = 1;
	    if($opt{last})
	    {
		my $best= &whichisbest($db_hash_ref->{$key},\@d,$key);
		print $q."\t".${$db_hash_ref->{$key}}[$best]."\n";
	    } else
	    {
		foreach my $value (@{$db_hash_ref->{$key}}){
		    print $q."\t".$value."\n";
		}
	    }
	}    
    }
    
    if($a==0)
    {
	$m++;
	my @out;
	map {push @out,"nocommon$m"} 1..${$db_hash_ref->{"ncol"}}[0], if ! defined $opt{nocomm_string};
	map {push @out,$opt{nocomm_string}} 1..${$db_hash_ref->{"ncol"}}[0], if defined $opt{nocomm_string};
	my $nocomm = join "\t",@out;
	print "$q\t$nocomm\n";
    }
#    print Dumper(keys $_);
}


sub whichisbest{
    my $a = $_[0];
    my $n = $_[1];
    my $record = $_[2];

    my $ref;
    foreach (@$a){
	my @f = split/\t/,$_,-1;
	push @{$ref},[@f];
    }

    #print Dumper($ref);
    #print Dumper($n);

    my $last=0;
    my $best;

    foreach my $tmp_n(@$n){
	my $c=0;
	foreach my $tmp_ref(@$ref){
	    $c++;
	    my @tmp_db = split/$opt{db_d2}/,$$tmp_ref[$tmp_n],-1;
	    #print Dumper(@tmp_db);
	    foreach(@tmp_db){
		if($record eq $_){
		    $last=1;
		    $best=$c-1;
		    last;
		}
	    }
	    if($last==1){last;}
	}
	if($last==1){
	    last;
	}
    }
    return $best;
}


__END__
####################################################################
##                             Now Docs...
####################################################################
=head1 NAME

  $0  - DESCRIBE ME

=head1 SYNOPSIS

$0  [-h] [-v]

=head1 EXAMPLES

perl $0 

=head1 OPTIONS

=over 1

=item B<-c>

Specify the searching cols of query file. Use 1,2,3 for multiple columns.

=item B<-q,--query>

Specify  query file.

=item B<-query_d1>

specify the major delimiter of query file.

=item B<-query_d2>

specify the secondary delimiter for specified colnums of query file.

=item B<-d>

specify the searching cols of db file. Use 1,2,3 for multiple columns.

=item B<-db>

speicify db file

=item B<-db_d1>

specify major delimiter for db file

=item B<-db_d2>

specify secondary delimeter of db file

=item B<-save>

Save indexed hash file of db for specified cols for repeated searching. Use together with -hash

=item B<-hash>

specify the indexed hash name. MyBase::Usually different files for different col indexing.

=item B<-load>

load indexed hash for db file for specified cols. Use "-save -load" for the first time indexing.

=item B<-nocomm_string>

Use this string for the record of querynull records  

=item B<-last>

For multiple matching records of db, only output the first one.

=back
