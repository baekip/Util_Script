#getwd()
#source("http://bioconductor.org/biocLite.R");biocLite("VariantAnnotation")
#library("VariantAnnotation")
args = commandArgs(TRUE)
CLOSE_path <- "/BiO/BioTools/CLOSE-CNV/CLOSE-master/CLOSE-R/"
project_path <- "/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-2/"
result_path <- paste( project_path, "/result/", sep="")
#setwd(project_path)
#setwd("/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-2/result/00_freebayes_result/")
#---------------------------------------------------------------------------------------------
#Example
#control_id <- "TN1511D0287-1"
#case_id <- "TN1511D0306"
#sampleName <- "OV_044"
control_id <- args[1]  #normal
case_id <- args[2]  #tumor
sampleName <- args[3]  #sample name
#-----------------------------------------------------------------------------------------------------
#call Rsource and requirement library
#source("http://bioconductor.org/biocLite.R"); biocLite("DPpackage")
library(DPpackage)
library(ggplot2)
source("/BiO/BioTools/CLOSE-CNV/CLOSE-master/CLOSE-R/CRP.R")
#source("/BiO/BioTools/CLOSE-CNV/CLOSE-master/CLOSE-R/subFunc.R")
source("/BiO/BioTools/CLOSE-CNV/CLOSE-master/CLOSE-R/subFunc_modified.R")
#--------------------------------------------------------------------------------------
#call basic requirement file and path
codeDir <- "/BiO/BioTools/CLOSE/"
outDir <- paste(result_path,"/00_close_result/",sep="")
pair_id <- paste(control_id,"_",case_id, sep="")
cmd_pair_dir <- paste("mkdir -p ",outDir,pair_id,sep="")
system(cmd_pair_dir)
segment.file <- paste(result_path,"00_sequenza_result/",pair_id,"/",pair_id,"/",sampleName,"_segments.txt",sep="")
#LRR<-read.table("LRR.txt",header=TRUE,sep="\t")
#BAF<-read.table("BAF.txt",header=TRUE,sep="\t")
#-----------------------------------------------------------------------------------------------
##Call VCFprep
#freebayes_path <- paste(result_path,"/00_freebayes_result",sep="")
#free_control_vcf <- paste(freebayes_path,"/",control_id,".freebayes.vcf",sep="")
#free_case_vcf <-paste(freebayes_path,"/",case_id,".freebayes.vcf",sep="")
outDir <- paste(result_path,"/00_close_result/",pair_id,"/",sep="")
setwd(outDir)
close_vcf_path <- paste(result_path,"/00_close_vcf/",sep="")
control_vcf <- paste ( c(close_vcf_path,control_id,"/",control_id,".annotated.filtered3.vcf"),collapse="")
case_vcf <- paste ( c(close_vcf_path,case_id,"/",case_id,".annotated.filtered3.vcf"),collapse="")
VCFprep(control_vcf,case_vcf, filter=FALSE)
#VCFprep(control_vcf, case_vcf, filter=FALSE)
#------------------------------------------------------------------------------------------------
#Definition of LAF and LRR 
#Run CRP.R 
input_tmp <- read.table(segment.file, header = TRUE, sep = "\t")
LRR_tmp <- log2(input_tmp[,7])
input <- cbind(input_tmp[,1:4],LRR_tmp)
#outDir <- paste(result_path,"/00_close_result/",pair_id,"/",sep="")
#setwd(outDir)
#LRR <- CNstatus[,c(1,2,5)]
#LRR_digits <- round(output[,11],digits=0)
CRP(input, codeDir, outDir, sampleName)
#----------------------------------------------------
#BAFtoLAF(seg_BAF)
#Run plotCNstatus figure
#plotCNstatus.chr(CNstatus,BAF,LRR,sampleName)
#replace CN Neutral LOH to CN_Neutral_LOH 
#replace "chr" to ""
#/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-2/result/00_close_result/TN1511D0286_TN1512D0673
output_path <- paste(result_path,"/00_close_result/",pair_id,"/",sep="")
output_file <- paste(output_path,"output.txt",sep="")
output <- read.table(output_file,header=TRUE,sep="\t")
LRR <- output[,c(1:2,11)]
BAF <- output[,c(1:2,10)]
#BAF <- cbind(output[,1:2],1-output[,10])
CNstatus.txt <- paste(c(outDir,sampleName,".CNstatus.txt"),collapse="")
CNstatus <- read.table(CNstatus.txt, header=TRUE, sep=" ")
plotCNstatus.WG(CNstatus,BAF,LRR,sampleName)
plotCNstatus.chr(CNstatus,BAF,LRR,sampleName)
#---------------------------------------------------------------------
#CNstatus_input <- paste(outDir,sampleName,".CNstatus.txt",sep="" ) 
#CNstatus <- read.table(CNstatus_input, header=TRUE)
#plotCNstatus.chr(CNstatus,BAF,LRR,sampleName)
#plotCNstatus.WG(CNstatus,BAF,LRR,sampleName)
