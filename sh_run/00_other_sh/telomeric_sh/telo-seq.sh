#!/bin/bash
sample_id=$1
project_path=/bio/BioProjects/YSU-Human-WGS-2016-12-TBD160883/
fastq_path=$project_path/result/01_fastqc_orig/$sample_id/
fastq_1=$fastq_path/$sample_id\_1.fastq
fastq_2=$fastq_path/$sample_id\_2.fastq
output_path=$project_path/result/00_telo-seq/
log_file=$output_path/$sample_id\.telo-seq.log
repeats=5
exec > $log_file 2>&1

echo "$fastq_1"
echo "$fastq_2"
/bio/BioTools/telo-seq/Telo-seq.pl $fastq_1 $fastq_2 $repeats  
