#! /usr/bin/perl -w
  use Statistics::Multtest qw(bonferroni holm hommel hochberg BH BY qvalue);
  use Statistics::Multtest qw(:all);
  use strict;
  
  open (FILE,"$ARGV[0]")||die "can't open file:$!\n";
  my $dumpline = <FILE>;
  chomp $dumpline;
  print "$dumpline\tq-value (BY)\n";
  my %hash = ();
  
  
  while (<FILE>){
  	chomp;

  	if (/^(.*)\s+(\S+)$/){
	 $hash{$1} = $2; 
     }
   }
 close FILE;
 
for my $ele (sort keys %hash){
   my $qvalueBY = BY(\%hash)->{$ele};
  print "$ele\t$hash{$ele}\t$qvalueBY\n";
  }
