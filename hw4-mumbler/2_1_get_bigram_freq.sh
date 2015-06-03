#!/bin/bash

# invoke configuration file
. /gpfs/gpfsfpo/scripts/mumblr.cfg

case `hostname` in
   "gpfs1.mids-rt-w251.com")
       start=0;
       end=33;
       host_dir=gpfs1;
   ;;
   "gpfs2.mids-rt-w251.com")
       start=34;
       end=66;
       host_dir=gpfs2;
   ;;
   "gpfs3.mids-rt-w251.com")
       start=67;
       end=99;
       host_dir=gpfs3;
   ;;
esac

log_file="markov.preprocessing.${host_dir}.log"
out_file="${out_dir}/file_counts.${host_dir}.txt"
done_file="${out_dir}/file_counts.${host_dir}.done"

exec 3>&1 1>>${log_dir}/${log_file} 2>&1

echo "[`hostname`] [`date`] Starting processing files"

echo "[`hostname`] [`date`] Removing previous output file ${out_file} and ${done_file}"
rm -f ${out_file}
touch ${out_file}

rm -f ${done_file}

for ((i=$start; i<=$end; i++ ))
do
   echo "[`hostname`] [`date`] Working on file id $i "
   unzip -c ${data_dir}/${host_dir}/googlebooks-eng-all-2gram-20090715-${i}.csv.zip | awk -F$'\t' '{a[$1]+=$2;}END{for(i in a)print i" "a[i];}' >> ${out_file}
   echo "[`hostname`] [`date`] Completed file id $i "
done

touch ${done_file}