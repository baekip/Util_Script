#!/usr/perl 

use strict;
use warnings;

use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $ARGV[0]);
print $script_path;

if ( @ARGV != 2) {
    printUsage();
}

my $in_previous_list = $ARGV[0];
my $in_additional_list = $ARGV[1];

open my $fp, '<:encoding(UTF-8)', $in_previous_list or die;
open my $fa, '<:encoding(UTF-8)', $in_additional_list or die;

my $samtools = "/BiO/BioTools/samtools/samtools-1.2/samtools";
my $sh_path = "$script_path/sh_file";
make_dir($sh_path);
#samtools merge out.bam in1.bam in2.bam in3.bam
#

while ( my $p_row = <$fp>, my $a_row = <$fa>) {
    chomp $p_row; chomp $a_row;

    my $p_row = trim($p_row); my $a_row = trim($a_row);
    my $previous_sample = "$script_path/$p_row";
    my $additional_sample = "$script_path/$a_row";
    my $merged_sample = "$script_path/Merged_$a_row";
    my $sh_file = "$sh_path/Merged_$a_row.sh"; 
    open my $sh,'>', $sh_file or die;
    
    my $md5sum_file = "$script_path/Merged_md5sum.txt";

    my $samtools_script = "$samtools merge $merged_sample $previous_sample $additional_sample";
    my $samtools_index = "$samtools index $merged_sample";
    my $md5sum_script = "md5sum $merged_sample >> $md5sum_file";
    my $cmd_qsub_sh = "qsub -V -e $sh_path -o $sh_path -S /bin/bash $sh_file";

    print $sh "date\n";
    print $sh $samtools_script."\n";
    print $sh $samtools_index."\n";
    print $sh $md5sum_script."\n";
    print $sh "date\n";

    #close ($sh_file,$sh);
    close $sh_file;
    print $cmd_qsub_sh."\n";
    system($cmd_qsub_sh);
    #close $md5sum;
    close $sh;
}


sub make_dir {
    my $dir_name = shift;
    if ( !-d $dir_name) {
        my $cmd_mkdir = "mkdir -p $dir_name";
        system ($cmd_mkdir);
    }
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
    print "Usage: perl $0 <Previous_Sample_list.txt> <Additional_Sample_list.txt> \n";
    exit;
}

