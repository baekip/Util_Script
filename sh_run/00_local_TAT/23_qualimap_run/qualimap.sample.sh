#!/bin/bash
project_path=/BiO/BioProjects/Genohub-Human-WES-2016-10-TBO160290-1/
sample_id=$1

date
unset DISPLAY
/BiO/BioTools/qualimap/qualimap_v2.0.1/qualimap bamqc \
	--java-mem-size=24G \
	-bam $project_path/result//07-1_picard_dedup/$sample_id/$sample_id.dedup.bam \
	-outdir $project_path/result//23_qualimap_run/$sample_id/ \
	-gff /BiO/BioResources/References/Human/hg19/targetkit/SureSelect_Human_All_Exon_V5.bed \
	-nt 8
date
