#!/bin/bash
project_path=/BiO/BioProjects/Genohub-Human-WES-2016-10-TBO160290-2/
sample_id=$1
date
/BiO/BioTools/samtools/samtools-1.2/samtools view \
    -hb -q30 \
    $project_path/result//07-1_picard_dedup/$sample_id/$sample_id.dedup.bam > \
    $project_path/result//16-1_samtools_uniqread/$sample_id/$sample_id.uniqread.bam
/BiO/BioTools/samtools/samtools-1.2/samtools index \
    $project_path/result//16-1_samtools_uniqread/$sample_id/$sample_id.uniqread.bam \
    $project_path/result//16-1_samtools_uniqread/$sample_id/$sample_id.uniqread.bai
date
