# Genome Data Processing with Apache Spark

This homework integrates Spark to perform genome analysis with ADAM library/toolkit. ADAM is built on Spark. 

## Running ADAM transformation on Y chromosome data set

After setting up Apache Spark cluster on four nodes on SoftLayer, run ADAM transformation on Apache Spark as a local instance

```
adam-submit --master local vcf2adam genedata/all.y.vcf genedata/all.y.adam
``` 

### Run time

```
[root@spark1 ~]# time adam-submit --master local vcf2adam /root/genedata/all.y.vcf /root/genedata/all.y.adam > adam.log 2>&1

real	10m45.380s
user	11m6.325s
sys	0m1.840s
```

### Output

```
[root@spark1 genedata]# pwd
/root/genedata
[root@spark1 genedata]# ls -ltr all.y.adam
total 14724
-rw-r--r-- 1 root root 2900343 Aug  6 03:29 part-r-00000.gz.parquet
-rw-r--r-- 1 root root 2968204 Aug  6 03:31 part-r-00001.gz.parquet
-rw-r--r-- 1 root root 2963102 Aug  6 03:33 part-r-00002.gz.parquet
-rw-r--r-- 1 root root 2919260 Aug  6 03:35 part-r-00003.gz.parquet
-rw-r--r-- 1 root root 2884323 Aug  6 03:37 part-r-00004.gz.parquet
-rw-r--r-- 1 root root  350001 Aug  6 03:38 part-r-00005.gz.parquet
-rw-r--r-- 1 root root       0 Aug  6 03:38 _SUCCESS
-rw-r--r-- 1 root root   40064 Aug  6 03:38 _metadata
-rw-r--r-- 1 root root   10688 Aug  6 03:38 _common_metadata
```

### Log files

* Command line log file is available at [adam.log](adam.log)
* Spark master and worker node logs are available at [spark-logs](spark-logs)   