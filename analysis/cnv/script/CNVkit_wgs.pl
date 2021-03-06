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
    'config=s' => \$in_config,
);

if (!defined $in_config or !-f $in_config){
    die "ERROR! check your config file with -c option \n";
}

my $config_path = dirname (abs_path $in_config);
$in_config =  "$config_path/$in_config";
print $in_config."\n";

my %info;
read_general_config($in_config, \%info);

#############################################################
#Requirement 
#############################################################

my $project_path=$info{project_path};
my $bam_path=$info{bam_path};
my $bam_pattern=$info{bam_pattern};
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
    
    my $current_bam_path = "$project_path/result/00_SV_run/00_bam_file/$delivery_id";
    make_dir($current_bam_path);
    my $current_bam_file = "$current_bam_path/$delivery_id\.bam";
    my $current_bai_file = "$current_bam_path/$delivery_id\.bam.bai";

    my $output_path = "$cnv_path/$delivery_id";
    make_dir($output_path);
    my $bam_file = "$bam_path/$tbi_id/$tbi_id\.$bam_pattern";
    checkfile($bam_file);
    my $bai_file = "$bam_path/$tbi_id/$tbi_id\.$bam_pattern\.bai";
    checkfile($bai_file);
    
    my $cnv_sh_path="$cnv_path/sh_file/$delivery_id/";
    make_dir($cnv_sh_path);
    my $cnv_sh = "$cnv_sh_path/$delivery_id\.cnvkit.wgs.sh";
    print "Current Sample ID: $delivery_id \n";
    open my $sh_fh, '>', $cnv_sh or die;
   
    print $sh_fh "#!/bin/sh
date\n\n";
    print $sh_fh "echo \"softlink bam file\"\n";
    print $sh_fh "ln -s $bam_file $current_bam_file \n";
    print $sh_fh "ln -s $bai_file $current_bai_file \n\n";
    
    #####1. cnvkit run call
    print "process: cnvkit run call\n";
    print $sh_fh "echo \"cnvkit run call\"
date
$cnvkit batch \\
    -m wgs \\
    $current_bam_file \\
    -n \\
    -f $reference \\
    -g $access_bed \\
    --annotate $refFlat_txt \\
    --output-reference \\
    -d $output_path 
    date\n\n";

    #####2. copynumber call
    print "process: copynumber call\n";
    print $sh_fh "echo \"copynumber call\"
date
$cnvkit call \\
    $output_path/$delivery_id\.cns \\
    -m threshold \\
    -t=-1.1,-0.4,0.3,0.7 \\
    -o $output_path/$delivery_id\.call.cns
date\n\n";

    ####3. output figure file 
    print "process: scatter pdf and png file\n";
    print $sh_fh "echo \"scatter pnf and png file\"
date
$cnvkit scatter \\
    $output_path/$delivery_id\.cnr \\
    -s $output_path/$delivery_id\.cns \\
    -o $output_path/$delivery_id-scatter.pdf

$cnvkit diagram \\
    $output_path/$delivery_id\.cnr \\
    -s $output_path/$delivery_id\.cns \\
    -o $output_path/$delivery_id-diagram.pdf\n

    -quality 90 \\
    $output_path/$delivery_id\-diagram.png

convert -density 150 \
    $output_path/$delivery_id\-scatter.pdf \\
    -quality 90 \\
    $output_path/$delivery_id\-scatter.png
date\n\n";
close ($sh_fh);
    
    my $cmd_cnv_fh = "qsub -V -e $cnv_sh_path -o $cnv_sh_path -S /bin/bash $cnv_sh";
    print "qsub command: $cmd_cnv_fh\n";
    system ($cmd_cnv_fh);
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
