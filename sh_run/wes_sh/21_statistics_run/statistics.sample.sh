#!/bin/bash
project_path=/BiO/BioProjects/Axil-Human-WGS-2016-11-TBO160322-1/
sample_id=$1

date
python /home/shsong/work/Pipeline/dnaseq/script//statistics_run.py \
	-f $project_path/result//20_statistics_fastq_run/$sample_id/ \
	-m $project_path/result//06-2_samtools_stats/$sample_id/$sample_id\.merge.stats \
	-d $project_path/result//07-2_samtools_stats/$sample_id/$sample_id\.dedup.stats \
	-u $project_path/result//16-2_samtools_stats/$sample_id/$sample_id\.uniqread.stats \
	-q $project_path/result//23_qualimap_run/$sample_id/genome_results.txt \
	-o $project_path/result//21_statistics_run/$sample_id/$sample_id\.statistics.xls \
	-r /BiO/BioResources/References/Human/hg19/hg19.fa \
	-p /BiO/BioTools/samtools/samtools-1.2/samtools \
	-n WGS \
	-g $project_path/result//14_snpeff_human_run/$sample_id/$sample_id\.BOTH.snpeff.tsv.tmp \
	-s $sample_id
date
