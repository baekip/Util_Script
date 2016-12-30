#!/bin/bash

normal_id=$1
tumor_id=$2
paired_id=$1\_$2
project_path=/BiO/BioProjects/SKKU_RNA-Seq_2016_10_Somatic/
mutect_path=$project_path/result/30-1_mutect_run/$paired_id/
tmp_path=$mutect_path/tmp/
mkdir -p $tmp_path
bam_path=$project_path/result/02_bam_file/
normal_bam=$bam_path/$normal_id\.bam
tumor_bam=$bam_path/$tumor_id\.bam
target_bed=/BiO/BioPeople/brandon/H_sapiens_ENS_72.chr.coding.merged.bed

date
/usr/bin/java -Xmx3g \
    -Djava.io.tmpdir=$tmp_path \
    -jar /BiO/BioTools/mutect/muTect-1.1.4/muTect-1.1.4.jar \
    --analysis_type MuTect \
    --reference_sequence /BiO/BioResources/References/Human/hg19/hg19.fa \
    --cosmic /BiO/BioResources/DBs/COSMICDB/v71/CosmicCodingMuts.anno.vcf.gz \
    --dbsnp /BiO/BioResources/References/Human/hg19/dbsnp_132.hg19.vcf \
    --input_file:normal $normal_bam \
    --input_file:tumor $tumor_bam \
    -rf BadCigar \
    -dcov 10000 \
    --out $mutect_path/$paired_id\.mutect.txt \
    --vcf $mutect_path/$paired_id\.mutect.vcf \
    --coverage_file $mutect_path/$paired_id\.mutect.wig \
    --intervals $target_bed \
    -nt 1
date

## PASS filter
grep -v "REJECT" $mutect_path/$paired_id\.mutect.vcf > $mutect_path/$paired_id\.mutect.pass.vcf
