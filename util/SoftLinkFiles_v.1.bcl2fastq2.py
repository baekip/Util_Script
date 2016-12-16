#!/usr/bin/python
import sys, gzip, subprocess, getopt, os, commands, socket, paramiko, glob
from paramiko import SSHClient,AutoAddPolicy
import smtplib
from email.MIMEText import MIMEText
import xlwt
import xlsxwriter
import os
from collections import Counter
import argparse


def define_index(fastq_file):
    list_index = []
    with gzip.open(fastq_file) as input_fp:
        count = 0
        for line in input_fp:
            units = line.strip().split()
            if count == 0:
#                print units
                item_index = units[1]
                index_info = item_index.split(':')[-1]
#                print index_info
                list_index.append(index_info)
            count += 1

            if count == 4:
                count = 0

            if len(list_index) == 20000:
                break

    count = Counter(list_index)
    most_index = count.most_common()[0][0]
#    print count.most_common()
#    print most_index
    return most_index

def getAbsPathDir(_fileName):
    absPathFileName = os.path.abspath(_fileName)
    absPathDir = absPathFileName[:absPathFileName.rfind("/") + 1]
    return absPathDir

def getFileName(_fileName):
    absPathFileName = os.path.abspath(_fileName)
    fileName = absPathFileName[absPathFileName.rfind("/") + 1:]
    return fileName

def setFastqPairing(_fastqList, _splitList, _outDir):
    fastqFirstList = []
    fastqFirstFltList = []
    fastqLastList = []
    fastqLastFltList = []
    filterResultList = []
    for fastq in sorted(_fastqList):
        filename = getFileName(fastq)

        fastqFlt = None
        if filename.find("fastq") != -1: fastqFlt = _outDir + filename.replace("fastq", "flt.fastq")
        elif filename.find("fq") != -1: fastqFlt = _outDir + filename.replace("fq", "flt.fq")

        if filename.find(_splitList[0]) != -1:
            fastqFirstList.append(fastq)
            fastqFirstFltList.append(fastqFlt)
            filterResultList.append(fastqFlt + ".rst.xls")
        elif filename.find(_splitList[1]) != -1:
            fastqLastList.append(fastq)
            fastqLastFltList.append(fastqFlt)
    return fastqFirstList, fastqFirstFltList, fastqLastList, fastqLastFltList, filterResultList

def makedirectory(_dir):
    if not os.path.exists(_dir):
        os.system("mkdir -p %s" %_dir)
    return

def link_fastq(sample_file, flowcell_file, link_dir):
    
    list_flowcell = []
    print flowcell_file
    if flowcell_file == "*":
        list_flowcell.append('*')
    else:
        with open(flowcell_file) as input_fp:
            for line in input_fp:
                units = line.strip().split()
                flowcell = units[0]
                list_flowcell.append(flowcell)

    list_sample_id = []
    with open(sample_file) as input_fp:
        for line in input_fp:
            units = line.strip().split()
            sample_id = units[0]
            list_sample_id.append(sample_id)

    abspath = os.path.abspath("./")

    SummaryFile = link_dir + "/Sequencing_Statistics_Result.xlsx"
    xls_SummaryFile = link_dir + "/Sequencing_Statistics_Result.xls"
    output_fp = open(xls_SummaryFile, 'w')

    book = xlsxwriter.Workbook(SummaryFile)
    sheet1 = book.add_worksheet('Sequencing Result')

    colalign = book.add_format({'align' : 'center', 'valign' : 'center'})
    
    sheet1.set_column(0,0,13, colalign)
    sheet1.set_column(1,1,11, colalign)
    sheet1.set_column(2,2,11, colalign)
    sheet1.set_column(3,3,13, colalign)
    sheet1.set_column(4,4,15, colalign)
    sheet1.set_column(5,5,11, colalign)
    sheet1.set_column(6,6,9, colalign)
    sheet1.set_column(7,7,13, colalign)
    sheet1.set_column(8,8,18, colalign)
    sheet1.set_column(9,9,14, colalign)
    sheet1.set_column(10,10,19, colalign)
    sheet1.set_column(11,11,9, colalign)
    sheet1.set_column(12,12,8, colalign)
    sheet1.set_column(13,13,17, colalign)
    sheet1.set_column(14,14,20, colalign)
    sheet1.set_column(15,15,17, colalign)
    sheet1.set_column(16,16,20, colalign)
    
    sheet1table = []

    sheet1header = [{'header' : 'SampleID'},
            {'header' : 'Index'},
            {'header' : 'TotalReads'},
            {'header' : 'TotalBases'},
            {'header' : 'TotalBases(Gb)'},
            {'header' : 'GC_Count'},
            {'header' : 'GC_Rate'},
            {'header' : 'N_ZeroReads'},
            {'header' : 'N_ZeroReadsRate'},
            {'header' : 'N5_LessReads'},
            {'header' : 'N5_LessReadsRate'},
            {'header' : 'N_Count'},
            {'header' : 'N_Rate'},
            {'header' : 'Q30_MoreBases'},
            {'header' : 'Q30_MoreBasesRate'},
            {'header' : 'Q20_MoreBases'},
            {'header' : 'Q20_MoreBasesRate'}]

    output_header = []
    for item in sheet1header:
        print item['header']
        output_header.append(str(item['header']))
    print >> output_fp, '\t'.join(output_header)


    RowCnt = 1
    for sample_id in list_sample_id:
        ProjectFolderList = []
        for flowcell_dir in list_flowcell:
            tmp_list= glob.glob("/BiO/%s/Unaligned/T*" %flowcell_dir)
            for _dir in tmp_list:
                ProjectFolderList.append(_dir)
        count = 1
        sample_count = 0
        for ProjectFolder in ProjectFolderList :
            dir_project_id = os.path.basename(ProjectFolder)
            SampleFileList = glob.glob(ProjectFolder + "/%s*.fastq.gz" %sample_id)
