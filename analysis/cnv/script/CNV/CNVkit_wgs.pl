#############################################################
#CNVkit - WGS (Whole Genome Sequencing)
#Date - 2017.01.13
#Author - baekip
#############################################################
#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path);

my $in_config;
GetOptions(
    'config=s' => $in_config,
);

my %info;
read_general_config($in_config, \%info);

#############################################################
#Requirement 
#############################################################

my $project_path=$info{project_path};
my $bam_path=$info{bam_path};
my $reference=$info{reference};
my $cnvkit=$info{cnvkit};
my $access_bed=$info{access_bed};
my $refFlat_txt=$info{refFlat_txt};
my $delivery_tbi_id=$info{delivery_tbi_id};
my @delivery_tbi_list=split /\,/, $delivery_tbi_id;
my $cnv_path="$project_path/result/00_SV_run/01_cnv_run/";
make_dir($cnv_path);

#############################################################
#run
#############################################################
foreach my $sample_id (@delivery_tbi_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $sample_id;
    my $output_path = "$cnv_path/$delivery_id";
    make_dir($output_path);
    my $bam_file = "$bam_path/$delivery_id/$delivery_id/.bam";
    my $cnv_sh_path="$cnv_path/sh_file/$delivery_id/";
    make_dir($cnv_sh_path);
    my $cnv_sh = "$cnv_sh_path/$delivery_id\.cnvkit.wgs.sh";
    open my $sh_fh, '>', $cnv_sh or die;
   
    print $sh_sh "#!/bin/sh
    date\n\n";
    print $sh_sh "$cnvkit batch \
    -m wgs \
    $bam_file \
    -n \
    -f $reference \
    -g $access_bed \
    --annotate $refFlat_txt \
    --output-reference \
    -d $output_path \n\n";
}
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
