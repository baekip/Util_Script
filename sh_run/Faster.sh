#!/bin/bash
seqtk_path=/BiO/BioProjects/Genohub-Human-WES-2016-10-TBO160290-1/result/01-1_seqtk_run/
sample_id=$1
fastq_1=$seqtk_path/$sample_id/$sample_id\_1.fastq.gz
fastq_2=$seqtk_path/$sample_id/$sample_id\_2.fastq.gz
/home/shsong/work/Pipeline/dnaseq/script/FasterFastqStatistics $fastq_1 $fastq_2
