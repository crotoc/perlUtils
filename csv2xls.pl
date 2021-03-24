#!/usr/bin/env perl

use strict;
use Spreadsheet::WriteExcel;
use Encode;

sub usage {
    print "usage:\n
cvs2xls.pl -i <input> -o <output> [-s 'separator'] [-d]
convert a cvs file to a xls simple file.
Source file will be parsed using ';' as default separator, or 'sep' if specified.
Arg 'd' specifies if debug info should be sent to STDERR.

";
} 

sub getArgs {
    my @args=@_;
    my $oldKey="";
    my %opts=();
    my $el;
    for $el (@args) {
	if ($el=~/^-/) {
	    $el=~s/-+//g;
	    $opts{$el}="";
	    $oldKey=$el;
	}
	else {
	    $opts{$oldKey}=$el;
	}
    }
    return %opts;
}

my $sourcename;
my $destname;
my $sep=";";
my %opts;
my $debug=0;

%opts=getArgs(@ARGV);

if (exists $opts{help}) {
    &usage();
    exit;
}
if (exists $opts{d}) {
    $debug=1;
}
if ((!exists $opts{i}) || (!exists $opts{o})) {
    print STDERR "Missing 'i' option !\n" if (!exists $opts{i});
    print STDERR "Missing 'o' option !\n" if (!exists $opts{o});
    &usage();
    exit;
}
if (exists $opts{s}) {
    $sep=$opts{s};
    $sep='\|' if ($sep eq '|');
}

$sourcename=$opts{i};
$destname=$opts{o};

my $workbook  = Spreadsheet::WriteExcel->new("$destname");
my $worksheet = $workbook->addworksheet();


open (SRC,"<$sourcename") || die "Can't open $sourcename !";
my $nrow=0;
while (my $line=<SRC>) {
    my @lcol;
    chomp $line;
    @lcol=split($sep,$line);
    my $ncol=0;
    for my $col (@lcol) {
	$worksheet->write_string($nrow, $ncol, decode('utf8',$col));
	$ncol++;
    }
    $nrow++;
}

close SRC;

