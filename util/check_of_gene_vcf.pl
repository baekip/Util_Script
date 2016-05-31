#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Cwd qw(abs_path);

if ( @ARGV != 2 ) {
    printUsage();
}

my $script_path = dirname(abs_path $0);
my $in_config = $ARGV[0];
my $output_file = $ARGV[1];

my %info;
read_config($in_config,\%info);

my $project_path = $info{project_path};
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id;
my $candidate_pos = $info{candidate_position};

my ($gene_chr,$pos) = split/\:/, $candidate_pos;
print $gene_chr;


my ($gene_start, $gene_end) = split /\-/, $gene_pos;

my $vcf_path = "$project_path/result/13_gatk_unifiedgenotyper";
dir_check($vcf_path);
my $snpeff_path = "$project_path/result/14_snpeff_human_run";
dir_check($snpeff_path);

open my $fh_output, '>', $output_file or die;

##make header###
print "CHROM\tPOS\tREF\tALT\t";
foreach (@delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
    print "$tbi_id\t";
}
print "\n";

foreach (@delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
    my $my_vcf_path = "$vcf_path/$tbi_id";
    my $vcf_file = "$my_vcf_path/$tbi_id.BOTH.vcf";

    my $my_snpeff_path = "$snpeff_path/$tbi_id";
    my $snpeff_file = "$my_snpeff_path/$tbi_id.BOTH.snpeff.tsv.tmp";

#    print $tbi_id."\n";

    open my $fh_vcf, '<:encoding(UTF-8)', $vcf_file or die;
    while (my $row = <$fh_vcf>){
        chomp $row;
        # my @tmp;
        my @column = split /\t/, $row;
        if ( $column[0] eq $my_gene_chr){# print "$column[1]||$start   &&   $column[1]||$end   \n"; 
            if (($column[1] > $start) && ($column[1] < $end)){
#                print "$column[0]\t$column[1]\n";
                # my $information = "$column[0]\t$column[1]\n";
                # push @tmp, $information;
            }
        }# push @final,@tmp;
    }
    close $fh_vcf;
}


sub dir_check {
    if ( !-d $vcf_path ){
        print "ERROR!! $vcf_path not exist!!\n";
        exit;
    }
}

sub read_config {
    my ($config, $ref_hash) = @_;
    open my $fh, '<:encoding(UTF-8)', $config  or die;
    while (my $row = <$fh>) {
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length($row) == 0) {next}
        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim($value);
        $ref_hash->{$key}=$value;
    }close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    } return wantarray ? @result:$result[0];
}

sub printUsage {
    print "Usage: perl $0 <in_config> <output_file> \n";
    print "Example: perl $0 </BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-2/check_gene_config.txt> </BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-2/Total_Ovary_Cancer_BRCA2.txt>\n";
    exit;
}

