#!/usr/bin/perl -w

use strict;
die "Usage: $0 dir outputfile " unless (@ARGV == 2);
  
  open (OUT, ">$ARGV[1]") or die;	
  print OUT "OG_ID\tNumber_of_parameters\tLikelihood (H1)\tPositively selected sites";       #extract model1a results

  my $dir = $ARGV[0] || die "need a directory";
  opendir(DIR, $dir) or die;  
my @store_array = ();
@store_array = readdir(DIR);
my $name = '';
my @array = ();

foreach my $file (@store_array) {
	@array = ();
 	next unless ($file =~ /-H1$/);
 	if ($file =~ /^(.*?)-BSM-H1/){
		$name = $1;
	} 
  print OUT "\n$name\t";
  
  open(FILE, "$dir/$file") || die "no input file";
  my $flag = 0;
  
  while(<FILE>){
    chomp;
	#lnL(ntime: 43  np: 47):  -2519.176271      +0.000000
	if(/^lnL\S+\s+\d+\s+np:\s+(\d+)\):\s+(\S+)\s+/){
	  print OUT "$1\t$2\t";
   }
   #Bayes Empirical Bayes
   if(/^Bayes Empirical Bayes/){
    $flag = 1;
	}
	if($flag == 1){
	 #   216 I 0.979*
	 if(/^\s+(\d+)\s+(\S+)\s+\d\.\d+\*/){
	  push @array, $1;
	  }
	  }
	#The grid (see ternary graph for p0-p1)
	if(/^The grid \(/){
	 $flag = 0;
	 print OUT join(", ", @array);
	 }
}
}

