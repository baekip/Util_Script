#!/bin/sh

cnvkiy_py=/bio/BioTools/miniconda2/bin/cnvkit.py
project_path=/bio/BioProjects/YSU-Human-WGS-2016-12-TBD160883/
sample_id=$1
reference=/bio/BioResources/References/Human/hg19/hg19.fa
cnvkit_path=/bio/BioTools/cnvkit/
output_path=$project_path/result/00_CNV_run/$sample_id/
mkdir -p $output_path
bam_file=$project_path/result/00_CNV_run/bam_file/$sample_id\.bam
log_file=$output_path/$sample_id\.cnvkit.log
gainloss_file=$output_path/$sample_id\.gene.gainloss
refFlat_txt=/bio/BioProjects/YSU-Human-WGS-2016-12-TBD160883/result/00_CNV_run/refFlat.txt
access_bed=/bio/BioTools/cnvkit/cnvkit-0.8.1/data/access-5k-mappable.hg19.bed
exec >> $log_file 2>&1
#
#date
#echo "cnvkit run call"
cnvkit.py batch \
    -m wgs \
    $bam_file \
    -n -f $reference \
    -g $access_bed \
    --annotate $refFlat_txt \
    --output-reference $output_path/$sample_id\.cnn \
    -d $output_path

#2.copynumber call
date
echo "copynumber call" 
cnvkit.py call \
    $output_path/$sample_id\.cns \
    -m threshold \
    -t=-1.1,-0.4,0.3,0.7 \
    -o $output_path/$sample_id\.call.cns
date

##3.gainloss call
date
echo "gainloss call"
cnvkit.py gainloss \
    $output_path/$sample_id\.cnr \
    -s \
    $output_path/$sample_id\.call.cns \
    -t 0.4 \
    -m 5 \
    > $gainloss_file
date
#3.plot scatter diagram
# Optionally, with --scatter and --diagram
date
echo "output figure file" 
cnvkit.py scatter \
    $output_path/$sample_id\.cnr \
    -s $output_path/$sample_id\.cns \
    -o $output_path/$sample_id-scatter.pdf

cnvkit.py diagram \
    $output_path/$sample_id\.cnr \
    -s $output_path/$sample_id\.cns \
    -o $output_path/$sample_id-diagram.pdf

convert -density 150 \
    $output_path/$sample_id\-diagram.pdf \
    -quality 90 \
    $output_path/$sample_id\-diagram.png

convert -density 150 \
    $output_path/$sample_id\-scatter.pdf \
    -quality 90 \
    $output_path/$sample_id\-scatter.png
date
