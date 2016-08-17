#!/usr/bin/perl


#-------------------
#Author:Baek Inpyo
#Date: 11-March 2016
#-------------------

use strict;
use warnings;


if ( 1 != @ARGV ) {
    printUsage();
}

my $in_config = $ARGV[0];
print $in_config;

my %info;
read_config ($in_config, \%info);

my $project_path = $info{project_path};
my $mpileup_path = "$project_path/result/17_samtools_mpileup";
my $sequenza_result_path = "$project_path/result/00_sequenza_result";
my $samtools = $info{samtools};
my $reference = $info{reference};
my $sequenza = $info{sequenza};
my $sh_path = "$project_path/result/sh_file";
my $hg19_gc50base = "/BiO/BioProjects/NCC-Human-WES-2016-06-TBD160355/hg19.gc50Base.txt.gz";

print $sequenza."\n";

my @delivery_list = split /\,/, $info{delivery_tbi_id};
my @list_pair_id = split /\,/, $info{pair_id};

my %delivery_hash;
delivery_split (\@delivery_list, \%delivery_hash);

foreach (@list_pair_id) {
    my $pair_id = $_;
    my $merged_sequenza_dir = "$sequenza_result_path/$pair_id";
    make_dir($merged_sequenza_dir);

    my ($normal_id, $tumor_id) = split /\_/, $_;
    my $normal_mpileup = "$mpileup_path/$normal_id/$normal_id.mpileup";
    check_file($normal_mpileup);
    my $tumor_mpileup = "$mpileup_path/$tumor_id/$tumor_id.mpileup";
    check_file($tumor_mpileup);
    my $cmd_sequenza = "$sequenza pileup2seqz -gc $hg19_gc50base -n $normal_mpileup -t $tumor_mpileup | gzip > $merged_sequenza_dir/$pair_id.out.seqz.gz";

    my $sh_sequenza_path = "$sh_path/00_sequenza_result/$pair_id";
    make_dir($sh_sequenza_path);
    my $sh_sequenza = "$sh_sequenza_path/$pair_id.sequenza.sh";
    
    open my $fh_sequenza, '>', $sh_sequenza or die;
    print $fh_sequenza "date \n";
    print $fh_sequenza $cmd_sequenza."\n";
    print $fh_sequenza "date \n";
    close $sh_sequenza;

    my $cmd_qsub = "qsub -V -e $sh_sequenza_path -o $sh_sequenza_path -S /bin/bash $sh_sequenza";
    system($cmd_qsub);

}


=pod    
foreach (@delivery_list) {
    my ($delivery_id, $tbi_id, $type_id ) = split /\:/, $_;
    my $mpileup_file = "$mpileup_path/$tbi_id/$tbi_id.mpileup";
    my 
#    check_file ($mpileup_file);

}
=cut

sub make_dir {
    my $dir = shift;
    if ( !-d $dir) {
        my $cmd_dir = "mkdir -p $dir ";
        system ($cmd_dir);
    }
}

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    for (@$delivery_list) {
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
    }
}

sub check_file {
    my $file = shift;
    if (!-e $file) {
        print "Not exist $file !!! \n";
#        exit;
    }
}

sub read_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>) {
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
    }return wantarray ? @result:$result[0];
}


sub printUsage {
    print "Usage: perl $0 <in.config> \n";
    exit;
}

