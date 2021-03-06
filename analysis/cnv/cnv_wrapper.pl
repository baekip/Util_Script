#!/usr/bin/perl

=head1 Name

    cnv_wrapper.pl -- a wrapper script for making a CNV-report

=head1 Version 

    Author: baekip (inpyo.baek@theragenetex.com)
    Version: 0.1 
    Date: 2017-02-09

=head1 Usage 
    
    perl cnv_wrapper.pl [options] config_file
        -c input_config <copynumber_config.wgs.txt>
        -p input_pipeline <copynumber_pipeline.wgs.txt>
        -h output help information to screen 

=head1 Example 

    perl cnv_wrapper.pl -c copynumber_config.wgs.txt -p copynumber_pipeline.wgs.txt

=cut

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/library';
use Utils qw(read_config checkFile make_dir); 
use DateTime;


my ($in_config, $in_pipeline, $help);
GetOptions(
    'config=s' => \$in_config,
    'pipeline=s' => \$in_pipeline,
    'help' => \$help
);

die `pod2text $0` if (!defined $in_config || !defined $in_pipeline || $help);

my %info;
read_config ($in_config, \%info);

#############################################################
#Requirement config source 
#############################################################

my $project_id = $info{project_id};
my $sample_id = $info{sample_id};
my $report_type = $info{report_type};
my $dev_path = $info{dev_path};

if ($report_type eq "somatic"){
    my $somatic_pl = "$dev_path/script/CNVkit_paired_report.pl";
    my $cmd = "perl $somatic_pl -c $in_config";
    system($cmd);
}elsif ($report_type eq "individual"){
    my $individual_pl "$dev_path/script/CNVkit_report.pl";
    my $cmd = "perl $individual_pl -c $in_config";
    system($cmd);
}else {
    die "Check your config file <report_type> ";
}

