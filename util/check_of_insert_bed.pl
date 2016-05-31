#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 3) {
    printUsage();
}

my $in_bed = $ARGV[0];
my $in_vcf = $ARGV[1];
my $output_txt = $ARGV[2];

open my $fh_bed, '<:encoding(UTF-8)', $in_bed or die; 
open my $fh_vcf, '<:encoding(UTF-8)', $in_vcf or die;
open my $fh_output, '>', $output_txt or die;

while (my $row_bed = <$fh_bed>){
    chomp $row_bed; 
    if ($row_bed =~ /^#/){next;}
    while (my $row_vcf = <$fh_vcf>){

        chomp $row_vcf;
#        print $row_bed."\n\n\n";
#        print $row_vcf."\n";
    
        my @row_bed = split /\t/, $row_bed;
        my @row_vcf = split /\t/, $row_vcf;

        my $bed_chr = $row_bed[0]; my $bed_start = $row_bed[1]; my $bed_end = $row_bed[2];  
        my $vcf_chr = $row_vcf[0]; my $vcf_start = $row_vcf[1]; my $vcf_end = $row_vcf[2];
        
        print $row_vcf."\n";
        if ($bed_chr eq $vcf_chr && $bed_start <= $vcf_start){
#            if ( $bed_start <= $vcf_start){
                
                print $fh_output "$row_vcf\tincluding\n";
                #   }   
        }
    }close $fh_vcf;
}close $fh_bed;
    


sub printUsage{
    print "Usage: perl $0 <in.bed> <in.vcf.output> <output.result.name>\n";
    print "Example: perl $0 C0781661_Covered_revised.bed TN1511D0287-1_TN1511D0306.mutect.pass.vcf check_output.txt\n";
    exit;
}
