#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Cwd qw(abs_path);

my $script_path = dirname( abs_path $ARGV[0]);
my $orig_rawdata_path = "$script_path/result/01_fastqc_orig/";

if (@ARGV != 1){
    printUsage();
}

my $in_config = $ARGV[0];

my %info;
read_config ($in_config, \%info);

my $project_path = $info{project_path};
my $sample_id = $info{sample_id};
my $additional_bp_range = $info{additional_bp_range};
my @list_sample_id = split /\,/, $sample_id;


my $seqtk_exe = "/BiO/BioTools/seqtk/dev/seqtk";

my $fastqc_path = "$project_path/result/01_fastqc_orig";
my $sh_dir = "$project_path/result/sh_log_file";
my $result_seqtk = "$project_path/result/00_seqtk_cut";
my $sh_seqtk = "$sh_dir/00_seqtk_cut";
make_dir($sh_seqtk);


#/BiO/BioProjects/GREECE-Human-WES-2015-10-TBO150073/result/01_fastqc_orig/TN1509D0878
#qsub -cwd -S /usr/bin/perl
#fastqc.TN1509D0878.1.sh

foreach (@list_sample_id) {
    my ($tbi_id, $customer_size) = split/\:/, $_;
    
    
    my $sample_result_dir = "$result_seqtk/$tbi_id";
    make_dir($sh_seqtk);
    my $sh_log_dir = "$sh_seqtk/$tbi_id";
    make_dir($sh_log_dir);
    my $rawdata_path = "$project_path/rawdata/$tbi_id";
    make_dir($rawdata_path);
    
    my $half_size = $customer_size/2;
    my $customer_bp = $half_size * 1000000000;
    my $customer_line = int ( ($customer_bp / 101) * ($additional_bp_range + 1) )  ; 
    
    my $fastqc_raw_1 = "$fastqc_path/$tbi_id/$tbi_id"."_1.fastq.gz";
    my $fastqc_raw_2 = "$fastqc_path/$tbi_id/$tbi_id"."_2.fastq.gz";
   
    my $new_read_1 = "$rawdata_path/$tbi_id"."_1.fastq.gz";
    my $new_read_2 = "$rawdata_path/$tbi_id"."_2.fastq.gz";

    print "Trimming of $fastqc_raw_1: $half_size Gbp \n";
    print "Trimming of $fastqc_raw_2: $half_size Gbp \n";

    my $seqtk_sh_1 = "$sh_log_dir/seqtk.$tbi_id"."_1.sh";
    my $seqtk_sh_2 = "$sh_log_dir/seqtk.$tbi_id"."_2.sh";
    

    open my $fh_sh_1, '>', $seqtk_sh_1 or die;
    print $fh_sh_1 "date \n";
    my $command_1 = "$seqtk_exe sample -2 -s100 $fastqc_raw_1 $customer_line | gzip -c > $new_read_1 \n";
    print $fh_sh_1 $command_1;
    print $fh_sh_1 "date \n";
    close $fh_sh_1;
    my $cmd_qsub_sh_1 = "qsub -V -e $sh_log_dir -o $sh_log_dir -S /bin/bash $seqtk_sh_1";
    system($cmd_qsub_sh_1);
    print $command_1."\n";


    open my $fh_sh_2, '>', $seqtk_sh_2 or die;
    print $fh_sh_2 "date \n";
    my $command_2 = "$seqtk_exe sample -2 -s100 $fastqc_raw_2 $customer_line | gzip -c > $new_read_2 \n";
    print $fh_sh_2 $command_2;
    print $fh_sh_2 "date \n";
    my $cmd_qsub_sh_2 = "qsub -V -e $sh_log_dir -o $sh_log_dir -S /bin/bash $seqtk_sh_2";
    system($cmd_qsub_sh_2);
    print $command_2."\n";
}


sub make_dir {
    my $dir_name = shift;
    if (!-d $dir_name){
        system ("mkdir -p $dir_name");
    }
}


sub read_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>) {
        chomp $row; 
        if ($row =~ /^#/) { next; }
        if ( length $row == 0 ) { next; }

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


sub printUsage {
    print "Usage: perl $0 <in_trim_config> \n";
    exit;
}
