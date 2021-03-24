#!/bin/env perl
use strict;

use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Storable;
use Switch;
use Bundle::Wrapper;
use Cwd;
use String::Random;
use MyBase::Usual;
use POSIX qw(ceil);

####################################################################
##                             OPTIONS
####################################################################

my $Version=Bundle::Wrapper->date;
my $s=MyBase::Mysub->new();
my %opt;
$opt{time}=Bundle::Wrapper->date;
$opt{threads}=5;
$opt{n}=1;
$opt{format}="group";
$opt{out}="temp";
$opt{outtype}="number";


GetOptions(
    "help|h!" => \$opt{help},
    "excute|e!" => \$opt{e},
    "chkopt!" => \$opt{chkopt},
    "version|v!" => \$opt{version},
    "s|save!" => \$opt{save},
    "l|load!" => \$opt{load},
    "cmd=s" => \@{$opt{cmd}},
    "t|threads=i" => \$opt{threads},
    "temp!" => \$opt{temp},
    "i|in=s" => \$opt{in},
    "o|out=s" => \$opt{out},
    "header!" => \$opt{header},

    "outtype=s" => \$opt{outtype},
    "n=i" => \$opt{n},
    "f|format=s" => \$opt{format},
    "col=i"=>\$opt{col},

    "dir_out=s" => \$opt{dir_out},
    "dir_log=s" => \$opt{dir_log},
    # "~1=s" => \\$opt{~1},
    # "~1!" => \\$opt{~1},
    # "~1=i" => \\$opt{~1},
    ) or pod2usage(
    verbose => 0,
    exitstatus => 1
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

##initiate some opts if not specify
$opt{dir_out}= Cwd::getcwd."/out",if ! $opt{dir_out};
$opt{out}= !$opt{out}?"$opt{dir_out}/out":"$opt{dir_out}/$opt{out}";
$opt{dir_log}="$opt{dir_out}/log",if !$opt{dir_log};

if(!$opt{e}){
    $s->opt_print(\%opt);
    print "Add -e to excute\n";
    exit '0';
}

my $b=Bundle::Wrapper->new(\%opt);
$b->mkdir($opt{dir_out});

####################################################################
##                               Filehandle
####################################################################
my $fh_in;
open($fh_in,"<$opt{in}");

my $fh_log;
open($fh_log,">",$opt{log}), if $opt{log};


####################################################################
##                               STORAGE
####################################################################
# if($opt{save} && !$opt{load}){
#     store $hash,"$opt{in}.hash";
# }

# if($opt{load} && -e "$opt{in}.hash")
# {
#     $hash=retrieve("$opt{in}.hash");
# }
# elsif($opt{load} && ! -e "$opt{in}.hash")
# {
#     die "need hash.result\n";
# }

# if($opt{load} && -e "$opt{in}.hash")
# {
#     $hash=retrieve("$opt{in}.hash");
# }
# elsif($opt{load} && ! -e "$opt{in}.hash")
# {
#     die "need $opt{in}.hash\n";
# }


####################################################################
##                               MAIN
####################################################################
if($opt{in}=~/\.gz/){
    open(M,"zcat $opt{in} |");
}
else{
    open(M,"<$opt{in}");
}   
chomp(my @map=<M>);
close M;

#print scalar(@map);
my $this = MyBase::Usual->new();
my %group = $this->grouphash(\@map,$opt{format},$opt{col});

my $total = scalar(keys %group);
my $n = ceil(scalar(keys %group)/$opt{n});
print "Total:$total\tnGroup:$n\tnEntries:$opt{n}\n";

my $c = 0;
chomp(my $pwd = `pwd`);
my $tmp;


foreach my $key(sort {$a <=> $b} (keys %group)){
    $tmp = $c % $opt{n};
    if($tmp==0){
	my $gf;
	if($opt{type} eq "number"){
	    $gf="$opt{out}.$tmp";
	}else{
	    $gf="$opt{out}$key";
	}
	print "Write to $gf\n";
	open(GF,">$gf");
    }
    print GF @{$group{$key}};
}


#while(<$fh_in>){
#}


####################################################################
##                               SUBS
####################################################################
#sub

####################################################################
##                             TEMP FILE SAVE
####################################################################
my $fh_temp;
if($opt{temp}){
    open($fh_temp,">$opt{out}.temp"),if $opt{out} || open($fh_temp,">out.temp");
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

=item B<-h|--help>

 Print help message and exit successfully.

=item B<-v|--version>

 Print version information and exit successfully.

=item B<-excute|e>
Run cmd

=item B<-dir_out>

Folder of output.
Default: pwd/out


=item B<-cmd>

Command build in this script, including:
fmt_zscore, coordinate, intersect, split, twas.
The order is important, please reserve it.


=item B<-header>

Parse header 

=item B<-out>

Prefix of output files. Default: out

=item B<-t|threads>

Threads used 

=item B<-save>

Save hash if there exists.

=item B<-load>

Load hash if there exists.

=item B<chkopt>

Check auto-parsed opts

=item B<-version>

Version of this script.

=back

=cut






