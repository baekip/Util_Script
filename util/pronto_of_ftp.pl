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
my $result_path="$project_path/result/";
my $fastq_path="$result_path/01_fastqc_orig";
my $bam_path="$result_path/12_gatk_printrecal";
my $vcf_path="$result_path/13_gatk_unifiedgenotyper";
my $annotation_path="$result_path/14_snpeff_human_run";

my $delivery_tbi_id=$info{delivery_tbi_id};
my @delivery_list=split /\=/, $delivery_tbi_id;

#############################################################
#1.make directories
#############################################################
my $pronto_path="$result_path/80_pronto_ftp_upload";
make_dir($pronto_path);

my $pronto_report_path="$pronto_path/report";
make_dir($pronto_report_path);

`cp $project_path/report/Analysis_report_$project_id\.pdf $pronto_report_path/`;
`cp $project_path/report/alignment.statistics.xls $pronto_report_path/`;

foreach my $id (@delivery_list){
    my ($delivery_id, $tbi_id, $type_id)=split /\:/, $id;
    my $pronto_sample_path="$pronto_path/$delivery_id";
    make_dir($pronto_sample_path);

    ###01_fastq_file
    my $pronto_fastq_path="$pronto_sample_path/FASTQ/";
    make_dir($pronto_fastq_path);
    `ln -s $fastq_path/$tbi_id/$tbi_id\_1_fastqc $pronto_fastq_path/$delivery_id\_1_fastqc`;
    `ln -s $fastq_path/$tbi_id/$tbi_id\_2_fastqc $pronto_fastq_path/$delivery_id\_2_fastqc`;
    `ln -s $fastq_path/$tbi_id/$tbi_id\_1.fastq.gz $pronto_fastq_path/$delivery_id\_1.fastq.gz`;
    `ln -s $fastq_path/$tbi_id/$tbi_id\_2.fastq.gz $pronto_fastq_path/$delivery_id\_2.fastq.gz`;
    `ln -s $fastq_path/$tbi_id/$tbi_id\_1.md5.txt $pronto_fastq_path/$delivery_id\_1.md5.txt`;
    `ln -s $fastq_path/$tbi_id/$tbi_id\_2.md5.txt $pronto_fastq_path/$delivery_id\_2.md5.txt`;
    checkFile("$fastq_path/$tbi_id/$tbi_id\_1.fastq.gz");
    checkFile("$fastq_path/$tbi_id/$tbi_id\_2.fastq.gz");

    ###02_bam_file
    my $pronto_bam_path="$pronto_sample_path/BAM/";
    make_dir($pronto_bam_path);
    `ln -s $bam_path/$tbi_id/$tbi_id\.printrecal.bam $pronto_bam_path/$delivery_id\.printrecal.bam`;
    `ln -s $bam_path/$tbi_id/$tbi_id\.printrecal.bai $pronto_bam_path/$delivery_id\.printrecal.bai`;
    checkFile("$bam_path/$tbi_id/$tbi_id\.printrecal.bam");
    checkFile("$bam_path/$tbi_id/$tbi_id\.printrecal.bai");
    
    ###03_vcf_file
    my $pronto_vcf_path="$pronto_sample_path/VCF/";
    make_dir($pronto_vcf_path);
    `ln -s $vcf_path/$tbi_id/$tbi_id\.BOTH.vcf $pronto_vcf_path/$delivery_id\.BOTH.vcf`;
    `ln -s $vcf_path/$tbi_id/$tbi_id\.BOTH.vcf.idx $pronto_vcf_path/$delivery_id\.BOTH.vcf.idx`;
    checkFile("$vcf_path/$tbi_id/$tbi_id\.BOTH.vcf");
    checkFile("$vcf_path/$tbi_id/$tbi_id\.BOTH.vcf.idx");
    
    
    ###04_annotation_file
    my $pronto_tsv_path="$pronto_sample_path/TSV/";
    make_dir($pronto_tsv_path);
    `ln -s $annotation_path/$tbi_id/$tbi_id\.BOTH.snpeff.isoform.tsv $pronto_tsv_path/$delivery_id\.BOTH.snpeff.isoform.tsv`;
    checkFile("$annotation_path/$tbi_id/$tbi_id\.BOTH.snpeff.isoform.tsv");
}

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

