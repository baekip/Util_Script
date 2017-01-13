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

#print $in_config."\n";

my $config_path = dirname (abs_path $in_config);
$in_config="$config_path/$in_config";
my %info;
read_general_config ($in_config, \%info);

#############################################################
#0.preparation
#############################################################

my $project_path=$info{project_path};
my $project_id=$info{project_id};
my $telomeric_path="$project_path/result/00_telo-seq";
my $delivery_id=$info{delivery_tbi_id};
my @delivery_list=split /\,/, $delivery_id;

#############################################################
#1.read fastq stats xls file 
#############################################################
my $rawdata_path="$project_path/rawdata";
my $sequence_stat="$rawdata_path/Sequencing_Statistics_Result.xls";
my $seqtk_path="$project_path/result/01-1_seqtk_run";
my $fastq_path="$project_path/result//01_fastqc_orig";


open my $fh_stat, '>', $sequence_stat or die;
#print "SampleID\tIndex\tTotalReads\tTotalBases\tTotalBases(Gb)\tGC_Count\tGC_Rate N_ZeroReads\tN_ZeroReadsRate\tN5_LessReads\tN5_LessReadsRate\tN_Count N_Rate\tQ30_MoreBases\tQ30_MoreBasesRate\tQ20_MoreBases\tQ20_MoreBasesRate\n";

foreach my $id (@delivery_list) {
    my ($delivery_id,$tbi_id,$type_id) = split /\:/, $id;
    my $sample_seqtk_path="$seqtk_path/$tbi_id/";
    checkDir($sample_seqtk_path);
    my $rst_xls="$sample_seqtk_path/$tbi_id\_1.fastq.gz.rst.xls";
    checkFile($rst_xls);
    
    open my $rst_fh, '<:encoding(UTF-8)', $rst_xls or die;
    while (my $row = <$rst_fh>){
        chomp $row;
        my @col;
        my @rst;
        push @col, $row;
        foreach (@col){
            my @cell = split /\t/, $_;
            push @rst, @cell;
        }
        foreach (my $i=1; $i<@rst; $i++){
            print $rst[$i]."\n";
        }
    }
}
close ($fh_stat);
print "End\n"; 
#############################################################
#sub
#############################################################
sub changeGbp{
    my $val = shift;
    $val = $val/1000000000;
    $val = &RoundXL($val,2);
    return $val;
}

sub RoundXL {
    sprintf("%.$_[1]f", $_[0]);
}

#sub read_hash {
#    my $file=shift;
#    my $hash_ref = shift;
#    open my $fh, '<:encoding(UTF-8)', $file or die;
#    while (my $row=<$fh>){
#        chomp $row;
#        my $header;
#        my $value;
#        my @head_list;
#        if ($row =~ /^#/) {
#        next;
#    }
#    my $total_reads=`cat 
#}

sub checkDir{
    my $dir=shift;
    if (!-d $dir){
        die "ERROR! not exist <$dir>\n";
    }
}

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

