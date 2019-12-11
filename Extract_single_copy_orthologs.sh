#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Please provide arguments!'
    echo 'Usage: ./Extract_single_copy_orthologs.sh inputdirectory'
    echo -e "Input directory should include;\n1. species.txt (abbreviations for species separated by newlines)\n2. orthogroups.txt (all orthogroups without singletons)"
    exit 0
fi

prepare() {
    mapfile -t speciesarray < $1/species.txt
    }

join() {
    local retname=$1 sep=$2 ret=$3
    shift 3 || shift $(($#))
    printf -v "$retname" "%s" "$ret${@/#/$sep}"
}

search_for_all() {
    awk "/$input/"  $1/orthogroups.txt > $1/grp_with_all.txt
    }

fun() {
    mapfile -t array < $1/grp_with_all.txt
    arraylength=${#array[@]}
    for (( i=1; i<${arraylength}+1; i++ ));
    do
        #echo ${array[$i-1]}
        cluster=$(echo ${array[$i-1]} | cut -d : -f 1 | xargs basename)
        #echo $cluster
        for j in "${speciesarray[@]}"
        do
            #echo $j
            count=$(grep -o $j <<< ${array[$i-1]} | wc -l)
            echo -e "$cluster\t$j=$count"
        done
    done
    }

search_for_single() {
    awk "/$input3/" $1/counts_modified.txt > $1/single_copy_ortholog_temp.txt
    }

get_clustersandmodify() {
    awk {'print $1'} $1/single_copy_ortholog_temp.txt > $1/single_copy_ortholog_group_ids.txt    
    grep -w  -f $1/single_copy_ortholog_group_ids.txt $1/grp_with_all.txt > $1/one_copy_in_each.txt
    }
    
main() {
    prepare $1
    echo You have ${#speciesarray[@]} species...
    join input "/&&/" "${speciesarray[@]}"
    search_for_all $1
    echo PATTERN count or quantitative comparison
    fun $1 >> $1/counts_raw.txt
    echo Total number of clusters with complete set of species is $arraylength
    awk '$1==last {printf ",%s",$2; next} NR>1 {print "";} {last=$1; printf "%s",$0;} END{print "";}' $1/counts_raw.txt > $1/counts_modified.txt
    echo derive single copy ortholog from counts_modified.txt
    input2=${input//"/&&/"/"=1\>/&&/\<"}
    echo $input2
    input3=$(echo $input2 | sed 's/^/\\</g'|sed 's/$/=1\\>/g') #for exact match awk '/\< string \>/ && /\< string2 \>/ etc. Otherwise it takes clusters with all =1 but e.g. Hsap=17 etc.
    echo $input3
    search_for_single $1
    get_clustersandmodify $1
    mkdir $1/toextractseq
    cp $1/one_copy_in_each.txt $1/toextractseq/
    cd $1/toextractseq/
    echo Replace the Group tags of clusters
    echo "Convert the rows into columns (and separate the groups by blank line)"
    perl -pne 'BEGIN {$\="\n"}s/ /\n/g' one_copy_in_each.txt > no_others_no_duplicates_rmv_spc_no_prefix_in_colomn.txt
    echo Copy the file into a new name
    cp no_others_no_duplicates_rmv_spc_no_prefix_in_colomn.txt ids_in_all_cluster.txt
    echo "Final result is the ids_in_all_cluster.txt in toextractseq directory and it contains all the SCOs"
    }


main $1
