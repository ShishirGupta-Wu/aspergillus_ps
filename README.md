# Analysis of Positive Selection in Aspergillus
In this repository I describe the workflow followed to process and analyze the data of the study "Genetic comparison of Aspergillus fumigatus with 18 other species of the genus Aspergillus reveals conservation, evolution and specific virulence genes".

# Issues & Contact
Note that these scripts were not designed to function as a fully-automated pipeline, but rather as a series of individual steps with extensive manual quality control between them. It will therefore not be straightforward to run all steps smoothly in one go. Feel free to contact me (shishir.gupta@uni-wuerzburg.de) if you run into any issue.

# Supplementary data and material
Additional data and material can be found here: Supplementary data and material. Sequence Alighment of Single Copy Orthologs can be obtained from [here](https://funginet.hki-jena.de/data_files/76)

# 1. Sequences
All the sequences used can be downloaded from

# 2. Orthology analysis
Orthology were computed using standerd protocol of OrthoMCL. Please find the access link of software [here](https://orthomcl.org/common/downloads/software/v2.0/orthomclSoftware-v2.0.9.tar.gz) and protocol for computations [here] https://orthomcl.org/common/downloads/software/v2.0/UserGuide.txtV

The resulted cluster from orthology analysis can be obtained [here](https://funginet.hki-jena.de/data_files/76). Single copy ortholog clusters were extracted from the script ..

# 3. Alignments

Requirement - Perl, BioPerl, T-Coffeee, Prank, Pal2Nal, Gblocks. All the programs should be installed and path should be added in the bash profile (Unix OS).

$ perl run_tcoffee.pl -i protein_cluster_dir

$ perl run_pal2nal.pl -p protein_alignment_dir -d gene_cluster_dir -c directory_codon_alignments

Removal of Unreliable Alignment Regions

$ perl run_gblocks.pl -i directory_codon_alignments

# 4. Recombination

Create a text file named as input_path.txt which should contain the full path to each tested alignment file per line.
Place the file in the same directory as the alignment files  and execute the following command on the terminal.

$ mpirun -np 4 HYPHYMPI run_GARD.bf

$ perl run_GARDProcessor.pl -i gard_directory -t GARDProcessor_temp.bf -p full_path_to_working_ directory

$ perl summary_breakpoint.pl -i gard_dir -o breakpoint.tab

# 5. Evolutionary analyses

Generation of species tree

Keep script concat_alignments.pl in the directory with amino acid sequence alignment of single copy orthologs   

$ perl concat_alignments.pl

$ perl degapper.pl -in concat_alignments.fa -limit 0.5 

$ raxmlHPC-PTHREADS-AVX -f a -T 2 -p 12345 -m PROTGAMMAAUTO -x 12345 -# 10000 -s concat_alignments.fa.proc -m PROTGAMMAAUTO -n T20 

For null model
$ perl run_codeml_BS_Null.pl -s phylip -t species_tree.txt -o M1a > run.log &

$ perl parse_codeml_BS_H0.pl M1a codeml-bs-M1a.txt

For alternative model
$ perl run_codeml_BS_modelA.pl -s phylip -t species_tree.txt -o M2a > run.log &

$ perl parse_codeml_BS_H1.pl M2a codeml-bs-M2a.txt


Statistics

$ perl combineM1-M2.pl codeml-bs-M2a.txt codeml-bs-M1a.txt > gene.list

$ perl statistics-chi2-df1-pvalue.pl gene.list > combineM1aM2a_addPvalue_gene.list.txt

$ perl calculating-qvalue-BY.pl combineM1aM2a_addPvalue_gene.list.txt > combinedM1aM2a_addQvalue_gene.list.txt
