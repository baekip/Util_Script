#!/bin/sh
cnvkit_py=/BiO/BioTools/miniconda2/bin/cnvkit.py
project_path=/BiO/BioProjects/Ion_Torrent/NCC-Human-Proton-2016-12-TBD160222/Merged/
sample_id=$1
reference=/BiO/BioPeople/brandon/test_nextflow/proton_multisample_unifiedgenotyper/ref/hg19/hg19.fasta
cnvkit_path=/BiO/BioTools/cnvkit/
output_path=$project_path/00_CNV_run/$sample_id/
mkdir -p $output_path
bam_file=$project_path/02_bam_file/$sample_id\.bam
target_bed=/BiO/BioProjects/Ion_Torrent/NCC-Human-Proton-2016-12-TBD160222/Merged/IAD66243_167_Designed_PDY_revised.bed
access_bed=/BiO/BioTools/cnvkit/data/access-10kb.hg19.bed
refFlat_txt=/BiO/BioTools/cnvkit/data/refFlat.txt
gainloss_file=$output_path/$sample_id\.gene.gainloss
####0.Sequencing-accessible regions
####Make access.bed file
#date
#$cnvkit_py access \
#    $reference \
#    -s 5000 \
#    -o $access_bed 
#date
#
##1.If you have no normal samples to use for the reference, you can create a "flat" reference which assumes equeal coverage in all bins by using the --normal/-n flag without specifying any additional BAMfiles:
date
$cnvkit_py batch \
    -m amplicon \
    $bam_file \
    -n \
    -t $target_bed \
    -f $reference \
    --annotate $refFlat_txt \
    --output-reference $output_path/$sample_id\.cnn \
    -d $output_path
date
#
##2. segments
$cnvkit_py segment \
    $output_path/$sample_id\.cnr \
    -o $output_path/$sample_id\.cns


#2.copynumber call
date 
cnvkit.py call \
    $output_path/$sample_id\.cns \
    -m threshold \
    -t=-1.1,-0.4,0.3,0.7 \
    -o $output_path/$sample_id\.call.cns
date

##3.gainloss call
cnvkit.py gainloss \
    $output_path/$sample_id\.cnr \
    -s \
    $output_path/$sample_id\.call.cns \
    -t 0.4 \
    -m 5 \
    > $gainloss_file

#3.plot scatter diagram
# Optionally, with --scatter and --diagram
$cnvkit_py scatter \
    $output_path/$sample_id\.cnr \
    -s $output_path/$sample_id\.cns \
    -o $output_path/$sample_id-scatter.pdf
$cnvkit_py diagram \
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
