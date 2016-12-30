#!/bin/bash
project_path=/BiO/BioProjects/Axil-Human-WGS-2016-11-TBO160322-1/
sample_id=$1

target_bed=/BiO/BioResources/References/Human/hg19/targetkit/SureSelect_Human_All_Exon_V5.bed 
date
java -Xmx12g \
	-Djava.io.tmpdir=$project_path/result//13_gatk_unifiedgenotyper/$sample_id/tmp/ \
	-jar /BiO/BioTools/gatk/GenomeAnalysisTKLite-2.3-9.jar \
	-T UnifiedGenotyper \
	-stand_call_conf 30.0 \
	-stand_emit_conf 10.0 \
	-dcov 10000 \
	-I $project_path/result//12_gatk_printrecal/$sample_id/$sample_id\.printrecal.bam \
	-R /BiO/BioResources/References/Human/hg19/hg19.fa \
	--dbsnp /BiO/BioResources/References/Human/hg19/dbsnp_132.hg19.vcf \
	-o $project_path/result//13_gatk_unifiedgenotyper/$sample_id/$sample_id\.BOTH.vcf \
	-glm BOTH \
	-nt 4
python /home/shsong/work/Pipeline/dnaseq/script//allele_freq_plot.py \
    -i $project_path/result//13_gatk_unifiedgenotyper/$sample_id/$sample_id.BOTH.vcf \
    -o $project_path/result//13_gatk_unifiedgenotyper/$sample_id/$sample_id.BOTH.allele.frq 
date
