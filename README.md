# Analysis of Positive Selection in Aspergillus
In this repository we describe the workflow followed to process and analyze the data of the study "*Genetic comparison of Aspergillus fumigatus with 18 other species of the genus Aspergillus reveals conservation, evolution and specific virulence genes*".

## Issues & Contacts
Please note that these scripts were not designed to function as a fully-automated pipeline, but rather as a series of individual steps with extensive manual quality control between them. It will therefore not be straightforward to run all steps smoothly in one go. Feel free to contact me (shishir.gupta@uni-wuerzburg.de) or [Prof. Dr. Thomas Dandekar](https://www.biozentrum.uni-wuerzburg.de/bioinfo/research/groups/funct-genomics-systems-biology/people/thomas-dandekar/) (dandekar@biozentrum.uni-wuerzburg.de) if you run into any issue.

## Requirements 

Perl, BioPerl, Blast, T-Coffeee, Pal2Nal, Gblocks, Hyphy, RaxML, PAML. All the programs should be installed and path should be added in the bash profile (Unix OS).

## 1. Sequences
All the amino acid sequences used can be downloaded from [here](https://funginet.hki-jena.de/data_files/80) and nucleotide sequences can be downloaded from [here](https://funginet.hki-jena.de/data_files/79).

## 2. Orthology analysis
Orthology were computed using standerd protocol of OrthoMCL. Please find the access link of software [here](https://orthomcl.org/common/downloads/software/v2.0/orthomclSoftware-v2.0.9.tar.gz) and protocol for computations [here](https://orthomcl.org/common/downloads/software/v2.0/UserGuide.txtV).

The resulted cluster from orthology analysis can be obtained [here](https://funginet.hki-jena.de/data_files/76). Single copy ortholog clusters were extracted by the bash script [extract_single_copy_orthologs.sh](https://github.com/ShishirGupta-Wu/aspergillus_ps/blob/master/extract_single_copy_orthologs.sh).

## 3. Alignments

`$ perl run_tcoffee.pl -i protein_cluster_dir`

`$ perl run_pal2nal.pl -p protein_alignment_dir -d gene_cluster_dir -c directory_codon_alignments`

*Removal of Unreliable Alignment Regions*

`$ perl run_gblocks.pl -i directory_codon_alignments`

Nucleotide alignment of single copy orthologs can be obtained from [here](https://funginet.hki-jena.de/data_files/81).

## 4. Recombination
Create a text file named as input_path.txt which should contain the full path to each tested alignment file per line.
Place the file in the same directory as the alignment files  and execute the following command on the terminal.

`$ mpirun -np 4 HYPHYMPI run_GARD.bf`

`$ perl run_GARDProcessor.pl -i gard_directory -t GARDProcessor_temp.bf -p full_path_to_working_ directory`

`$ perl summary_breakpoint.pl -i gard_dir -o breakpoint.tab`

## 5. Evolutionary analyses

*Generation of species tree*

Keep script concat_alignments.pl in the directory with amino acid sequence alignment of single copy orthologs   

`$ perl concat_alignments.pl`

`$ perl degapper.pl -in concat_alignments.fa -limit 0.5`

`$ raxmlHPC-PTHREADS-AVX -f a -T 2 -p 12345 -m PROTGAMMAAUTO -x 12345 -# 10000 -s concat_alignments.fa.proc -m PROTGAMMAAUTO -n T20`

*For null model*

`$ perl run_codeml_BS_Null.pl -s phylip -t species_tree.txt -o M1a > run.log &`

`$ perl parse_codeml_BS_H0.pl M1a codeml-bs-M1a.txt`

*For alternative model*

`$ perl run_codeml_BS_modelA.pl -s phylip -t species_tree.txt -o M2a > run.log &`

`$ perl parse_codeml_BS_H1.pl M2a codeml-bs-M2a.txt`

*Statistics*

`$ perl combineM1-M2.pl codeml-bs-M2a.txt codeml-bs-M1a.txt > gene.list`

`$ perl statistics-chi2-df1-pvalue.pl gene.list > combineM1aM2a_addPvalue_gene.list.txt`

`$ perl calculating-qvalue-BY.pl combineM1aM2a_addPvalue_gene.list.txt > combinedM1aM2a_addQvalue_gene.list.txt`

## Additional files
Additional data and material can be found [here](https://github.com/ShishirGupta-Wu/aspergillus_ps/blob/master/Supplementary_materials.zip) in a single zip file. Sequence alighment of Single Copy Orthologs can be obtained from [here](https://funginet.hki-jena.de/data_files/76)

#### [Additional file 1: Supplementary figures](https://github.com/ShishirGupta-Wu/aspergillus_ps/blob/supplementary_data/Supplementary_figures.pdf) -

Figure S1: Proteins-protein interactions (PPIs) map. PPIs between *A. fumigatus* proteins coded by positively selected genes (PSGs) and human proteins. Orange - *A. fumigatus* proteins and blue - human proteins.

Figure S2: Gene Ontology (GO) overrepresentation analysis. Biological process (GO) significantly overrepresented in human proteins targeted by *A. fumigatus* virulence related proteins coded by multi-copy category positively selected genes (PSGs).

Figure S3: *A. fumigatus* and *A. fischeri* genome synteny map. Image was generated using the Mauve genome alignment tool. Upper and lower lines of the genomes correspond to *A. fumigatus* and *A. fischeri* respectively. Red vertical bars indicate concatenated chromosomal boundaries. Color-coded syntenic blocks indicate conserved segments (LCBs; Locally Collinear Blocks) identified by Mauve (minimum LCB weight = 999). Plots of sequence similarity are shown within each syntenic block. Regions with no color indicate no detectable homology between the two genomes with the settings used in Mauve. Unmatched regions (white area) within an LCBs indicate the presence of strain-specific sequence. The connecting lines between blocks indicate the location of each block in two genomes. Homologous regions with possible rearrangements are shown in first row.

#### [Additional data file 1](https://github.com/ShishirGupta-Wu/aspergillus_ps/blob/supplementary_data/Additional%20data%20file%201.pdf):

Clusters of orthologues identified by OrthoMCL (inflation index: 1.5). Abbreviations - abra : *Aspergillus brasiliensis*, acar : *A. carbonarius*, acla : *A. clavatus*, afis : *A. fischeri*, afla : *A. flavus*, afum : *A. fumigatus*, agla : *A. glaucus*, akaw : *A. kawachii*, alue : *A. luchuensis*, anid : *A. nidulans*, anig : *A. niger*, aora : *A. oryzae*, asyd : *A. sydowii*, ater : *A. terreus*, atub : *A. tubingenesis*, aver : *A. versicolor*, awen : *A. wentii*, azon : *A. zonatus*.

#### [Additional data file 2](https://github.com/ShishirGupta-Wu/aspergillus_ps/blob/supplementary_data/Additional%20data%20file%202.pdf):

Core genome of Aspergillus. The file consists of all the clusters containing at least one protein from all the analysed 18 species. Abbreviations - abra : *Aspergillus brasiliensis*, acar : *A. carbonarius*, acla : *A. clavatus*, afis : *A. fischeri*, afla : *A. flavus*, afum : *A. fumigatus*, agla : *A. glaucus*, akaw : *A. kawachii*, alue : *A. luchuensis*, anid : *A. nidulans*, anig : *A. niger*, aora : *A. oryzae*, asyd : *A. sydowii*, ater : *A. terreus*, atub : *A. tubingenesis*, aver : *A. versicolor*, awen : *A. wentii*, azon : *A. zonatus*.

#### [Additional data file 3](https://github.com/ShishirGupta-Wu/aspergillus_ps/blob/supplementary_data/Additional%20data%20file%203.pdf): 

*A. fumigatus* and *A. fischeri* orthology analysis (Inparanoid output).

#### [Additional file 2](https://github.com/ShishirGupta-Wu/aspergillus_ps/blob/supplementary_data/Additional%20file%202.xlsx) –

Table S1. Conservancy of *A. fumigatus* specific genes in other *A. fumigatus* strains

Table S2. Basic genomic information of all eighteen aspergilli

Table S3. GO over-representation analysis of single copy orthologs in the three GO categories (i.e. ‘Biological Processes’, BP; ‘Molecular Function’, MF; ‘Cellular Component’, CC)

Table S4. Quantitative summary of orthology assignments

Table S5. GO over-representation analysis of recombination breakpoint containing clusters in the three GO categories (i.e. ‘Biological Processes’, BP; ‘Molecular Function’, MF; ‘Cellular Component’, CC)

Table S6. Pathway overrepresentation of host proteins interacting with *A. fumigatus* positively selected proteins

Table S7. Gene Ontology (GO) overrepresentation of host proteins interacting with *A. fumigatus* positively selected proteins

Table S8. Positively selected genes and KOG annotations

Table S9. Positively selected multi-gene family virulence genes identified in *A. fumigatus*

Table S10. Genes from top three GO-biological processes with reference to ortholog relation to amoeba species *A. castellanii* and *D. discoideum*

Table S11. Positively selected genes and their expression in hypoxia conditions

Table S12. *A. fumigatus* positively selected hub proteins

Table S13. Degree of *A. fumigatus* positively selected proteins involved in host interactions

Table S14. Positively selected genes identified in *A. fischeri*

Table S15. Recombination breakpoints in alignments
