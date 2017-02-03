#############################################################
#CNVkit report V0.3.1
#Date - 2017.01.13
#Author - baekip
#############################################################
#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname (abs_path $0) . '/../library';
use Report qw(report_header report_opt report_int report_info report_workflow );
use Result qw(result_scatter_plot result_diagram_plot result_table);
use Utils qw(read_config trim checkFile make_dir); 
use CNV qw(cnv_target);

my $ver = "0.3.1";
my $in_config;
GetOptions(
    'config=s' => \$in_config,
);

if (!defined $in_config or !-f $in_config){
    die "ERROR! check your config file with -c option \n";
}

my $config_path = dirname (abs_path $in_config);
$in_config =  "$config_path/$in_config";
print "read config: $in_config \n";

my %info;
read_config($in_config, \%info);

#############################################################
#Requirement 
#############################################################
my $project_id = $info{project_id};
my $sample_id = $info{sample_id};
my @sample_list = split /\,/, $sample_id;
my $project_path = $info{project_path};
#############################################################
#make report 
#############################################################
my $report_path = "$project_path/result/00_SV_run/report";
make_dir($report_path);

my $report_rmd = "$report_path/$project_id\_SV_AnalysisReport.rmd";
open my $fh, '>', $report_rmd or die;

report_header($fh, $ver, $project_id);
report_opt($fh, $report_path);
report_int($fh);
report_info($fh,"hg19");
report_workflow($fh,$project_path);

foreach my $id (@sample_list) {
    cnv_target($id, %info);
    print $info{project_path}."\n";
#    print $id."\n";
#    my $scatter_png = "scatter_png";
#    my $diagram_png = "diagram_png";
#    my $gainloss_table = "gainloss_table";
#    result_scatter_plot($fh,$scatter_png,$id);
#    result_diagram_plot($fh,$diagram_png,$id);
#    result_table($fh,$gainloss_table,$id);
}
close $fh;
=pod
