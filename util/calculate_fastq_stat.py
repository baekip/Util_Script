#!/usr/bin/python

import time
import sys
import re
import os
import glob
import commands
import argparse
from operator import itemgetter, attrgetter, methodcaller

def makedirectory(Dir):
    if not os.path.exists(Dir):
        os.system('mkdir -p %s' %Dir)

def run_program(input_path, sample_file, log_path, output_path):

    fastq_stat='/home/shsong//work/Pipeline/dnaseq/util/FasterFastqStatistics'

    with open(sample_file) as input_fp:
        for line in input_fp:
            units = line.strip().split()
            if line.startswith('#'):
                continue
            chg_id = units[0]
            tbi_id = units[1]
            list_input_1_file = []
            list_input_2_file = []
            for fastq_file in glob.glob('%s/%s/*.fastq.gz' %(input_path, chg_id)):
                if not 'single' in fastq_file:
                    if '_R1' in fastq_file:
                        tmp_fastq = fastq_file.split('_R1')
                        test_fastq = []
                        test_fastq.append(tmp_fastq[0])
                        test_fastq.append('_R1')
                        test_fastq.append(''.join(tmp_fastq[1:]))
                        list_input_1_file.append(test_fastq)
                    if '_R2' in fastq_file:
                        tmp_fastq = fastq_file.split('_R2')
                        test_fastq = []
                        test_fastq.append(tmp_fastq[0])
                        test_fastq.append('_R2')
                        test_fastq.append(''.join(tmp_fastq[1:]))
                        list_input_2_file.append(test_fastq)
                    if '_1' in fastq_file:
                        tmp_fastq = fastq_file.split('_1')
                        test_fastq = []
                        test_fastq.append(tmp_fastq[0])
                        test_fastq.append('_1')
                        test_fastq.append(''.join(tmp_fastq[1:]))
                        list_input_1_file.append(test_fastq)
                    if '_2' in fastq_file:
                        tmp_fastq = fastq_file.split('_2')
                        test_fastq = []
                        test_fastq.append(tmp_fastq[0])
                        test_fastq.append('_2')
                        test_fastq.append(''.join(tmp_fastq[1:]))
                        list_input_2_file.append(test_fastq)

            sort_list_input_1_file = sorted(list_input_1_file, key=itemgetter(0,2))
            sort_list_input_2_file = sorted(list_input_2_file, key=itemgetter(0,2))

            list_runoutput = []

            result_path = os.path.abspath('%s/%s/' %(output_path, tbi_id))
            sh_path = os.path.abspath('%s/%s/' %(log_path, tbi_id))
            makedirectory(result_path)
            makedirectory(sh_path)

            list_rawdata_1 = []
            list_rawdata_2 = []
            rawdata_1 = '%s/%s_R1.fastq.gz' %(result_path, tbi_id)
            rawdata_2 = '%s/%s_R2.fastq.gz' %(result_path, tbi_id)
            
            md5_file_1 = '%s/%s_R1.md5.txt' %(result_path, tbi_id)
            md5_file_2 = '%s/%s_R2.md5.txt' %(result_path, tbi_id)

            if len(list_input_1_file) == 1:
                os.system('ln -s %s %s' %(''.join(list_input_1_file[0]), rawdata_1))
                os.system('ln -s %s %s' %(''.join(list_input_2_file[0]), rawdata_2))
            else:
                for idx in range(0, len(sort_list_input_1_file)):
                    input_rawdata_1 = ''.join(sort_list_input_1_file[idx])
                    input_rawdata_2 = ''.join(sort_list_input_2_file[idx])

                    list_rawdata_1.append(input_rawdata_1)
                    list_rawdata_2.append(input_rawdata_2)

            sh_file = '%s/merge_stat.%s.sh' %(sh_path, chg_id)

            with open(sh_file, 'w') as output_fp:
                print >> output_fp, '#!/bin/bash'
                print >> output_fp, 'date'
                if len(list_rawdata_1) != 0:
                    print >> output_fp, 'cat %s > %s' %(' '.join(list_rawdata_1), rawdata_1)
                if len(list_rawdata_2) != 0:
                    print >> output_fp, 'cat %s > %s' %(' '.join(list_rawdata_2), rawdata_2)

                print >> output_fp, 'cd  %s ' %(result_path)
                print >> output_fp, 'md5sum %s_R1.fastq.gz > %s' %(tbi_id, md5_file_1)
                print >> output_fp, 'md5sum %s_R2.fastq.gz > %s' %(tbi_id, md5_file_2)

                for idx in range(0, len(sort_list_input_1_file)):
                    input_rawdata_1 = ''.join(sort_list_input_1_file[idx])
                    input_rawdata_2 = ''.join(sort_list_input_2_file[idx])

                    print >> output_fp, '%s %s %s' %(fastq_stat, input_rawdata_1, input_rawdata_2)
                print >> output_fp, 'date'
#            os.system('qsub -e %s -o %s -pe smp 2 -S /bin/bash %s' %(sh_path, sh_path, sh_file))
            print 'qsub -e %s -o %s -pe smp 2 -S /bin/bash %s' %(sh_path, sh_path, sh_file)

    return

def usage():
    message='''
python %s
python calculate_fastq_stat.py -i /BiO/BioPeople/shsong/Projects/WGS_test/C160006-P004/ -l /BiO/BioPeople/shsong/Projects/WGS_test/C160006-P004/sh_log/ -s sample.txt -o /BiO/BioPeople/shsong/Projects/WGS_test/C160006-P004/merge_file/
-i, --input_path : input data path
-l, --log_path : log path
-s, --sample : sample file
-o, --output_path : output path
    ''' %sys.argv[0]
    print message

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input_path')
    parser.add_argument('-l', '--log_path')
    parser.add_argument('-s', '--sample')
    parser.add_argument('-o', '--output_path')
    args = parser.parse_args()
    try:
        len(args.input_path) > 0
        len(args.log_path) > 0
        len(args.output_path) > 0

    except:
        usage()
        sys.exit(2)

    run_program(args.input_path, args.sample, args.log_path, args.output_path)
#    try:
#        run_program(args.input_path, args.sample, args.log_path, args.output_path)
#    except:
#        print 'ERROR'

if __name__ == '__main__':
    main()

