#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path);

my $in_config;
GetOptions(
    'config=s' => \$in_config,
);

if (!defined $in_config or !-f $in_config){
    die "ERROR! check your config file with -c option\n";
}

print $in_config."\n";

my $config_path = dirname (abs_path $in_config);
$in_config="$config_path/$in_config";
#print $config_path."\n";
#print $in_config."\n";
my %info;
read_general_config ($in_config, \%info);

#############################################################
#0.preparation
#############################################################

my $project_path=$info{project_path};
my $project_id=$info{project_id};
my $telomeric_path="$project_path/result/00_telo-seq";
my $sample_id=$info{sample_id};
my @sample_list=split /\,/, $sample_id;

#############################################################
#1.make report description
#############################################################
my $report_path="$project_path/result/00_CNV_run/report/";
make_dir($report_path);
my $report_result="$report_path/report.result";
open my $report_fh, '>', $report_result or die;

##Introduction


foreach my $id (@sample_list) {
    print $report_fh "##$id\n
###Profile Scatter Plot\n
 Plot bin-level log2 coverages and segmentation calls together. Without any further arguments, this plots the genome-wide copy number in a form familiar to those who have used array CGH.\n\n
[Download Result File](result/$id/$id-scatter.pdf) \n\n
\`\`\`{r scatter_plot_$id, out.width = \"1000px\",out.heigh=\"800px\"}\n
S_$id\_scatter_plot = \'result/$id/$id-scatter.png\'\n
include_graphics(S_$id\_scatter_plot)\n
\`\`\`\n\n

### Profile Diagram Plot\n\n
 Draw copy number on chromosomes as an ideogram. If both the bin-level log2 ratios and segmentation calls are given, show them side-by-side on each chromosome\n\n
      
[Download Result File](result/$id/$id-diagram.pdf) \n\n
\`\`\`{r diagram_plot_$id, out.width = \"1000px\",out.heigh=\"800px\"}\n
S_$id\_diagram_plot = \'result/$id/$id-diagram.png\'\n
include_graphics(S_$id\_diagram_plot)\n
\`\`\`\n\n\n
    
### Total Result Table\n\n

 The log2 ratio value reported for each gene will be the value of the segment covering the gene. Where more than one segment overlaps the gene, i.e. if the gene contains a breakpoint, each segment\'s value will be reported as a separate row for the same gene.\n\n

[Download Result File](result/$id/$id\.gene.gainloss)\n\n

\`\`\`{r table_$id, results=\'asis\',echo=FALSE}\n
S_$id\_cnv_result=read.table(file.path(project_path, \"\", \"result/$id/$id.gene.gainloss\"), header=T, sep= \"\t\", check.names = T)
datatable(S_$id\_cnv_result)\n
\`\`\`\n

column           Description
------------   ------------------------------------------------
chromosome      Chromosome or reference sequence name
start           Start position
gene            Gene name          
log2            Log2 mean coverage depth      
depth           Absolute-scale mean coverage depth
probes          the number of bins covered by the segment
weight          each bin's proportional weight or reliability
cn              copy number value\n\n


If log2 value is up to       Copy number
------------------------   ---------------
       -1.1                        0
       -0.4                        1
        0.3                        2
        0.7                        3
        ...                       ...\n\n

### Translocation Result\n\n

\`\`\`{r TRA_$id, results=\'asis\',echo=FALSE}\n
S_$id\_tra_table=read.table(file.path(project_path, \"\", \"result/$id/$id.delly_TRA_PASS_Table.txt\"), header=T, sep= \"\t\", check.names = T)
datatable(S_$id\_tra_table)
\`\`\`\n

### Inversion Result\n\n

\`\`\`{r INV_$id, results=\'asis\',echo=FALSE}\n
S_$id\_inv_table=read.table(file.path(project_path, \"\", \"result/$id/$id.delly_INV_PASS_Table.txt\"), header=T, sep= \"\t\", check.names = T)
datatable(S_$id\_inv_table)
\`\`\`\n

### Telomeric Summary Result\n\n
Estimating telomere lengths with Next Generation Sequencing\n

\`\`\`{r teloseq_$id, results=\'asis\',echo=FALSE}\n
S_$id\_teloseq_table=read.table(file.path(project_path, \"\", \"result/$id/$id.telo-seq.result\"), header=T, sep= \"\t\", check.names = T)
datatable(S_$id\_teloseq_table)
\`\`\`\n

\`\`\`{r telseq_$id, results=\'asis\',echo=FALSE}\n
S_$id\_telseq_table=read.table(file.path(project_path, \"\", \"result/$id/$id.telseq.result\"), header=T, sep= \"\t\", check.names = T)
datatable(S_$id\_telseq_table)
\`\`\`\n

Column                        Definitions
-----------------------      -----------------------------------------------------
ReadGroup                     read group, Defined by the RG tag in BAM header.
Library                       sequencing library that the read group belongs to.
Sample                        defined by the SM tag in BAM header.
Total                         total number of reads in this read group.
Mapped                        total number of mapped reads, SAM flag 0x4.
Duplicates                    total number of duplicate reads, SAM flag 0x400.
LENGH_ESTIMATE                estimated telomere length.
TEL0                          read counts for reads containing no TTAGGG/CCCTAA repeats.
TEL1                          read counts for reads containing only 1 TTAGGG/CCCTAA repeats.
TELn                          read counts for reads containing only n TTAGGG/CCCTAA repeats.
TEL16                         read counts for reads containing 16 TTAGGG/CCCTAA repeats.
GC0                           read counts for reads with GC between 40%-42%.
GC1                           read counts for reads with GC between 42%-44%.
GCn                           read counts for reads with GC between (40\%\+n2%)-(42\%\+(n+1)2%).
GC9                           read counts for reads with GC between 58%-60%.\n\n";

}
close($report_fh);

#############################################################
#sub
#############################################################
sub checkfile{
	my $file = shift;
	if (!-f $file){
		die "error ! not found <$file>\n";
	}
}

sub read_general_config{
	my ($file, $hash_ref) = @_;
	open my $fh, '<:encoding(utf-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/){ next; } # pass header line
		if (length($row) == 0){ next; }

		my ($key, $value) = split /\=/, $row;
		$key = trim($key);
		$value = trim($value);
		$hash_ref->{$key} = $value;
	}
	close($fh);	
}

sub trim {
	my @result = @_;

	foreach (@result) {
		s/^\s+//;
		s/\s+$//;
	}

	return wantarray ? @result : $result[0];
}

sub make_dir {
    my $dir_name = shift;
    if (!-d $dir_name){
        my $cmd_mkdir = "mkdir -p $dir_name";
        system ($cmd_mkdir);
    }
}

