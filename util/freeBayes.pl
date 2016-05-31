#!/usr/bin/perl

use strict;
use warnings;

if ( 1 != @ARGV ) {
    printUsage();
}


my $in_config = $ARGV[0];

my %info;
read_config($in_config, \%info);

##Requirement##
my $excavator_path = $info{excavator_path};
my $project_path = $info{project_path};
my $target_bed = $info{target_bed};
my $bam_path = "$project_path/result/12_gatk_printrecal";
my @target_bed = split /\//,$target_bed;
my $bed_name = substr($target_bed[-1],0,-4);
my $reference = $info{reference};
my $hg_version = $info{snpeff_db};
my $pair_id = $info{pair_id};
my $samtools = $info{samtools};
my $project_id = $info{project_id};
my $freebayes = $info{freebayes};
my $bedtools = $info{bedtools};
my $delivery_tbi_id = $info{delivery_tbi_id};
#------------------------------------------------------


my $freebayes_path ="$project_path/result/00_freebayes_result/";
make_dir($freebayes_path);


my @delivery_list = split /\,/, $delivery_tbi_id;
for(@delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
    my $sample_bam_file = "$bam_path/$tbi_id/$tbi_id.printrecal.bam";
    my $sh_freebayes = "$freebayes_path/$tbi_id.freebayes.sh";
    open my $fh_sh, '>', $sh_freebayes or die; 
    my $cmd_freebayes = "$freebayes -f $reference $sample_bam_file  > $freebayes_path/$tbi_id.freebayes.vcf";
    my $cmd_grep = "cat $freebayes_path/$tbi_id.freebayes.vcf \| grep \'#\' > $freebayes_path/$tbi_id.freebayes.targeted.vcf";
    my $cmd_bedtools = "$bedtools intersect -a $freebayes_path/$tbi_id.freebayes.vcf -b $target_bed >> $freebayes_path/$tbi_id.freebayes.targeted.vcf";
#    my $cmd_freebayes = "$freebayes -f $reference $sample_bam_file \| vcffilter -f \"QUAL > 30\" > $freebayes_path/$tbi_id.freebayes.vcf";
    print $fh_sh "date \n";
    # print $fh_sh "$cmd_freebayes \n";
    print $fh_sh "$cmd_grep \n";
    print $fh_sh "$cmd_bedtools \n";
    print $fh_sh "date";
    close $fh_sh;
    my $cmd_qsub = "qsub -V -e $freebayes_path -o $freebayes_path -S /bin/bash $sh_freebayes";
    system($cmd_qsub);
}

sub make_dir {
    my $dir_name = shift;
    if (!-d $dir_name){
        my $cmd_mkdir = "mkdir -p $dir_name";
        system ($cmd_mkdir);
    }
}

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    for (@$delivery_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
    }
}

sub read_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while ( my $row = <$fh>) {
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length($row) == 0 ) {next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim($value);
        $hash_ref->{$key}=$value;
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

sub printUsage{
    print "perl $0 <in.config> \n";
    exit;
}

