#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 2){
    printUsage();
}

my %info;

my $in_config = $ARGV[0];
read_config ($in_config,\%info);


my $project_path = $info{project_path};
my $pair_id = $info{pair_id};
my @pair_list = split /\,/, $pair_id;

my $mutect_path = "$project_path/result/26_mutect_run";
my $virmid_path = "$project_path/result/27_virmid_run";
my $indeldetector_path = "$project_path/result/28_indeldetector_run";

my $my_output_path = "$project_path/output";


foreach (@pair_list) {
    my $paired_id = $_;
    my $mutect_id_path = "$mutect_path/$paired_id";
    my $virmid_id_path = "$virmid_path/$paired_id";
    my $indeldetector_id_path = "$indeldetector_path/$paired_id";

    my $my_mutect_output = "$my_output_path/30-1_mutect_run/$paired_id";
    make_dir($my_mutect_output);
    my $my_virmid_output = "$my_output_path/31-1_virmid_run/$paired_id";
    make_dir($my_virmid_output);
    my $my_indel_output = "$my_output_path/32-1_indeldetector_run/$paired_id";
    make_dir($my_indel_output);

    my ($control, $case) = split/\_/, $paired_id;

    my $mutect_output_vcf = "$my_mutect_output/$paired_id.SNP.vcf";
    my $virmid_output_vcf = "$my_virmid_output/$paired_id.SNP.vcf";
    my $indel_output_vcf = "$my_indel_output/$paired_id.INDEL.vcf";

    #TN1508D0513_TN1508D0514.INDEL.vcf
    #TN1508D0513_TN1508D0514.SNP.vcf
    #TN1508D0513_TN1508D0514.SNP.vcf
   print $mutect_output_vcf; 
    open my $fh_mutect, '>', $mutect_output_vcf or die;
    open my $fh_virmid, '>', $virmid_output_vcf or die;
    open my $fh_indel, '>', $indel_output_vcf or die;
        
    for (my $i=1; $i < 25; $i++){
        if ( $i == 23 ) {
            my $j = "X";
            my $mutect_chr_path = "$mutect_id_path/chr".$j."/";
            my $virmid_chr_path = "$virmid_id_path/chr".$j."/";
            my $indel_chr_path = "$indeldetector_id_path/chr".$j."/";
            
            my $mutect_pass_vcf = "$mutect_chr_path/$paired_id.chr$j.mutect.pass.vcf";
            my $virmid_pass_vcf = "$virmid_chr_path/$case.chr$j.recal.bam.virmid.som.passed.vcf";
#            my $virmid_pass_vcf = "$virmid_chr_path/$control.chr$j.recal.bam.virmid.som.passed.vcf";
            my $indel_pass_vcf = "$indel_chr_path/$paired_id.chr$j.indeldetector.pass.vcf";
           
            open my $tmp_mutect, '<:encoding(UTF-8)', $mutect_pass_vcf or die;
            while ( my $row = <$tmp_mutect>){
                chomp $row; 
                print $fh_mutect $row."\n";
            }close $tmp_mutect;
           print $virmid_pass_vcf; 
            open my $tmp_virmid, '<:encoding(UTF-8)', $virmid_pass_vcf or die;
            while ( my $row = <$tmp_virmid>){
                chomp $row;
                print $fh_virmid $row."\n";
            }close $tmp_virmid;

            open my $tmp_indel, '<:encoding(UTF-8)', $indel_pass_vcf or die;
            while ( my $row = <$tmp_indel>){
                chomp $row;
                print $fh_indel $row."\n";
            }close $tmp_indel;


        }elsif( $i == 24) {
            my $j = "Y";

            my $mutect_chr_path = "$mutect_id_path/chr".$j."/";
            my $virmid_chr_path = "$virmid_id_path/chr".$j."/";
            my $indel_chr_path = "$indeldetector_id_path/chr".$j."/";
            
            my $mutect_pass_vcf = "$mutect_chr_path/$paired_id.chr$j.mutect.pass.vcf";
            my $virmid_pass_vcf = "$virmid_chr_path/$case.chr$j.recal.bam.virmid.som.passed.vcf";
            # my $virmid_pass_vcf = "$virmid_chr_path/$control.chr$j.recal.bam.virmid.som.passed.vcf";
            my $indel_pass_vcf = "$indel_chr_path/$paired_id.chr$j.indeldetector.pass.vcf";
            
            open my $tmp_mutect, '<:encoding(UTF-8)', $mutect_pass_vcf or die;
            while ( my $row = <$tmp_mutect>){
                chomp $row; 
                print $fh_mutect $row ."\n";
            }close $tmp_mutect;
            
            open my $tmp_virmid, '<:encoding(UTF-8)', $virmid_pass_vcf or die;
            while ( my $row = <$tmp_virmid>){
                chomp $row;
                print $fh_virmid $row ."\n";
            }close $tmp_virmid;

            open my $tmp_indel, '<:encoding(UTF-8)', $indel_pass_vcf or die;
            while ( my $row = <$tmp_indel>){
                chomp $row;
                print $fh_indel $row ."\n";
            }close $tmp_indel;

        }else { 
            my $mutect_chr_path = "$mutect_id_path/chr".$i."/";
            my $virmid_chr_path = "$virmid_id_path/chr".$i."/";
            my $indel_chr_path = "$indeldetector_id_path/chr".$i."/";
            
            my $mutect_pass_vcf = "$mutect_chr_path/$paired_id.chr$i.mutect.pass.vcf";
            my $virmid_pass_vcf = "$virmid_chr_path/$case.chr$i.recal.bam.virmid.som.passed.vcf";
            # my $virmid_pass_vcf = "$virmid_chr_path/$control.chr$i.recal.bam.virmid.som.passed.vcf";
            my $indel_pass_vcf = "$indel_chr_path/$paired_id.chr$i.indeldetector.pass.vcf";
           
            print $mutect_pass_vcf."\n";
            open my $tmp_mutect, '<:encoding(UTF-8)', $mutect_pass_vcf or die;
            while ( my $row = <$tmp_mutect>){
                chomp $row; 
                print $fh_mutect $row."\n";
            }close $tmp_mutect;
           
            open my $tmp_virmid, '<:encoding(UTF-8)', $virmid_pass_vcf or die;
            while ( my $row = <$tmp_virmid>){
                chomp $row;
                print $fh_virmid $row."\n";
            }close $tmp_virmid;

            open my $tmp_indel, '<:encoding(UTF-8)', $indel_pass_vcf or die;
            while ( my $row = <$tmp_indel>){
                chomp $row;
                print $fh_indel $row."\n";
            }close  $tmp_indel;

        }

    }
    close $fh_mutect;
    close $fh_virmid;
    close $fh_indel;
}

sub make_dir {
    my $file = shift;
    if ( !-d $file ){
        my $cmd_make = "mkdir -p $file";
        system($cmd_make)
    }
}

sub read_config {
    my ($in_config, $ref_hash) = @_;
    open my $fh, '<:encoding(UTF-8)', $in_config or die;
    while (my $row=<$fh>){
        chomp $row;
        my ($key, $value) = split /\=/, $row;
        if ($row =~ /^#/) {next;}
        if (length($row) == 0) {next;}
        $key = trim ($key); 
        $value = trim ($value);
        $ref_hash->{$key}=$value;
    }
    close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @result:$result[0];
}

sub printUsage {
    print "Usage: perl $0 <in_config> \n";
    exit;
}
