#getwd()
#source("http://bioconductor.org/biocLite.R");biocLite("VariantAnnotation")
#library("VariantAnnotation")
args = commandArgs(TRUE)

working_dir <- "/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_close_vcf/"
setwd(working_dir)
CLOSE_path <- "/BiO/BioTools/CLOSE-CNV/CLOSE-master/CLOSE-R/"
vcf_path <- "/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_close_vcf//"
#vcf_path <- "/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_freebayes_result/"
#vcf_path <- "/BiO/BioPeople/brandon/test_CLOSE/data/"

setwd("/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_freebayes_result/")
#---------------------------------------------------------------------------------------------
control_id <- args[1]
case_id <- args[2]

control_id <- "TN1511D0286"  ##OV035_Tumor
case_id <- "TN1512D0673"    ##OV035_Normal

control_id <- "TN1511D0306"  ##OV044_Tumor
case_id <- "TN1511D0287-1"  ##OV044_Normal
#-----------------------------------------------------------------------------------------------------
control_vcf <- paste ( c(vcf_path,control_id,"/",control_id,".annotated.filtered3.vcf"),collapse="")
case_vcf <- paste ( c(vcf_path,case_id,"/",case_id,".annotated.filtered3.vcf"),collapse="")
case_vcf <- paste ( "/BiO/BioPeople/brandon/test_CLOSE/data/", "t.annotated.filtered3.vcf", sep="")
control_vcf <- paste ( "/BiO/BioPeople/brandon/test_CLOSE/data/", "n.annotated.filtered3.vcf", sep="")
#-----------------------------------------------------------------------------------------------------
#source_call
source("/BiO/BioTools/CLOSE-CNV/CLOSE-master/CLOSE-R/CRP.R")
source("/BiO/BioTools/CLOSE-CNV/CLOSE-master/CLOSE-R/subFunc.R")
#---------------------------------------------------------------------------------------------------
#VCFprep
source("http://bioconductor.org/biocLite.R"); biocLite("DPpackage")
library(DPpackage)
library(ggplot2)
VCFprep(control_vcf, case_vcf, filter=FALSE)
#--------------------------------------------------------------------------------------
CRP_PATH = "/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_close_vcf/"
codeDir <- "/BiO/BioTools/CLOSE/"
sampleName <- "OV056"
outDir <- "/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_close_vcf"
segment.file <- paste ( c(CRP_PATH,sampleName,"_segment.txt"),collapse="")
segment.file
CNstatus.txt <- paste ( c(sampleName,".CNstatus.txt"),collapse="")
CNstatus <- read.table(CNstatus.txt, header=TRUE, sep="\t")
LRR<-read.table("LRR.txt",header=TRUE,sep="\t")
BAF<-read.table("BAF.txt",header=TRUE,sep="\t")
#--------------------------------------------------------------------------------------
output <- read.table ("output.txt", header=TRUE, sep="\t")
input <- read.table (segment.file, header = TRUE, sep = "\t")

BAF
LAF <- BAFtoLAF(BAF.vec)
BAF_tmp <- cbind(BAF[,1:3],LAF )

head(BAF[,1:2], LAF)

LRR <- CNstatus[,c(1,2,5)]
CRP(input, codeDir, outDir, sampleName)

plotCNstatus.chr(CNstatus,BAF_tmp,LRR,sampleName)
plotCNstatus.WG(CNstatus,BAF,LRR,sampleName)
setwd()

#----------------------------------------------------
#runFalcon
Falcon.result<-runFalcon(output, sampleName, threshold=0.15)
#---------------------------------------------------
#LAF and LRR definition
BAF <- 1-as.numeric( output[,10] ) ## AAF <- output[,10] 
head(BAF)
head(output)
LAF<-BAFtoLAF(BAF)
LRR<-output[,11]
head(LRR)

run.result <- runDP(LAF,LRR,disp.param=0.45, max.iter=100, tolerance=.001)


#------------------------------------------------------------
#getCentroid
#1) segs.cluster
#2) Ncluster: number of clusters; third element of the list returned from runDP()

#--------------------------------------------------------------------
#call sequenza segmentation 
source("/BiO/BioTools/CLOSE/CLOSE-R/subFunc.R")
library(ggplot2)
paired_sample = "TN1511D0291_TN1511D0311"
CRP_input_file <- paste("/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_sequenza_result/",paired_sample,"/TEST/","Test_segments.txt",sep="")
CRP_input <- read.table(CRP_input_file, header=TRUE, sep="\t")
CRP_modified_input <- CRP_input [,c(1:4,7)]


seg_BAF <- CRP_input[,4]
seg_BAF
BAFtoLAF(seg_BAF)
head(CRP_modified_input)

codeDir <- "/BiO/BioTools/CLOSE-CNV/CLOSE-master/"
outDir <- "/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_sequenza_result/"
sampleName <-"OV_056"
BAF <- cbind(output[,1:2],BAF)
BAF
LRR <-cbind(output[,1:2],LRR)
LRR_digits <- round(output[,11],digits=0)
LRR <- cbind(output[,1:2],LRR_digits)

CRP(CRP_modified_input,codeDir,outDir,sampleName)
class(BAF)
class(LRR)

#---------------------------------------------------------------------
CNstatus_input <- paste(outDir,sampleName,".CNstatus.txt",sep="" ) 
CNstatus <- read.table(CNstatus_input, header=TRUE, sep="\t")
plotCNstatus.chr()
plotCNstatus.WG(CNstatus,BAF,LRR,sampleName)






