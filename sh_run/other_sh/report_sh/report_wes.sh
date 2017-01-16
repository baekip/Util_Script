#!/bin/bash
wrapper_pl=/BiO/BioPeople/baekip/text2pdf/dev/wes/Variant_Resource/wrapper_report_wes.pl
wes_config=/BiO/BioProjects/Chicago-Human-WES-2016-04/wes_config.human.txt
wes_pipeline=/BiO/BioProjects/SGN-Human-WES-2015-10-TBO150020-2/wes_pipeline_config.human.overseas.txt

perl $wrapper_pl \
    $wes_config \
    $wes_pipeline 