#            print SampleFileList
            if len(SampleFileList) == 0:
                continue
            for SampleFile in SampleFileList:
                SampleFileName = SampleFile.split("/")[-1]
                SampleID = SampleFileName.split("_")[0]
                makedirectory("%s/%s" %(link_dir, sample_id))
                LinkFileName = SampleFileName.replace(SampleID, SampleID + "-%d" % count)
                os.system("ln -s %s %s/%s/%s" % (SampleFile, link_dir, sample_id, LinkFileName))
                tmp_fastq = SampleFileList[0]
                sample_count += 1
            count += 1
        if sample_count != 0:
            index_ID = define_index(tmp_fastq)
            ResultFileList = []
            for flowcell_dir in list_flowcell:
                tmp_list = glob.glob("/BiO/%s/Unaligned/*/%s*.result" %(flowcell_dir, sample_id))
                for _dir in tmp_list:
                    ResultFileList.append(_dir)

            print sample_id 
            print ResultFileList
            TotalReadCnt = 0
            TotalLength = 0
            TotalGCCnt = 0
            NZeroReadCnt = 0
            N5ReadCnt = 0
            TotalNCnt = 0
            TotalQ30 = 0
            TotalQ20 = 0
            for ResultFile in ResultFileList :
                subf = open (ResultFile, 'r')
                for stats in subf.xreadlines() :
                    if not stats[0] == "#" :
                        words = stats.split("\t")
                        TotalReadCnt += int(words[0])
                        TotalLength += int(words[1])
                        TotalGCCnt += int(words[3])
                        NZeroReadCnt += int(words[5])
                        N5ReadCnt += int(words[7])
                        TotalNCnt += int(words[9])
                        TotalQ30 += (int(words[19]) + int(words[21]))
                        TotalQ20 += (int(words[23]) + int(words[25]))
                subf.close()
            TotalLengthGB = "%.2f Gb" % (TotalLength * 1.0 / 1000000000)
            GCRate = TotalGCCnt * 100.0 / TotalLength
            NzRate = NZeroReadCnt * 100.0 / TotalReadCnt
            N5Rate = N5ReadCnt * 100.0 / TotalReadCnt
            TotalNRate = TotalNCnt * 100.0 / TotalLength
            TotalQ30Rate = TotalQ30 * 100.0 / TotalLength
            TotalQ20Rate = TotalQ20 * 100.0 / TotalLength

            sheet1outline = []
#        print line.rstrip().split("\t")[0]
            sheet1outline.append(sample_id)
            sheet1outline.append(str(index_ID))
            sheet1outline.append(str(TotalReadCnt))
            sheet1outline.append(str(TotalLength))
            sheet1outline.append(str(TotalLengthGB))
            sheet1outline.append(str(TotalGCCnt))
            sheet1outline.append(str("%.2f%%" % GCRate))
            sheet1outline.append(str(NZeroReadCnt))
            sheet1outline.append(str("%.2f%%" % NzRate))
            sheet1outline.append(str(N5ReadCnt))
            sheet1outline.append(str("%.2f%%" % N5Rate))
            sheet1outline.append(str(TotalNCnt))
            sheet1outline.append(str("%.2f%%" % TotalNRate))
            sheet1outline.append(str(TotalQ30))
            sheet1outline.append(str("%.2f%%" % TotalQ30Rate))
            sheet1outline.append(str(TotalQ20))
            sheet1outline.append(str("%.2f%%" % TotalQ20Rate))
            RowCnt += 1
            sheet1table.append(sheet1outline)
            print >> output_fp, '\t'.join(sheet1outline)

#    print RowCnt
    sheet1.add_table(0,0,(RowCnt-1),16,{'data' : sheet1table, 'columns' : sheet1header, 'style': 'Table Style Light 15', 'autofilter': False, 'banded_rows': 0})

    book.close()
    output_fp.close()

def usage():
    message='''
python %s

-s, --sample    : sample list file
-f, --flowcell  : flowcell list file (default : "*")
-o, --outputdir : link file directory (default : ./)

##optional
-o, --output : default(output.xlsx)
''' %sys.argv[0]
    print message

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--sample')
    parser.add_argument('-f', '--flowcell', default="*")
    parser.add_argument('-o', '--outputdir', default="./")
    args = parser.parse_args()
    try:
        len(args.sample) > 0

    except:
        usage()
        sys.exit(2)

    link_fastq(args.sample, args.flowcell, args.outputdir)

if __name__ == '__main__':
    main()
