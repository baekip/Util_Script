#!/bin/bash
project_path=/BiO/BioProjects/Genohub-Human-WES-2016-10-TBO160290-1/
sample_id=$i
date
/BiO/BioTools/java/jre1.7.0_51/bin/java -Xmx24g \
	-Djava.io.tmpdir=$project_path/result//07-1_picard_dedup/$sample_id/tmp/ \
	-XX:ParallelGCThreads=8 \
	-jar /BiO/BioTools/picard/picard-tools-1.98//MarkDuplicates.jar \
	INPUT=$project_path/result//06-1_picard_merge/$sample_id/$sample_id.merge.bam \
	OUTPUT=$project_path//result//07-1_picard_dedup/$sample_id/$sample_id.dedup.bam \
	M=$project_path/result//07-1_picard_dedup/$sample_id/$sample_id.dedup.txt \
	VALIDATION_STRINGENCY=LENIENT \
	REMOVE_DUPLICATES=true \
	CREATE_INDEX=true


md5sum $project_path/result//07-1_picard_dedup/$sample_id/$sample_id.dedup.bam > $project_path/result//07-1_picard_dedup/$sample_id/$sample_id.dedup.md5.txt
date
