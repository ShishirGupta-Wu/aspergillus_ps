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

my $seqdir;
my $tree;
my $outputdir;

$seqdir = &overrideDefault("alignment.dir",'seqdir');  #the last variable must be the same in the line below: my @standard_options = ( "help|h+", "seqdir|s:s", "tree|t:s", "outputdir|o:s");
$tree = &overrideDefault("tree.file",'tree');
$outputdir = &overrideDefault("nullModel.dir",'outputdir');

######################################################################
# CODE
######################################################################

 system("mkdir $outputdir"); 
 
#==============================================================



my %count = ();
opendir(DIR, $seqdir) or die;
my @store_array = ();
@store_array = readdir(DIR);
my $name = '';

foreach my $file (@store_array) {
	next unless ($file =~ /^\S+\.phylip$/);
	if ($file =~ /^(\S+)\.phylip$/){
		$name = $1;
	}
	
  open (OUT, ">$name.H1.ctl")|| die "can't open contral file:$!\n";

  print OUT "seqfile           = $seqdir/$file\n",
            "treefile          = $tree\n",
            "outfile           = $outputdir/$name-BSM-H1\n",
            "noisy             = 0\n",
            "verbose           = 1\n",
            "runmode           = 0\n",
            "seqtype           = 1\n",
            "CodonFreq         = 2\n",
            "aaDist            = 0\n",
            "model             = 2\n",
            "NSsites           = 2\n",                         #modify this parameter
            "icode             = 0\n",
            "fix_kappa         = 0\n",
            "kappa             = 2\n",
            "fix_omega         = 0\n",
            "omega             = 1.5\n",                    #(or any value > 1)
            "clock             = 0\n",
            "getSE             = 0\n",
            "RateAncestor      = 0\n",
            "Small_Diff        = .5e-6\n",
            "cleandata         = 1\n";

  system("codeml $name.H1.ctl");
}


#==============================================================

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "seqdir|s:s", "tree|t:s", "outputdir|o:s");
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

	Run an alternative model H1 using the codeml program on many coding
    genes.

=head1 SYNOPSIS

script.pl  -i -t -p [-h]

 [-help -h]              Displays this basic usage information
 [-seqdir -s]            Input directory containing non-recombinant alignments 
 [-tree -t]              Input species tree with labeled branch for a single lineage
 [-outputdir -o]         Output directory

