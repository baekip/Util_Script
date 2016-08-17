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

my %info;
read_config ($in_config, \%info);

my $project_path = $info{project_path};
my $close_vcf_path = "$project_path/result/00_close_vcf/";
make_dir($close_vcf_path);
my $samtools = $info{samtools};
my $reference = $info{reference};
my $sh_path = "$project_path/result/sh_file";
my $sh_close_path = "$sh_path/00_close_vcf/";
make_dir($sh_close_path);
my $snpeff = $info{snpeff};
my $snpeff_config = $info{snpeff_config};
#my $gatk = $info{gatk};
my $gatk = "/BiO/BioTools/GATK/3.4-46/GenomeAnalysisTK.jar";
my $bam_path = "$project_path/result/12_gatk_printrecal/";
my $freebayes_filter = "/BiO/BioTools/CLOSE/scripts/freebayes_filter.py";

my $java = $info{java_1_7};
my $freebayes_path = "$project_path/result/00_freebayes_result/";

my @delivery_list = split /\,/, $info{delivery_tbi_id};
my @list_pair_id = split /\,/, $info{pair_id};

foreach (@delivery_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
    my $freebayes_vcf = "$freebayes_path/$tbi_id.freebayes.targeted.vcf";
    my $close_vcf_path = "$close_vcf_path/$tbi_id";
    make_dir($close_vcf_path);

    my $sh_sample_close = "$sh_close_path/$tbi_id";
    make_dir($sh_sample_close);
    my $sh_close = "$sh_sample_close/$tbi_id.close.sh";
    open my $fh_close, '>', $sh_close or die;
    
    print $fh_close "date \n\n";
    print $fh_close "export PATH=/BiO/BioTools/freebayes/vcflib/bin:/BiO/BioTools/freeBayes/freebayes/bin:\$PATH\n";
    print $fh_close "vcffilter -f \"QUAL > 30\" $freebayes_vcf > $close_vcf_path/$tbi_id.freebayes.filtered.vcf \n";
    print $fh_close "cat $close_vcf_path/$tbi_id.freebayes.filtered.vcf \| $java -Xmx4G -Xms4G -jar $snpeff eff -motif -nextProt -lof -v -c $snpeff_config -hgvs -i vcf -o gatk GRCh37.75 > $close_vcf_path/$tbi_id.freebayes.ann.3.vcf 2> $close_vcf_path/$tbi_id.snpEff.log \n";
    print $fh_close "$java -Xmx3G -Xms3G -jar $gatk -R $reference  -T VariantAnnotator -I $bam_path/$tbi_id/$tbi_id.printrecal.bam -o $close_vcf_path/$tbi_id.var.ann.3.vcf --variant $close_vcf_path/$tbi_id.freebayes.ann.3.vcf -L $close_vcf_path/$tbi_id.freebayes.ann.3.vcf -A Coverage -A QualByDepth -A MappingQualityRankSumTest -A ReadPosRankSumTest -A FisherStrand -A MappingQualityZero -A LowMQ -A RMSMappingQuality -A BaseQualityRankSumTest -rf BadCigar > $close_vcf_path/$tbi_id.gatk.ann.3.log > $close_vcf_path/$tbi_id.var.ann.3.vcf \n";

#    -I /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418-3/result/12_gatk_printrecal/TN1512D0673/TN1512D0673.printrecal.bam -o ${sample_name}.var_ann.3.vcf --variant ${sample_name}.freebayes.ann.3.vcf -L ${sample_name}.freebayes.ann.3.vcf -A Coverage -A QualByDepth -A MappingQualityRankSumTest -A ReadPosRankSumTest -A FisherStrand -A MappingQualityZero -A LowMQ -A RMSMappingQuality -A BaseQualityRankSumTest -rf BadCigar > gatk_ann.3.log 2>&1

    print $fh_close "cat $close_vcf_path/$tbi_id.var.ann.3.vcf \| vcffilter -f \"DP > 7\" \| python $freebayes_filter 40 40 30 4 0 > $close_vcf_path/$tbi_id.annotated.filtered3.vcf 2> $close_vcf_path/$tbi_id.fb_filter3.log \n\n";
    print $fh_close "date \n";

    close $fh_close;

    my $cmd_qsub = "qsub -V -e $sh_sample_close -o $sh_sample_close -S /bin/bash $sh_close ";
    system($cmd_qsub);
}

=pod
    my $normal_mpileup = "$mpileup_path/$normal_id/$normal_id.mpileup";
    check_file($normal_mpileup);
    my $tumor_mpileup = "$mpileup_path/$tumor_id/$tumor_id.mpileup";
    check_file($tumor_mpileup);
    my $cmd_sequenza = "$sequenza pileup2seqz -gc $hg19_gc50base -n $normal_mpileup -t $tumor_mpileup | gzip > $merged_sequenza_dir/$pair_id.out.seqz.gz";

    my $sh_close_path = "$sh_path/00_close_vcf/$_id";
    make_dir($sh_sequenza_path);
    
    print $fh_sequenza "date \n";
    print $fh_sequenza $cmd_sequenza."\n";
    print $fh_sequenza "date \n";
    close $sh_sequenza;

    my $cmd_qsub = "qsub -V -e $sh_sequenza_path -o $sh_sequenza_path -S /bin/bash $sh_sequenza";
    system($cmd_qsub);

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
