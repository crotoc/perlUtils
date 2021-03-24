#!/bin/env perl
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use MyBase::Usual;
use Storable;


####################################################################
##                             OPTIONS
####################################################################
my $Version=&date;
my $opt_help;
my $opt_e;
my $opt_version;
my $opt_save=1;
my $opt_load='';
my $opt_in;
my $opt_out;
my $u=MyBase::Usual->new();
my $opt_temp;
my $opt_c;
my $opt_d;
my $opt_delimiter="\t";


GetOptions(
    "help|h!" => \$opt_help,
    "excute|e!" => \$opt_e,
    "i|in=s" => \$opt_in,
    "c|col=s" => \$opt_c,
    "d|col2=s" => \$opt_d,
    "o|out=s" => \$opt_out,
    "s|save!" => \$opt_save,
    "l|load!" => \$opt_load,
    "temp!" => \$opt_temp,
    "version|v!" => \$opt_version
    ) or pod2usage(
    verbose => 0,
    exitstatus => 1
    );

if ($opt_help) {
    pod2usage(
	verbose => 2,
	exitstatus => 0
	);
}

if ($opt_version) {
    print $Version;
    exit 0;
}

if(!$opt_e){
    $u->printopts2(
	{
	    "help|h!" => \$opt_help,
	    "excute|e!" => \$opt_e,
	    "i|in=s" => \$opt_in,
	    "c|col=s" => \$opt_c,
	    "d|col2=s" => \$opt_d,
	    "o|out=s" => \$opt_out,
	    "s|save!" => \$opt_save,
	    "l|load!" => \$opt_load,
	    "temp!" => \$opt_temp,
	    "version|v!" => \$opt_version
	});
    print "Add -e to excute\n";
    exit '0';
    
}

####################################################################
##                               Filehandle
####################################################################
my $fh_out;
if(!$opt_out){$fh_out=*STDOUT;}
else{open($fh_out,">$opt_out")}

my $fh_in;
open($fh_in,"<$opt_in");

####################################################################
##                               STORAGE
####################################################################
# if($opt_save && !$opt_load){
#     store $hash,"$opt_in.hash";
# }

# if($opt_load && -e "$opt_in.hash")
# {
#     $hash=retrieve("$opt_in.hash");
# }
# elsif($opt_load && ! -e "$opt_in.hash")
# {
#     die "need hash.result\n";
# }

# if($opt_load && -e "$opt_in.hash")
# {
#     $hash=retrieve("$opt_in.hash");
# }
# elsif($opt_load && ! -e "$opt_in.hash")
# {
#     die "need $opt_in.hash\n";
# }


####################################################################
##                               MAIN
####################################################################


my @c;
@c = $u->colstr2array($opt_c);
map {$c[$_]-=1} 0..$#c;
#print Dumper(@c);

my @d;
@d = $u->colstr2array($opt_d), if $opt_d;
map {$d[$_]-=1} 0..$#d, if $opt_d;

#print Dumper(@d);

my $hash;

while (<$fh_in>) {
    chomp;
    my @f=split/\t/,$_,-1;
    #print Dumper @f;
    if(! scalar(@d)){
	my $e;
        map {$e->{$_}++} 0..$#f;
	map {delete $e->{$_}} @c;
	@d = sort {$a <=> $b } keys %$e;
	#print Dumper(@d);
    }

    my $key = join "\t",@f[@c];
    foreach my $d (@d){
	push @{$hash->{$key}->{$d}},$f[$d];
    }
    
}

for my $key(sort keys %$hash){
    my @out;
    push @out,$key;
    foreach my $d(@d){	
	push @out,join (";",@{$hash->{$key}->{$d}});
    }
    print join ("\t",@out)."\n";
}

####################################################################
##                             TEMP FILE SAVE
####################################################################
my $fh_temp;
if($opt_temp){
    open($fh_temp,">$opt_out.temp"),if $opt_out || open($fh_temp,">out.temp");
}





####################################################################
##                               SUBS
####################################################################

sub date{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my @abbr = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    $year += 1900;
    return("$abbr[$mon] $mday $year\n");
}


__END__
####################################################################
##                             Now Docs...
####################################################################
=head1 NAME

 mergebycol.pl  - merge columns by single/multiple columns as index

 Example: perl ~/script/mergebycol.pl -in tmp -c 1,2,3,4,5  -e > tmp.merge

=head1 SYNOPSIS

 mergebycol.pl  [-h] [-v]

=head1 OPTIONS

=over 1

=item B<-h|--help>

 Print help message and exit successfully.

=item B<-c|--col>

 Columns as key

=item B<-d|--col2>

 Columns will be combined. If unspecified, all the rest columns except option specified by "-c" are in effect.

=item B<-v|--version>

 Print version information and exit successfully.

=back

=cut
