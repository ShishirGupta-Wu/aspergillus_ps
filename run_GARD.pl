#! /usr/bin/perl

use strict;
use warnings;

#core Perl modules
use Getopt::Long;

#locally-written modules
BEGIN {
    select(STDERR);
    $| = 1;
    select(STDOUT);
    $| = 1;
}

# get input params
my $global_options = checkParams();

my $inputdir;
my $templatefile;
my $path;

$inputdir = &overrideDefault("inputfile.dir",'inputdir');
$templatefile = &overrideDefault("template.bf",'templatefile');
$path = &overrideDefault("wd.path",'path');

######################################################################
# CODE
######################################################################

my %count = ();
opendir(DIR, $inputdir) || die "Can't open directory $inputdir\n";
my @store_array = ();
@store_array = readdir(DIR);
my $name = '';

foreach my $file (@store_array) {
	next unless ($file =~ /^\S+\.fa$/);
	if ($file =~ /^(\S+\.fa)$/){
		$name = $1;
	}
  open (IN, "$templatefile") or die;
  open (OUT, ">$inputdir/runGARDPro.$name.bf") or die;
  my $fullpath = $path.'/'.$inputdir.'/'.$file;
  while(<IN>){
   chomp;
   $_ =~ s/full path to the original alignment file/$fullpath/;
   $_ =~ s/full path to the output file with extension _splits/$fullpath.html_splits/;
   print OUT "$_\n";
  }
  system("mpirun -np 150 HYPHYMPI $inputdir/runGARDPro.$name.bf > $inputdir/$name.SH.txt");
}

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputdir|i:s", "templatefile|t:s", "path|p:s");
    my %options;

    # Add any other command line options, and the code to handle them
    # 
    GetOptions( \%options, @standard_options );
    
	#if no arguments supplied print the usage and exit
    #
    exec("pod2usage $0") if (0 == (keys (%options) ));

    # If the -help option is set, print the usage and exit
    #
    exec("pod2usage $0") if $options{'help'};

    # Compulsosy items
    #if(!exists $options{'infile'} ) { print "**ERROR: $0 : \n"; exec("pod2usage $0"); }

    return \%options;
}

sub overrideDefault
{
    #-----
    # Set and override default values for parameters
    #
    my ($default_value, $option_name) = @_;
    if(exists $global_options->{$option_name}) 
    {
        return $global_options->{$option_name};
    }
    return $default_value;
}

=head1 DESCRIPTION

	Run a GARDProcessor analysis to confirm that the topologies differ between segments and the significant recombination breakpoints.

=head1 SYNOPSIS

script.pl  -i -t -p [-h]

 [-help -h]                Displays this basic usage information
 [-inputdir -i]            Input directory containing raw alignment file to be tested 
 [-templatefile -t]        Batch file as template to create input by running GARDProcessor
 [-path -p]                The current working directory prompted by pwd



