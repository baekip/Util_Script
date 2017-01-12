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
print $fh_stat "SampleID\tIndex\tTotalReads\tTotalBases\tTotalBases(Gb)\tGC_Count\tGC_Rate N_ZeroReads\tN_ZeroReadsRate\tN5_LessReads\tN5_LessReadsRate\tN_Count N_Rate\tQ30_MoreBases\tQ30_MoreBasesRate\tQ20_MoreBases\tQ20_MoreBasesRate\n";

foreach my $id (@delivery_list) {
    my ($delivery_id,$tbi_id,$type_id) = split /\:/, $id;
    my $sample_seqtk_path="$seqtk_path/$tbi_id/";
    checkDir($sample_seqtk_path);
    my $rst_xls="$sample_seqtk_path/$tbi_id\_1.fastq.gz.rst.xls";
    checkFile($rst_xls);
       
    #####Read column value#####
    my $total_reads = `cat $rst_xls | grep -v \'#\'| cut -f 1 `;
    chomp ($total_reads);
    my $total_length = `cat $rst_xls | grep -v \'#\'| cut -f 2 `;
    chomp ($total_length);
    my $total_GC = `cat $rst_xls | grep -v \'#\'| cut -f 3 `;
    chomp ($total_GC);
    my $Nzero_reads = `cat $rst_xls | grep -v \'#\'| cut -f 4 `;
    chomp ($Nzero_reads);
    my $N5_reads = `cat $rst_xls | grep -v \'#\' | cut -f 5 `;
    chomp ($N5_reads);
    my $N_count = `cat $rst_xls | grep -v \'#\' | cut -f 6 `;
    chomp ($N_count);
    my $Q30_base_R1 = `cat $rst_xls | grep -v \'#\' | cut -f 9`;
    chomp ($Q30_base_R1);
    my $Q30_base_R2 = `cat $rst_xls | grep -v \'#\' | cut -f 10`;
    chomp ($Q30_base_R2);
    my $Q20_base_R1 = `cat $rst_xls | grep -v \'#\' | cut -f 13`;
    chomp ($Q20_base_R1);
    my $Q20_base_R2 = `cat $rst_xls | grep -v \'#\' | cut -f 14`;
    chomp ($Q20_base_R2);

    #####correct stats column#####
    
    my $sample_rawdata="$fastq_path/$tbi_id/$tbi_id\_1.fastq.gz";
    checkFile($sample_rawdata);
    my $fastq_header = `zcat $sample_rawdata | head -n 1 `;
    chomp ($fastq_header);
    my @header_list = split /\:/, $fastq_header;
    my $index=$header_list[-1];
    
    my $total_base_gb=changeGbp($total_length)." Gb";
    my $gc_rate=$total_GC/$total_length*100;$gc_rate=RoundXL($gc_rate,2)."%";
    my $Nzero_rate=$Nzero_reads/$total_reads*100;$Nzero_rate=RoundXL($Nzero_rate,2)."%";
    my $N5_rate=$N5_reads/$total_reads*100;$N5_rate=RoundXL($N5_rate,2)."%";
    my $N_rate=$N_count/$total_length*100;$N_rate=RoundXL($N_rate,2)."%";
    my $Q30_base=$Q30_base_R1+$Q30_base_R2;
    my $Q30_rate=$Q30_base/$total_length*100;$Q30_rate=RoundXL($Q30_rate,2)."%";
    my $Q20_base=$Q20_base_R1+$Q20_base_R2;
    my $Q20_rate=$Q20_base/$total_length*100;$Q20_rate=RoundXL($Q20_rate,2)."%";
    print $fh_stat "$tbi_id\t$index\t$total_reads\t$total_length\t$total_base_gb\t$total_GC\t$gc_rate\t$Nzero_reads\t$Nzero_rate\t$N5_reads\t$N5_rate\t$N_count\t$N_rate\t$Q30_base\t$Q30_rate\t$Q20_base\t$Q20_rate\n";
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

