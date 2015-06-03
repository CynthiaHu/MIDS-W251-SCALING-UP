#!/bin/bash

# this is a wrapper to embed all the scripts developed for markov text generation
# there is a separate script for mumblr and this script is intended to run only if
# pre-processing step is not completed.
# ==============================================================================
# IMPORTANT
# 1. THIS SCRIPT MUST BE LAUNCHED FROM NODE1
# 2. THIS SCRIPT TAKES LONG TIME TO RUN AS IT HAS TO DOWNLOAD HUGE DATA AND DOES
#    PRE-PROCESSING. PLEASE RUN THIS SCRIPT IN nohup mode
#      nohup /gpfs/gpfsfpo/scripts/main.wrapper.sh &
# ==============================================================================

# invoke configuration file
. /gpfs/gpfsfpo/scripts/mumblr.cfg

# launching script to download the corpus
if [ "$enable_download" = "Y" ]
then
    echo "[`hostname`] [`date`] preparing to download files" 

    nohup ${script_dir}/1_download_data.sh &
    ssh -n -f root@${node2} "sh -c 'cd ${script_dir}; nohup ${script_dir}/1_download_data.sh &'"
    ssh -n -f root@${node3} "sh -c 'cd ${script_dir}; nohup ${script_dir}/1_download_data.sh &'"

    echo "[`hostname`] [`date`] downloading files..." 

# wait until download completes
    sleep 60
    while [ true ]
    do
        if [ -f "${download_dir}/download.complete.gpfs1" -a -f "${download_dir}/download.complete.gpfs1" -a -f "${download_dir}/download.complete.gpfs1" ]
        then
            break;
        fi
    done
fi

echo "[`hostname`] [`date`] pre-processing files..." 
${script_dir}/2_mumblr_preprocessing.sh