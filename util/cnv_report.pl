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

my $sample_id=$info{sample_id};
my @sample_list=split /\,/, $sample_id;

#############################################################
#1.make report description
#############################################################
my $report_path="$project_path/00_CNV_run/report/";
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
        ...                       ...\n\n";
}
close($report_fh);

#############################################################
#sub
#############################################################
sub checkFile{
	my $file = shift;
	if (!-f $file){
		die "ERROR ! not found <$file>\n";
	}
}

sub read_general_config{
	my ($file, $hash_ref) = @_;
	open my $fh, '<:encoding(UTF-8)', $file or die;
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

