#!/bin/bash
date
java -Xmx3g \
	-Djava.io.tmpdir=/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//32-1_indeldetector_run/TN1511D0287_TN1511D0306/tmp/ \
	-jar /BiO/BioTools/gatk/GenomeAnalysisTKLite-2.3-9.jar \
	-T SomaticIndelDetector \
	--reference_sequence /BiO/BioResources/References/Human/hg19/hg19.fa \
	--window_size 300 \
	--input_file:normal /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//12_gatk_printrecal/TN1511D0287/TN1511D0287.printrecal.bam \
	--input_file:tumor /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//12_gatk_printrecal/TN1511D0306/TN1511D0306.printrecal.bam \
	--intervals /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/C0781661_Covered_revised_.bed \
	-rf BadCigar \
	-verbose /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//32-1_indeldetector_run/TN1511D0287_TN1511D0306//TN1511D0287_TN1511D0306.indeldetector.txt \
	-o /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//32-1_indeldetector_run/TN1511D0287_TN1511D0306//TN1511D0287_TN1511D0306.indeldetector.vcf \
	-nt 1

## PASS filter
grep "SOMATIC\|#" /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//32-1_indeldetector_run/TN1511D0287_TN1511D0306//TN1511D0287_TN1511D0306.indeldetector.vcf > /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//32-1_indeldetector_run/TN1511D0287_TN1511D0306//TN1511D0287_TN1511D0306.indeldetector.pass.vcf

ln -s /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//32-1_indeldetector_run/TN1511D0287_TN1511D0306//TN1511D0287_TN1511D0306.indeldetector.pass.vcf /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result//32-1_indeldetector_run/TN1511D0287_TN1511D0306//TN1511D0287_TN1511D0306.INDEL.vcf
date
