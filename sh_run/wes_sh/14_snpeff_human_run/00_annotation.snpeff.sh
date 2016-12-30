#!/bin/bash

input_vcf=$1
output_prefix=$2
mkdir -p $output_prfix/tmp

date 
/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/snpEff.jar \
	-geneId \
	-c /BiO/BioTools/snpeff/snpEff_v4.1g/snpEff.config \
	-v hg19 \
        -s $output_prefix.snpeff.html \
	-o vcf \
	$input_vcf | \

/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	gwasCat -v - | \

/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	varType -v - | \

/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	annotate -noID -info COSMID -v /BiO/BioResources/DBs/COSMICDB/v71/CosmicCodingMuts.anno.vcf.gz - | \

/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	annotate -dbsnp -v - | \

/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	annotate -clinvar -v - | \

/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	dbNSFP -v - | \

/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	annotate -v /BiO/BioResources/DBs/EXAC/release0.3/ExAC.r0.3.sites.vep.header.vcf.gz | \

#/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
#	-Djava.io.tmpdir=/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-2/result/00_vcf_target_stat/tmp/ \
#	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
#	annotate -v /BiO/BioResources/DBs/KNIH/KNIH.BOTH.sort.out.herder.vcf.gz | \
        
/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx2g \
	-Djava.io.tmpdir=$output_prefix/tmp/ \
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	annotate -v /BiO/kjh/BioResources/DBs/KPGP/KPGP.38.20140427.header.vcf.gz  | sed "s/dbNSFP_GERP++/dbNSFP_GERP/g"| grep -v "hg38_chr" > $output_prefix.snpeff.vcf


cat $output_prefix.snpeff.vcf | /BiO/BioTools/snpeff/snpEff_v4.1g/scripts/vcfEffOnePerLine.pl | /BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx4g \
	-Djava.io.tmpdir=$output_prefix/tmp/\
	-jar /BiO/BioTools/snpeff/snpEff_v4.1g/SnpSift.jar \
	extractFields -e "." - CHROM POS ID REF ALT FILTER VARTYPE \
	"ANN[*].EFFECT" \
	"ANN[*].IMPACT" \
	"ANN[*].GENE" \
	"ANN[*].FEATURE" \
	"ANN[*].FEATUREID" \
	"ANN[*].BIOTYPE" \
	"ANN[*].RANK" \
	"ANN[*].HGVS_C" \
	"ANN[*].HGVS_P" \
	"ANN[*].CDNA_POS" \
	"ANN[*].CDNA_LEN" \
	"ANN[*].CDS_POS" \
	"ANN[*].CDS_LEN" \
	"ANN[*].AA_POS" \
	"ANN[*].AA_LEN" \
	"ANN[*].DISTANCE" \
	GWASCAT \
	COSMID \
	"CLNDSDBID" \
	"CLNORIGIN" \
	"CLNSIG" \
	"CLNDBN" \
	"dbNSFP_Uniprot_acc" \
	"dbNSFP_Interpro_domain" \
	"dbNSFP_SIFT_pred" \
	"dbNSFP_Polyphen2_HDIV_pred" \
	"dbNSFP_Polyphen2_HVAR_pred" \
	"dbNSFP_LRT_pred" \
	"dbNSFP_MutationTaster_pred" \
	"dbNSFP_GERP_NR" \
	"dbNSFP_GERP_RS" \
	"dbNSFP_phastCons100way_vertebrate" \
	"dbNSFP_1000Gp1_AF" \
	"dbNSFP_1000Gp1_AFR_AF" \
	"dbNSFP_1000Gp1_EUR_AF" \
	"dbNSFP_1000Gp1_AMR_AF" \
	"dbNSFP_1000Gp1_ASN_AF" \
	"dbNSFP_ESP6500_AA_AF" \
	"dbNSFP_ESP6500_EA_AF" \
	"EXAC_AC" \
	"EXAC_AN" \
	"EXAC_AF" \
	"KPGP_Alt_allele_frq" \
	> $output_prefix.snpeff.xls
date

