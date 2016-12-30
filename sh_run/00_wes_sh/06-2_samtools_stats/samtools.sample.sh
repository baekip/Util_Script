#!/bin/bash
project_path=/BiO/BioProjects/Genohub-Human-WES-2016-10-TBO160290-2/
sample_id=$1
date
/BiO/BioTools/samtools/samtools-1.2/samtools stats \
    $project_path/result//06-1_picard_merge/$sample_id/$sample_id.merge.bam > \
    $project_path/result//06-2_samtools_stats/$sample_id/$sample_id.merge.stats
date
