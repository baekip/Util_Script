#!/bin/bash
wrapper_pl=/BiO/BioPeople/baekip/text2pdf/dev/wes/WGS_Resource_Human/wrapper_report_wes.pl
wes_config=/bio/BioProjects/YSU-Human-WGS-2016-12-TBD160883/wgs_config.human.sentieon.txt
wes_pipeline=asd

perl $wrapper_pl \
    $wes_config \
    $wes_pipeline
