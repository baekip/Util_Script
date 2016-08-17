#setwd("/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/00_sequenza_result/")
#setwd("/Users/Baek/Desktop/Sequenza_result")

#####################################
#Mar-8 2016
#CBU paired Normal Purity Calculation 
######################################

options(warn=-1)

#source("http://www.bioconductor.org/biocLite.R");biocLite("sequenza")
library(sequenza)

#data.file <- system.file ("data","example.seqz.txt.gz",package="sequenza")
#sequenza_data_path <- "/Library/Frameworks/R.framework/Resources/library/sequenza/data/"
#sample_id <- "kwon_1"
#seqz_id = paste (c(sample_id,"_out.seqz.gz"),collapes="")
#--------------------------------------------------
#1.Prepared Data Set

args = commandArgs(TRUE)
sample_id = args[1]
patient_id = args[2]
sample_id
#sample_id <- "kwon_1"
#sample_id <- "TN1511D0286_TN1512D0673"

seqz_file <- paste( c(sample_id,".out.seqz.gz"), collapse = "")
data.file <- system.file ("data", seqz_file, package="sequenza" )
project_path <- "/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-2/"
output_path <- paste ( c(project_path, "/result/00_sequenza_result/", sample_id, "/"), collapse="")
setwd(output_path)

#data.file <- system.file ("data", "example.seqz.txt.gz",package = "sequenza")
#data.file <- system.file ("/BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-2/result/00_sequenza_result/TN1511D0286_TN1512D0673/", "TN1511D0286_TN1512D0673/TN1511D0286_TN1512D0673.out.seqz.gz",package = "sequenza")

seqz.data <- read.seqz (data.file)

#--------------------------------------------------
#2. Normalization of Depth Ratio
#gc.stats <- gc.sample.stats(data.file)
gc.stats <- gc.norm( x= seqz.data$depth.ratio,
                     gc=seqz.data$GC.percent)
gc.vect <- setNames(gc.stats$raw.mean,gc.stats$gc.values)
seqz.data$adjusted.ratio <- seqz.data$depth.ratio /
  gc.vect[as.character(seqz.data$GC.percent)]

GC.contents.png.file <- paste( c(sample_id, "_GC_contents.png"), collapse = "")
png(GC.contents.png.file)

par(mfrow = c(1,2), cex = 1, las = 1, bty = 'l')
matplot(gc.stats$gc.values, gc.stats$raw,
        type='b', col=1, pch=c(1,19,1), lty=c(2,1,2),
        xlab = 'GC content (%)' , ylab = 'Uncorrected depth ratio')
legend('topright', legend = colnames(gc.stats$raw), pch = c(1, 19, 1))
hist2(seqz.data$depth.ratio, seqz.data$adjusted.ratio,
      breaks = prettyLog, key = vkey, panel.first = abline(0,1, lty=2),
      xlab = 'Uncorrectedd depth ratio', ylab = 'GC-adjusted depth ratio')

dev.off()
#GC save contents PNG 


#----------------------------------------------------------------------------
#5.Analyzing sequencing data with sequenza

test <- sequenza.extract (data.file)
names(test)

##5.1.1 Plot chromosome view with mutations, BAF, depth ratio and segments

for ( i in 1:24){
  chrom.png.file = paste (c(sample_id,"_chr",i,"_copynumber_profile.png"),collapse = "")
  png (chrom.png.file)
  chromosome.view(mut.tab = test$mutations[[i]], baf.windows=test$BAF[[i]],
                  ratio.windows=test$ratio[[i]], min.N.ratio=1,
                  segments=test$segments[[i]], main=test$chromosomes[i])
  dev.off()
}

#5.2 Inference of cellularity and ploidy
CP.example <- sequenza.fit (test)

#5.3 Results of model fitting 
sequenza.results (sequenza.extract = test, cp.table = CP.example,
                  sample.id = patient_id, out.dir = sample_id)
##5.3.1 Confidence intervals, confidence region and point estimate
cint <- get.ci(CP.example)

CP.plot.png.file <- paste( c(sample_id, "_CP_plot.png"), collapse = "")
png(CP.plot.png.file) 
cp.plot (CP.example)
cp.plot.contours(CP.example, add=TRUE, likThresh = c(0.95))
dev.off()

#------------------------------------------------------------------------
#Figure4. Plot of the log posterior porbability with respective cellularity and ploidy probaility distribution and confidence intervals
Plot.of.the.log.posterior.png.file <- paste ( c(sample_id, "_Plot.of.the.log.posterior.png"))
png(Plot.of.the.log.posterior.png.file)
par(mfrow = c(2,2))
cp.plot(CP.example)
cp.plot.contours(CP.example, add = TRUE)
plot(cint$values.cellularity, ylab = "Cellularity",
     xlab = "posterior probability", type = "n")
