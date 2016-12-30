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
my @sample_list=split /\,/, $sample_id;

#############################################################
#1.make table description
#############################################################
my $SV_path="$project_path/result/00_SV_run/";


foreach my $id (@sample_list) {
    my $TRA_input="$SV_path/$id/$id\.delly_TRA_PASS.vcf";
    my $TRA_output="$SV_path/$id/$id\.delly_TRA_PASS_Table.txt";
    
    open my $TRA_fh_input, '<:encoding(UTF-8)', $TRA_input or die;
    open my $TRA_fh_output, '>', $TRA_output or die;

    print $TRA_fh_output "breakpoint1:chr\tbreakpoint1:pos\tbreakpoint2:chr\tbreakpoint2:pos\ttranslocation type\n";

    while (my $row = <$TRA_fh_input>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        my @row_list = split /\s/, $row;
        my $info = $row_list[7];
        my @info_list = split /;/, $info;
        my $breakpoint1_chr = $row_list[0];
        my $breakpoint1_pos = $row_list[1];
        my ($chr_info,$breakpoint2_chr) = split /=/, $info_list[5];
        my ($pos_info,$breakpoint2_pos) = split /=/, $info_list[6];
        my ($ct_info,$trs) = split /=/, $info_list[7];

        print $TRA_fh_output "$breakpoint1_chr\t$breakpoint1_pos\t$breakpoint2_chr\t$breakpoint2_pos\t$trs\n";
    }close($TRA_fh_input);
close ($TRA_fh_output);
}

foreach my $id (@sample_list) {
    my $INV_input="$SV_path/$id/$id\.delly_INV_PASS.vcf";
    my $INV_output="$SV_path/$id/$id\.delly_INV_PASS_Table.txt";
    
    open my $INV_fh_input, '<:encoding(UTF-8)', $INV_input or die;
    open my $INV_fh_output, '>', $INV_output or die;

    print $INV_fh_output "breakpoint1:chr\tbreakpoint1:pos\tbreakpoint2:chr\tbreakpoint2:pos\tinversion type\n";

    while (my $row = <$INV_fh_input>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        my @row_list = split /\s/, $row;
        my $info = $row_list[7];
        my @info_list = split /;/, $info;
        my $breakpoint1_chr = $row_list[0];
        my $breakpoint1_pos = $row_list[1];
        my ($chr_info,$breakpoint2_chr) = split /=/, $info_list[5];
        my ($pos_info,$breakpoint2_pos) = split /=/, $info_list[6];
        my ($ct_info,$trs) = split /=/, $info_list[7];

        print $INV_fh_output "$breakpoint1_chr\t$breakpoint1_pos\t$breakpoint2_chr\t$breakpoint2_pos\t$trs\n";
    }close($INV_fh_input);
close ($INV_fh_output);
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

