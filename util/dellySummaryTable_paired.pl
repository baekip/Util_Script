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

my $config_path = dirname (abs_path $in_config);
$in_config="$config_path/$in_config";
my %info;
read_general_config ($in_config, \%info);

#############################################################
#0.preparation
#############################################################

my $project_path=$info{project_path};
my $sample_id=$info{sample_id};
my $pair_id=$info{pair_id};
my $bcftools=$info{bcftools};
my $cytoband=$info{cytoband};
my @sample_list=split /\,/, $sample_id;
my @paired_list=split /\,/, $pair_id;

#############################################################
#1.make table description
#############################################################
my $SV_path="$project_path/result/00_Somatic_SV_run/02_sv_run";

foreach my $id (@paired_list) {
    my $TRA_bcf="$SV_path/$id/$id\.delly_TRA.bcf";
    my $TRA_vcf="$SV_path/$id/$id\.delly_TRA.vcf";
    my $TRA_input="$SV_path/$id/$id\.delly_TRA_PASS.vcf";
    my $TRA_output="$SV_path/$id/$id\.delly_TRA_PASS_Table.txt";
    checkFile($TRA_bcf);
    `$bcftools view $TRA_bcf > $TRA_vcf`;
    print $TRA_vcf."\n";
#    cat Benign_Malignancy.delly_TRA.vcf | grep -v '##' | awk '{if($7=="PASS"){print $0}}' | grep -v IMPRECISE
    my $filter_cmd = "cat $TRA_vcf \| grep -v \'##\' \| awk \'\{if\(\$7==\"PASS\"\)\{print \$0}}\' \| grep -v IMPRECISE > $TRA_input";
    system($filter_cmd);
    open my $TRA_fh_input, '<:encoding(UTF-8)', $TRA_input or die;
    open my $TRA_fh_output, '>', $TRA_output or die;

    print $TRA_fh_output "breakpoint1:chr\tbreakpoint1:pos\tbreakpoint1:cyto\tbreakpoint2:chr\tbreakpoint2:pos\tbreakpoint2:cyto\ttranslocation type\n";

    while (my $row = <$TRA_fh_input>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        my @row_list = split /\s/, $row;
        my $info = $row_list[7];
        my @info_list = split /;/, $info;
        my $breakpoint1_chr = trim($row_list[0]);
        my $breakpoint1_pos = trim($row_list[1]);
        my $cytoband_input_1 = "$breakpoint1_chr:$breakpoint1_pos-$breakpoint1_pos";
        my $cyto_val_1 = cytoband_run($cytoband_input_1);
        my ($chr_info,$breakpoint2_chr) = split /=/, $info_list[3];
        my ($pos_info,$breakpoint2_pos) = split /=/, $info_list[4];
        my ($ct_info,$trs) = split /=/, $info_list[7];
        my $cytoband_input_2 = "$breakpoint2_chr:$breakpoint1_pos-$breakpoint2_pos";
        my $cyto_val_2 = cytoband_run($cytoband_input_2);

        print $TRA_fh_output "$breakpoint1_chr\t$breakpoint1_pos\t$cyto_val_1\t$breakpoint2_chr\t$breakpoint2_pos\t$cyto_val_2\t$trs\n";
    }close($TRA_fh_input);
close ($TRA_fh_output);
}

foreach my $id (@paired_list) {
    my $INV_bcf="$SV_path/$id/$id\.delly_INV.bcf";
    my $INV_vcf="$SV_path/$id/$id\.delly_INV.vcf";
    my $INV_input="$SV_path/$id/$id\.delly_INV_PASS.vcf";
    my $INV_output="$SV_path/$id/$id\.delly_INV_PASS_Table.txt";
    `$bcftools view $INV_bcf > $INV_vcf`;
#    cat Benign_Malignancy.delly_TRA.vcf | grep -v '##' | awk '{if($7=="PASS"){print $0}}' | grep -v IMPRECISE
    my $filter_cmd = "cat $INV_vcf \| grep -v \'##\' \| awk \'\{if\(\$7==\"PASS\"\)\{print \$0}}\' | grep -v IMPRECISE > $INV_input";
    system($filter_cmd);
    
    open my $INV_fh_input, '<:encoding(UTF-8)', $INV_input or die;
    open my $INV_fh_output, '>', $INV_output or die;

    print $INV_fh_output "breakpoint1:chr\tbreakpoint1:pos\tbreakpoint1:cyto\tbreakpoint2:chr\tbreakpoint2:pos\tbreakpoint2:cyto\tinversion type\n";

    while (my $row = <$INV_fh_input>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        my @row_list = split /\s/, $row;
        my $info = $row_list[7];
        my $TRA_output="$SV_path/$id/$id\.delly_TRA_PASS_Table.txt";
        my @info_list = split /;/, $info;
        my $breakpoint1_chr = trim($row_list[0]);
        my $breakpoint1_pos = trim($row_list[1]);
        my $cytoband_input_1 = "$breakpoint1_chr:$breakpoint1_pos-$breakpoint1_pos";
        my $cyto_val_1 = cytoband_run($cytoband_input_1);
        my ($chr_info,$breakpoint2_chr) = split /=/, $info_list[3];
        my ($pos_info,$breakpoint2_pos) = split /=/, $info_list[4];
        my ($ct_info,$trs) = split /=/, $info_list[7];
        my $cytoband_input_2 = "$breakpoint2_chr:$breakpoint2_pos-$breakpoint2_pos";
        my $cyto_val_2 = cytoband_run($cytoband_input_2);
        print $INV_fh_output "$breakpoint1_chr\t$breakpoint1_pos\t$cyto_val_1\t$breakpoint2_chr\t$breakpoint2_pos\t$cyto_val_2\t$trs\n";
    }close($INV_fh_input);
close ($INV_fh_output);
}
#############################################################
#sub
#############################################################
sub cytoband_run { 
    my $input = shift;
    my $val = `bash $cytoband $input`;
    print $input."\n";
    $val = trim ($val);
    return $val;
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

