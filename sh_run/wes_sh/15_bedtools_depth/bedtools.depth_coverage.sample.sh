#!/bin/bash
project_path=/BiO/BioProjects/Axil-Human-WGS-2016-11-TBO160322-1/
sample_id=$1
date
/BiO/BioTools/bedtools/bedtools-2.17.0/bin/bedtools coverage \
    -abam $project_path/result//07-1_picard_dedup/$sample_id/$sample_id.dedup.bam \
    -b /BiO/BioResources/References/Human/hg19/targetkit/SureSelect_Human_All_Exon_V5.bed \
    -d > $project_path/result//15_bedtools_depth/$sample_id/$sample_id.dedup.bam.depth
/BiO/BioTools/bedtools/bedtools-2.17.0/bin/bedtools coverage \
    -abam $project_path/result//07-1_picard_dedup/$sample_id/$sample_id.dedup.bam \
    -b /BiO/BioResources/References/Human/hg19/targetkit/SureSelect_Human_All_Exon_V5.bed > \
    $project_path/result//15_bedtools_depth/$sample_id/$sample_id.dedup.bam.coverage
date
