#!/bin/bash

# this is mumblr script takes two parameters:
#    mumbler <starting word> <max number of words>

# say the starting word is "straits". The mumbler looks up all n-grams that 
# start with "straits". Now mumbler needs evaluates all two-grams that start 
# with "straits" and select the next word. The process is repeated until either
# there is no two-gram that starts with that words or the length of the mumble 
# is exhausted.

[ $# -ne 2 ] && { echo "Incorrect usage. Run script as $0 WORD COUNT"; exit; }

SEED=$1
MAX_ITERATIONS=$2

iteration=`expr $MAX_ITERATIONS - 1`
current_seed=`echo $SEED | awk '{print tolower($0)}'`
output="$SEED"
mumblr_dir="/gpfs/gpfsfpo/mumblr"

STARTTIME=$(date +%s)
echo "Mumblr thinking..."

while [ $iteration -gt 0 ]
do
    file=`echo $current_seed | cut -c1-3`.txt
    [ ! -f "$mumblr_dir/$file" ] && { echo "$mumblr_dir/$file does not exists"; break; }
    next_seed=`awk -v search="$current_seed" -F" " '$1==search { a[count] = $2; count++; } END { srand();print a[int(rand()*(count-1))+1] }' $mumblr_dir/$file`
    [ -z "$next_seed" ] && break
    current_seed="$next_seed"
    output="$output $next_seed"
    iteration=`expr $iteration - 1`
done

echo -en "Mumblr mumbles\n\n$output"

ENDTIME=$(date +%s)
ELAPSED=$(echo "scale=3; ($ENDTIME - $STARTTIME)/1000" | bc)

echo -e "\n\nElapsed Time: $ELAPSED seconds"
