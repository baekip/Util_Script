#!/bin/bash
project_path=/BiO/BioProjects/AJU-Human-Insert-2016-11-TBD150410/
sample_id=$1

#-gff /BiO/BioResources/References/Human/hg19/targetkit/SureSelect_Human_All_Exon_V5.bed \
date
unset DISPLAY
/BiO/BioTools/qualimap/qualimap_v2.0.1/qualimap bamqc \
	--java-mem-size=24G \
	-bam $project_path/Result/$sample_id/05_dedup/$sample_id.dedup.bam \
	-outdir $project_path/Result/$sample_id/23_qualimap_run/$sample_id/ \
	-nt 8
date
