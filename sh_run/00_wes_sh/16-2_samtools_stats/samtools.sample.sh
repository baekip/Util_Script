#!/bin/bash
project_path=/BiO/BioProjects/Genohub-Human-WES-2016-10-TBO160290-2/
sample_id=$1
date

/BiO/BioTools/samtools/samtools-1.2/samtools stats \
    $project_path/result//16-1_samtools_uniqread/$sample_id/$sample_id.uniqread.bam > \
    $project_path//result//16-2_samtools_stats/$sample_id/$sample_id.uniqread.stats
date
