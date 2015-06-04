#!/bin/bash

# ==============================================================================
# IMPORTANT
# 1. THIS SCRIPT MUST BE LAUNCHED FROM NODE1
# ==============================================================================

# This script has two parts/steps. comments and pupose below

# invoke configuration file
. /gpfs/gpfsfpo/scripts/mumblr.cfg

[ ! -f ${out_dir} ] && mkdir ${out_dir}
[ ! -f ${mumblr_dir} ] && mkdir ${mumblr_dir}

case `hostname` in
   "gpfs1.mids-rt-w251.com") host_dir=gpfs1;;
   "gpfs2.mids-rt-w251.com") host_dir=gpfs2;;
   "gpfs3.mids-rt-w251.com") host_dir=gpfs3;;
esac

log_file="markov.preprocessing.${host_dir}.log"

exec 3>&1 1>>${log_dir}/${log_file} 2>&1

# ==============================================================================
# pre-processing step 1
# ==============================================================================

# This is step 1 of the pre-processing to calculate frequency of bi-grams across
# all the years and the number of appearances of first word in the bi-gram. This 
# script launches sub-processes on all the three nodes of GPFS cluster to process 
# the corpus in parallel. The scripts creates one output file one each node in 
# below format
#   word1 word2 bigram_freq word1_freq

# pre-processing step 1 starts
echo "[`hostname`] [`date`] starting pre-processing files"

# all commands must be launched from node 1 (gpfs1)
# launch scripts on 3 nodes to process specific files to get bi-gram frequency counts
echo "[`hostname`] [`date`] launching script on all three nodes to calculate bi-gram frequencies"
cd ${script_dir}; nohup ${script_dir}/2_1_get_bigram_freq.sh &
ssh -n -f root@${node2} "sh -c 'cd ${script_dir}; nohup ${script_dir}/2_1_get_bigram_freq.sh &'"
ssh -n -f root@${node3} "sh -c 'cd ${script_dir}; nohup ${script_dir}/2_1_get_bigram_freq.sh &'"

# wait until the files are created
sleep 60
while [ true ]
do
    if [ -f "${out_dir}/file_counts.gpfs1.done" -a -f "${out_dir}/file_counts.gpfs2.done" -a -f "${out_dir}/file_counts.gpfs3.done" ]
    then
        break;
    fi
done

echo "[`hostname`] [`date`] completed pre-processing step 1"

# pre-processing step 1 completes

# ==============================================================================
# pre-processing step 2
# ==============================================================================

# This is step 2 of the pre-processing to sort the files created from step 1 and
# consolidate the files to have unique counts for each bigram in the final file.
# The final pre-processed file will be split into small files based on the first
# character of the bigram i.e. "financial straits" will go into f.txt file. This
# split runs on all the three nodes. The mumblr script uses these smaller files 
# to mumble. Split files will be created on the three nodes and evenly distributed
#   a.txt --> h.txt on node 1
#   i.txt --> q.txt on node 2
#   r.txt --> z.tzt on node 3
#   word1 word2 bigram_freq word1_freq

# pre-processing step 2 starts
echo "[`hostname`] [`date`] starting pre-processing step 2"

# concatenate output from three nodes
echo "[`hostname`] [`date`] concatenating bi-gram frequency files from all three nodes"
cat ${out_dir}/file_counts.gpfs1.txt ${out_dir}/file_counts.gpfs2.txt ${out_dir}/file_counts.gpfs3.txt > ${out_dir}/file_counts.txt

# sort file based on first and second column
echo "[`hostname`] [`date`] sorting bigram frequency file"
sort -k1,1 -k2,2 ${out_dir}/file_counts.txt > ${out_dir}/file_counts.srt.txt
mv ${out_dir}/file_counts.srt.txt ${out_dir}/file_counts.txt

# add new column to get count of first word in the corpus
echo "[`hostname`] [`date`] adding new column to capture word2 of bi-gram frequencies"
awk 'FNR==NR{a[$1]+=$3;next}; {print $0, a[$1]}' ${out_dir}/file_counts.txt{,} > ${out_dir}/bigram.pre-processed.txt

# create separate files for each starting alphabet
# ignoring numbers and special characters
echo "[`hostname`] [`date`] splitting bi-gram frequency file based on starting alphabet of first word (ignoring numbers and special characters)"
cd ${mumblr_dir}
awk 'substr($1,1,1) ~ "^[a-zA-Z0-9!:,;_]$" && substr($2,1,1) ~ "^[a-zA-Z0-9!:,;_]$" { print tolower($0) > tolower(substr($1,1,3))".txt" }' ${out_dir}/bigram.pre-processed.txt

cd ${script_dir}

echo "[`hostname`] [`date`] completed pre-processing step 2"
# pre-processing step 2 completes