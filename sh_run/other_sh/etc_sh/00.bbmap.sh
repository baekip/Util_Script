#!/bin/sh
#bbsplit.sh ref=x.fa,y.fa in1=read1.fq in2=read2.fq basename=o%_#.fq
#server snake
sample_id=$1
bbsplit=/BiO/BioTools/bbmap/bbsplit.sh
project_path=/BiO/BioProjects/AURAGEN-Xenograft-WES-2016-11-TBO160349-1/
human_fa=/BiO/BioProjects/AURAGEN-Xenograft-WES-2016-11-TBO160349-1/rawdata/human.fa
mouse_fa=/BiO/BioProjects/AURAGEN-Xenograft-WES-2016-11-TBO160349-1/rawdata/mouse.fa
fastq_path=$project_path/rawdata/$sample_id/
fastq_R1=$fastq_path/$sample_id\_1.fastq.gz
fastq_R2=$fastq_path/$sample_id\_2.fastq.gz
pattern_name=$fastq_path/$sample_id
log_file=$fastq_path/$sample_id\.bbmap.log

exec >$log_file 2>&1

$bbsplit \
    ref=$human_fa,$mouse_fa \
    in1=$pattern_name\_1.fastq.gz \
    in2=$pattern_name\_2.fastq.gz \
    basename=$pattern_name\%_#.fastq.gz


#qsub -V -e $fastq_path \
#    -o $fastq_path\
#    -S /bin/bash "$bbsplit ref=$human_fa,$mouse_fa in1=$pattern_name\_1.fastq.gz in2=$pattern_name\_2.fastq.gz basename=$pattern_name\%_#.fastq.gz"
#
