#! /usr/bin/perl -w
  use Statistics::Distributions;
  open (FILE,"$ARGV[0]")||die "can't open file:$!\n";
  my $dumpline = <FILE>;
  chomp $dumpline;
  print "$dumpline\tp-value (chi-square with df = 1)\n";
  while (<FILE>){
  	chomp;
  	if (/\s+(\S+)$/){
  		$chisprob=Statistics::Distributions::chisqrprob (1,$1);
  print "$_\t$chisprob\n";
     }
   }
   close FILE;
  
