#!/usr/bin/perl-w
use strict;

## Program Info;
#
# Name: vcf merge script
#
# Function: vcf file merge using vcftools
#
# Author: Inpyo Baek
#  Copyright (c) Theragene Etex, 2016
#  all rights reserved
#
# Licence: This script may be used freely as long as no free is charged
#  for use, and as long as the author/copyright attributions
#  are not removed.
#
#  Histroy:
#   Version 1.0 (Feb 26, 2016): 
#
##
use File::Basename qw(dirname);
use Cwd qw(abs_path);

use Getopt::Long;

my ($VCFTOOLS_PATH, $TABIX_PATH);
GetOptions(
	'VCFTOOLS=s' => \$VCFTOOLS_PATH,
	'TABIX=s' => \$TABIX_PATH,
);

if (!$VCFTOOLS_PATH){
	$VCFTOOLS_PATH = "/BiO/BioTools/vcftools/current/";
}
if (!$TABIX_PATH){
    $TABIX_PATH = "/BiO/BioTools/tabix/tabix-v0.2.5/";
}

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD);  

if (@ARGV != 2){
	printUsage();
}

my $INPUT_S = $ARGV[0];
my $VCF_OUT = $ARGV[1];

my $PATH_tabix = $TABIX_PATH;
my $bgzip = $PATH_tabix."/bgzip";
my $tabix = $PATH_tabix."/tabix";

my $LIB_vcftools = $VCFTOOLS_PATH."/lib/perl5/site_perl";
my $PATH_vcftools = $VCFTOOLS_PATH."/bin";
my $merge = $PATH_vcftools."/vcf-merge";

$ENV{'PATH'}.= ":".$PATH_tabix;
#print "export PATH=$PATH_tabix:\$PATH\n";

my @FILES = glob($INPUT_S);
for (my $i=0; $i<@FILES; $i++){
	if ($FILES[$i] =~ /\.gz$/){
		next;	
	}
	my $command = "$bgzip -c $FILES[$i] > $FILES[$i].gz";
	if (!-f "$FILES[$i].gz"){
		print STDERR "$command\n";
		system($command);
	}
	if (!-f "$FILES[$i].gz.tbi"){
		$command = "$tabix -p vcf $FILES[$i].gz";
		print STDERR "$command\n";
		system($command);
	}
	$FILES[$i] = $FILES[$i].".gz";
}

my $infiles = "";
$infiles .= "$_ " foreach @FILES;

my $sc = "perl -I $LIB_vcftools $merge $infiles | $bgzip -c > $VCF_OUT";
print STDERR "$sc\n";
system($sc);

sub printUsage{
    print "Usage: perl $0 [-V vcftools Directory $VCFTOOLS_PATH] [-T tabix Directory $TABIX_PATH] <\"PATH/*.vcf\"> <out.vcf.gz>\n";
	print "Exampler: perl $0 \"/BiO/BioProjects/HALLYM-Cancer-Transcriptome-2015-09/Rine_Quant_Mutect_consensus_call/*.vcf\" /BiO/BioProjects/HALLYM-Cancer-Transcriptome-2015-09/Rine_Quant_Mutect_consensus_call/merged.vcf.gz\n";
    exit;
}


