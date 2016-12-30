##make MSIseqR input table for somatic analysis
##date 12-22 2016
##Author Baekip 
#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path);

my $in_config;
GetOptions(
    'config=s' => \$in_config,
);

if (!defined $in_config or !-f $in_config){
    die "ERROR! check your config file with -c option\n";
}

print $in_config."\n";
my $config_path = dirname(abs_path $in_config);
$in_config="$config_path/$in_config";
my %info;
read_general_config ($in_config, \%info);

#############################################################
#0.preparation
#############################################################

my $project_path=$info{project_path};
my $project_id=$info{project_id};
my $result_path="$project_path/result/";
my $MSI_path="$result_path/00_MSI_run";
make_dir($MSI_path);
print "$MSI_path\n";
my $bam_path="$result_path/12_gatk_printrecal";
my $vcf_path="$result_path/13_gatk_unifiedgenotyper";
my $annotation_path="$result_path/14_snpeff_human_run";
my $mutect_path="$result_path/30-1_mutect_run";
my $indel_path="$result_path/32-1_indeldetector_run";

my $pair_id=$info{pair_id};
my @pair_list=split /\,/, $pair_id;

#############################################################
#1.make input data of MSIseq R
#############################################################
my $MSIseq_input="$MSI_path/$project_id\_MSIseq.input";
open my $fh, '>', $MSIseq_input or die;

print $fh "Chrom\tStart_Position\tEnd_Position\tVariant_Type\tTumor_Sample_Barcode\n";
foreach my $id (@pair_list) {
    ###SNP
    my $SNP_vcf = "$mutect_path/$id/$id\.SNP.vcf";
    checkFile($SNP_vcf);
	open my $SNP_fh, '<:encoding(UTF-8)', $SNP_vcf or die;
	while (my $row = <$SNP_fh>) {
		chomp $row;
		if ($row =~ /^#/){ next; } # pass header line
		if (length($row) == 0){ next; }

		my ($chr,$pos,$rs_id,$ref,$alt,$qual,$filter,$info,$format,$sample1,$sample2) = split /\t/, $row;
                
                print $fh "$chr\t$pos\t$pos\tSNP\t$id\n";
	}
        close($SNP_fh);	
    ###INDEL
    my $INDEL_vcf = "$indel_path/$id/$id\.INDEL.vcf";
    checkFile($INDEL_vcf);
	open my $INDEL_fh, '<:encoding(UTF-8)', $INDEL_vcf or die;
	while (my $row = <$INDEL_fh>) {
		chomp $row;
		if ($row =~ /^#/){ next; } # pass header line
		if (length($row) == 0){ next; }

		my ($chr,$pos,$rs_id,$ref,$alt,$qual,$filter,$info,$format,$sample1,$sample2) = split /\t/, $row;
                $ref=trim($ref);
                $alt=trim($alt);
                #print $alt."\n";
                my $ref_len = length($ref);
                my $alt_len = length($alt);
                my $len_diff = $ref_len - $alt_len;
                #print $alt_len."\n";
                #my $len_diff=length($ref)-length($alt);
                if ($len_diff > 0) {
                    my $end = $pos;
                    print $fh "$chr\t$pos\t$end\tDEL\t$id\n";
                }elsif($len_diff < 0){
                    my $end = $pos - $len_diff;
                    print $fh "$chr\t$pos\t$end\tINS\t$id\n";
                }else{ print "CHECK YOUR <$INDEL_vcf> file!!! \n";}
	}
        close($INDEL_fh);
    }
close($fh);

#############################################################
#sub
#############################################################
sub checkFile{
	my $file = shift;
	if (!-f $file){
		die "ERROR ! not found <$file>\n";
	}
}

sub read_general_config{
	my ($file, $hash_ref) = @_;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/){ next; } # pass header line
		if (length($row) == 0){ next; }

		my ($key, $value) = split /\=/, $row;
		$key = trim($key);
		$value = trim($value);
		$hash_ref->{$key} = $value;
	}
	close($fh);	
}

sub trim {
	my @result = @_;

	foreach (@result) {
		s/^\s+//;
		s/\s+$//;
	}

	return wantarray ? @result : $result[0];
}

sub make_dir {
    my $dir_name = shift;
    if (!-d $dir_name){
        my $cmd_mkdir = "mkdir -p $dir_name";
        system ($cmd_mkdir);
    }
}

