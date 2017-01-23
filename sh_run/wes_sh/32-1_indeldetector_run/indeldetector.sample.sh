#!/bin/bash

normal_id=$1
tumor_id=$2
paired_id=$1\_$2
project_path=/BiO/BioProjects/SKKU_RNA-Seq_2016_10_Somatic/
indel_path=$project_path/result/32-1_indeldetector_run/$paired_id/
tmp_path=$indel_path/tmp/
mkdir -p $tmp_path
bam_path=$project_path/result/02_bam_file/
normal_bam=$bam_path/$normal_id\.bam
tumor_bam=$bam_path/$tumor_id\.bam
target_bed=/BiO/BioPeople/brandon/H_sapiens_ENS_72.chr.coding.merged.bed
log_file=$indel_path/$paired_id\.indel.log

exec > $log_file 2>&1

date
java -Xmx4g \
	-Djava.io.tmpdir=$tmp_path \
	-jar /BiO/BioTools/gatk/GenomeAnalysisTKLite-2.3-9.jar \
	-T SomaticIndelDetector \
	--reference_sequence /BiO/BioResources/References/Human/hg19/hg19.fa \
	--window_size 300 \
	--input_file:normal $normal_bam \
	--input_file:tumor $tumor_bam \
	--intervals /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/C0781661_Covered_revised_.bed \
	-rf BadCigar \
	-verbose $indel_path/$paired_id\.indeldetector.txt \
	-o $indel_path/$paired_id\.indeldetector.vcf \
	-nt 1

## PASS filter
grep "SOMATIC\|#" $indel_path/$paired_id\.indeldetector.vcf > $indel_path/$paired_id\.indeldetector.pass.vcf

ln -s $indel_path/$paired_id\.indeldetector.pass.vcf $indel_path/$paried\.INDEL.vcf
date
