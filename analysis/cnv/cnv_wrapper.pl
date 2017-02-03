#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) .'/library';
use Report qw(report_heder report_opt report_int report_workflow);
use Util qw(read_config checkFile make_dir); 

my $in_config;
GetOptions(
    'config=s' => \$in_config,
);

my %info;
read_config (%in_config, \%info);

my $project_id = $info{project_id};
my $sample_id = $info{sample_id};