select <- cint$confint.cellularity[1] <= cint$values.cellularity[,2] &
  cint$values.cellularity[,2] <= cint$confint.cellularity[2]
polygon(y = c(cint$confint.cellularity[1], cint$values.cellularity[select, 2], cint$confint.cellularity[2]), 
        x = c(0, cint$values.cellularity[select, 1], 0), col='red', border=NA)
lines(cint$values.cellularity)
abline(h = cint$max.cellularity, lty = 2, lwd = 0.5)  

plot(cint$values.ploidy, xlab = "Ploidy",
     ylab = "posterior probability", type = "n")
select <- cint$confint.ploidy[1] <= cint$values.ploidy[,1] &
  cint$values.ploidy[,1] <= cint$confint.ploidy[2]
polygon(x = c(cint$confint.ploidy[1], cint$values.ploidy[select, 1], cint$confint.ploidy[2]), 
        y = c(0, cint$values.ploidy[select, 2], 0), col='red', border=NA)
lines(cint$values.ploidy)
abline(v = cint$max.ploidy, lty = 2, lwd = 0.5)

dev.off()


##5.4 Call CNVs and mutations using the estimated parameters

cellularity <- cint$max.cellularity
cellularity

ploidy <- cint$max.ploidy
ploidy

avg.depth.ratio <- mean(test$gc$adj[,2])
avg.depth.ratio

#5.4.1. Detect variant alleles (mutations)
mut.tab <- na.exclude (do.call(rbind, test$mutations))

mut.alleles <- mufreq.bayes(mufreq = mut.tab$F,
                            depth.ratio = mut.tab$adjusted.ratio,
                            cellularity = cellularity, ploidy = ploidy,
                            avg.depth.ratio = avg.depth.ratio)

head(mut.alleles)
mut.allele.table <- (cbind(mut.tab[,c("chromosome","position","F","adjusted.ratio", "mutation")],mut.alleles))
mut.allele.table.name <- paste ( c(sample_id,".mut.allele.table.txt"), collapse= "")
write.table ( mut.allele.table , mut.allele.table.name, quote=FALSE, sep="\t", row.names = FALSE, col.names=TRUE)
###################################################
### 5.4.2 Detect copy number variations
###################################################
seg.tab     <- na.exclude(do.call(rbind, test$segments))
cn.alleles <- baf.bayes(Bf = seg.tab$Bf, depth.ratio = seg.tab$depth.ratio,
                        cellularity = cellularity, ploidy = ploidy,
                        avg.depth.ratio = avg.depth.ratio)
head(cn.alleles)
seg.tab <- cbind(seg.tab, cn.alleles)
seg.tab
txt.seg.tab = paste ( c (sample_id, "_seg.tab.txt"), collapse="")
write.table ( seg.tab, txt.seg.tab, sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE )



###################################################
### 5.5 Visualize detected copy number changes and variant alleles
###################################################
for ( i in 1:24){
  seg_path = paste( c(output_path,"seg/"), collapse="")
  setwd(seg_path)
  png.seg.CN.and.VA = paste ( c(sample_id,"_chr",i,"_seg.CN.and.VA.png"), collapse = "")
  png (png.seg.CN.and.VA)
  chromosome.view(mut.tab = test$mutations[[i]], baf.windows = test$BAF[[i]], 
                  ratio.windows = test$ratio[[i]],  min.N.ratio = 1,
                  segments = seg.tab[seg.tab$chromosome == test$chromosomes[i],],
                  main = test$chromosomes[i],
                  cellularity = cellularity, ploidy = ploidy,
                  avg.depth.ratio = avg.depth.ratio)
  dev.off()
}

###################################################
### 5.5.1 Genome-wide view of the allele and copy number state
###################################################
png.genome.wide.view = paste ( c (sample_id, "_genome_wide_view.png"), collapse = "")

png(png.genome.wide.view) 
par(mfrow = c(2,1), cex = 1, las = 1, bty = 'l')
genome.view(seg.cn = seg.tab, info.type = "CNt")
legend("bottomright", bty="n", c("Tumor copy number"),col = c("red"), 
       inset = c(0, -0.4), pch=15, xpd = TRUE)

###################################################
### 5.5.2 Genome-wide absolute copy number profile obtained frome exome sequencing
###################################################

genome.view(seg.cn = seg.tab, info.type = "AB")
legend("bottomright", bty = "n", c("A-allele","B-allele"), col= c("red", "blue"), 
       inset = c(0, -0.45), pch = 15, xpd = TRUE)

dev.off()


