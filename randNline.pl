#!/usr/bin/env perl
#!/bin/env perl
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use MyBase::Usual;
use Storable;
use List::Util qw(shuffle)

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
my $opt_n;
my $opt_out;
my $u=MyBase::Usual->new();
my $opt_temp;
my $opt_rest;

GetOptions(
    "help|h!" => \$opt_help,
    "excute|e!" => \$opt_e,
    "i|in=s" => \$opt_in,
    "n=i" => \$opt_n,
    "o|out=s" => \$opt_out,
    "s|save!" => \$opt_save,
    "l|load!" => \$opt_load,
    "temp!" => \$opt_temp,
    "rest!" => \$opt_rest,
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
	    "Excute|e!" => \$opt_e,
	    "i|in=s" => \$opt_in,
	    "n=i" => \$opt_n,
	    "o|out=s" => \$opt_out,
	    "s|save!" => \$opt_save,
	    "l|load!" => \$opt_load,
	    "temp!" => \$opt_temp,
	    "rest!" => \$opt_rest,
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
my $bufsize = $opt_n;
my @list = ();

if(!$opt_rest){
    srand();
    while (<$fh_in>)
    {
	push(@list, $_), next if @list < $bufsize;
	#print "$.\n";
	$list[ rand(@list) ] = $_ if rand(${.}/$bufsize) < 1;
    }
    print foreach @list;
}
else{
    my @$deck=<$fh_in>;
    my $picks_left = $opt_n;
    my $num_left = @$deck;
    my @picks;
    my $idx = 0;
    my @result;
    my @left;
    while($picks_left > 0 ) {  # when we have all our picks, stop
    # random number from 0..$num_left-1
    my $rand = int(rand($num_left));

    # pick successful
    if( $rand < $picks_left ) {
        push @result, $deck->[$idx];
        $picks_left--;
    }
    else{
	push @left, $deck->[$idx];
    }

    $num_left--;
    $idx++;
    }
        

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


####################################################################
##                             TEMP FILE SAVE
####################################################################
my $fh_temp;
if($opt_temp){
    open($fh_temp,">$opt_out.temp"),if $opt_out || open($fh_temp,">out.temp");
}



__END__
####################################################################
##                             Now Docs...
####################################################################
=head1 NAME

 randNline.pl  - DESCRIBE ME

=head1 SYNOPSIS

 randNline.pl  [-h] [-v]

=head1 OPTIONS

=over 1

=item B<-h|--help>

 Print help message and exit successfully.

=item B<-v|--version>

 Print version information and exit successfully.

=back

=cut


