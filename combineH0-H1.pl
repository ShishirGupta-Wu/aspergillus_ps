#! usr/bin/perl
#use strict;
die "Usage: $0 codeml-bs-H1.txt codeml-bs-H0.txt > gene.list" unless (@ARGV == 2);

open(LIST,$ARGV[0])or die "cannot open $ARGV[0]\n";
open(GENE,$ARGV[1])or die "cannot open $ARGV[1]\n";

my %hash = ();
my %vash = ();
my $count = 0;
my $l1 = 0;
my $l0 = 0;

my $dumpline1 = <LIST>;
chomp $dumpline1;

while(<LIST>){                               #each line contains only one word
	chomp;
   if(/^(\S+)\s+(\S+)\s+(\S+)/){
     $l1 = $3;
	 $hash{$1} = $_;
	 $vash{$1} = $l1;
}
}
close LIST;

my $dumpline2 = <GENE>;
chomp $dumpline2;
print "$dumpline2\t$dumpline1\t2DeltaL\n";

while(<GENE>){
	chomp;
	if(/^(\S+)\s+(\S+)\s+(\S+)/){
	 my $gene = $1;
	 $l0 = $3;
	 #warn "$gene\n";
	 if(exists $hash{$gene}){
	   my $delta = 2*($vash{$gene} - $l0);
	   print "$_\t$hash{$gene}\t$delta\n";
	   }
	  }
}
close (GENE);
