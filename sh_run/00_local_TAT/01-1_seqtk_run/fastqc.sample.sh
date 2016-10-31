#!/bin/bash
seqtk_path=/BiO/BioProjects/Spain-Human-WES-2016-10-TBO160321/result/01-1_seqtk_run
sample_id=$1

date
/BiO/BioTools/fastqc/FastQC_v0.10.1/fastqc \
    -t 2 \
    -o $seqtk_path/$sample_id/ \
    $seqtk_path/$sample_id/$sample_id\_1.fastq.gz

/BiO/BioTools/fastqc/FastQC_v0.10.1/fastqc \
    -t 2 \
    -o $seqtk_path/$sample_id/ \
    $seqtk_path/$sample_id/$sample_id\_2.fastq.gz

date
