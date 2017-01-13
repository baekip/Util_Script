#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path);

my $in_config;
GetOptions(
    'conifg=s' => \$in_config,
);

if (!defined $in_config or !-f $in_config){
    die "ERROR! check your config file with -c option\n";
}

print $in_config."\n";

my $config_path = dirname(abs_path $in_config);
$in_config="$config_path/$in_config";


