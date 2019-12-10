#!/usr/bin/perl -w 

use strict;
use Getopt::Long;
my $help;
my $infile = '';
my %final;
my $limit = 0.5;
my @sum = qw();
my $mask;
GetOptions ("h" => \$help,
	    "in=s" => \$infile,
	    "limit=s" => \$limit,
    "mask" => \$mask);
if ($help) {
	die "gapcol_removal.pl -in=<> [-limit=<>] [-mask] [-h]

DESCRIPTION:
gapcol_removal.pl processes an alignment by removing all alignment columns where the fraction of species that are represented by an amino acid is below 'limit'.
OPTIONS:
-in: provided the filename of the alignment in fasta format
-mask: set this flag when the alignment columns should rather be masked than removed
-limit: determines the minimum fraction of species that have to be represented by a amino acid in an alignment column. DEFAULT: 0.5\n";
}

my @seqs = `less $infile |sed -e 's/>//'`;
chomp @seqs;
my %smkeep = @seqs;
my %sm = @seqs;
my $speccount = scalar(keys %sm);
## translate all aminoacids into a 1, all other characters into a 0
## and sum up
for (keys %sm) {
    $sm{$_} =~ s/[^FLIMVSPTAYHQNKDECWRG]/0/ig;
    $sm{$_} =~ s/[A-Z]/1/gi;
    my @loc = split //, $sm{$_};
    for (my $i = 0; $i < @loc; $i++) {
	$sum[$i] += $loc[$i];
    }
}

## extract the alignment
for (my $i = 0; $i < @sum; $i++) {
    if ($sum[$i]/$speccount > $limit) {
	for (keys %sm) {
	    $final{$_} .= substr($smkeep{$_}, $i, 1);
	}
    }
    else {
	if ($mask) {
	   for (keys %sm) {
	    $final{$_} .= '*';
	   }
	}
    }
}
open (OUT, ">$infile.proc") or die "could not open infile\n";
for (my $i = 0; $i < @seqs; $i+= 2) {
    print OUT ">$seqs[$i]\n$final{$seqs[$i]}\n";
}
close OUT;

