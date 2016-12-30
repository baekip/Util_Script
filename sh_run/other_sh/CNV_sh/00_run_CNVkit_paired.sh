#!/bin/sh

cnvkit_py=/BiO/BioTools/miniconda2/bin/cnvkit.py
project_path=/BiO/BioProjects/NCC-Human-Proton-2016-10-TBD160789/
normal_id=$1
tumor_id=$2
paired_id=$1\-$2
reference=/BiO/BioResources/References/Mouse/Ens_67_NCBIM37/M_musculus_Ens67.chr.fa
output_path=$project_path/result/00_CNV_run/$paired_id/
mkdir -p $output_path
normal_bam=$project_path/result/12_gatk_printrecal/$normal_id/$normal_id.printrecal.bam
tumor_bam=$project_path/result/12_gatk_printrecal/$tumor_id/$tumor_id.printrecal.bam
target_bed=/BiO/BioProjects/CUK-Mouse-2016-07-TBD160465/Sureselect_mouse_All_Exon_V1_revised.bed
refFlat_file=$project_path/result/00_CNV_run/data/refFlat.txt
access_bed=$project_path/access-5kb.mm9.bed

## From baits and tumor/normal BAMs
$cnvkit_py batch \
    $tumor_bam \
    --normal $normal_bam \
    --targets $target_bed \
    --annotate $refFlat_file \
    --fasta $reference \
    --access $access_bed \
    --output-reference $output_path/$paired_id\.cnn \
    --output-dir $paired_id/ \
    --diagram --scatter

 Reusing a reference for additional samples
$cnvkit_py batch \
    $tumor_bam \
    -r $output_path/$sample_id.cnn \
    -d $paired_id/

#change cns and cnr file name
mv $output_path/$tumor_id.cns $output_path/$paired_id.cns
mv $output_path/$tumor_id.cnr $output_path/$paired_id.cnr


# Copy number Call
cnvkit.py call \
    $output_path/$paired_id.cns \
    -m threshold \
    -t=-1.1,-0.4,0.3,0.7 \
    -o $output_path/$paired_id.call.cns

# Draw Scatter and Diagram plot
$cnvkit_py diagram \
    -s $output_path/$paired_id.cns \
    $output_path/$paired_id.cnr \
    -o $output_path/$paired_id-diagram.pdf

$cnvkit_py scatter \
    $output_path/$paired_id.cnr \
    -s $output_path/$paired_id.cns \
    -o $output_path/$paired_id-scatter.pdf

## Convert pdf to png
convert \
    -density 150 \
    $output_path/$paired_id-diagram.pdf \
    -quality 90 \
    $output_path/$paired_id-diagram.png

convert \
    -density 150 \
    $output_path/$paired_id-scatter.pdf \
    -quality 90 \
    $output_path/$paired_id-scatter.png

