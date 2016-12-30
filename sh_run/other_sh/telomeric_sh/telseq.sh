#!/bin/bash
#example command: telseq -H a.bam b.bam c.bam > myresult

sample_id=$1
project_path=/bio/BioProjects/YSU-Human-WGS-2016-12-TBD160883/
bam_path=$project_path/result/00_CNV_run/bam_file/
bam_file=$bam_path/$sample_id\.bam
output_path=$project_path/result/00_telo-seq/$sample_id/
mkdir -p $output_path
output=$output_path/$sample_id\.telseq.result
log_file=$output_path/$sample_id\.telseq.log
repeats=5
exec > $log_file 2>&1

/bio/BioTools/telseq/bin/linux/telseq $bam_file > $output  
