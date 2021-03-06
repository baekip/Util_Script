#!/usr/bin/perl

# Function
#
use strict;
use warnings;

if ( 1 != @ARGV){
    printUsage();
}
my $in_config = $ARGV[0];

my %info;
read_config ($in_config, \%info);

my $project_path = $info{project_path};
my $copynumber_id = $info{copynumber_id};
my @copynumber_list = split /\,/,$copynumber_id;
my $close_path = "$project_path/result/00_close_result/";
my $chr_end_ref = {
    'chr1' => '249250621', 'chr2' => '243199373', 'chr3' => '198022430', 'chr4' => '191154276', 'chr5' => '180915260',
    'chr6' => '171115067', 'chr7' => '159138663', 'chr8' => '146364022', 'chr9' => '141213431', 'chr10' => '135534747',
    'chr11' => '135006516', 'chr12' => '133851895', 'chr13' => '115169878', 'chr14' => '107349540', 'chr15' => '102531392',
    'chr16' => '90354753', 'chr17' => '81195210', 'chr18' => '78077248', 'chr19' => '59128983', 'chr20' => '63025520', 
    'chr21' => '48129895', 'chr22' => '51304566', 'chrX' => '155270560', 'chrY' => '59373566'
};
my $total_summary_result = "$close_path/Total_summary_result.txt"; # output file

open my $fh_result, '>', $total_summary_result or die;
#print $fh_result "Sample_ID\tGain\tNormal\tLoss\tCN Neutral LOH\tAmbiguous\tTotal\tLOH\tLST\tTAI\tHRD-model Score\n";
print $fh_result "Sample_ID\tGain\tNormal\tLoss\tCN Neutral LOH\tAmbiguous\tTotal\tLOH\tLST\tTAI\tTotal HRD\tHRD-model Score\n";

foreach(@copynumber_list){
    my ($patient_id, $pair_id) = split/\:/, $_;

    my $segmentation_output = "$close_path/$pair_id/$patient_id.CNstatus.txt";
    open my $fh_seg, '<:encoding(UTF-8)', $segmentation_output or die;
    #print $patient_id."\n";
    my $TAI_criteria = 1000000; my $TAI_length = 3000000; my $LST_criteria = 15000000; my $LOH_criteria = 10000000; 
    my $gain_count=0; my $normal_count=0; my $loss_count=0; my $loh_count=0; my $ambiguous_count=0;
    my $loh_score=0; my $lst_score=0; my $tai_score=0; 
    ##counting copy number category
    while ( my $row = <$fh_seg>){
        chomp $row;
        my @seg_row = split /\s/, $row;
        my $chr = $seg_row[0];
        my $status_cluster = $seg_row[8];
        if ($chr eq "chr") {next;}
        if ($status_cluster =~ /^status_cluster/){next;}
        my $start = $seg_row[1]; 
        my $end = $seg_row[2];
        my $chr_end = $chr_end_ref->{$chr};
        my $end_term = $chr_end - $end;
        my $length = $end - $start;

        if ($status_cluster =~ /^Gain/){
            if ($length >= 15000000){ $lst_score++; }
            if ($length >= 3000000 and $start < 1000000){ $tai_score++; }
            if ($length >= 3000000 and $end_term < 1000000){ $tai_score++; }
            $gain_count++;
        }elsif ($status_cluster =~ /^Loss/){
            if ($length >= 15000000){ $lst_score++; }
            if ($length >= 3000000 and $start < 1000000){ $tai_score++; }
            if ($length >= 3000000 and $end_term < 1000000){ $tai_score++; }
            $loss_count++;
        }elsif ($status_cluster =~ /^Normal/){
            $normal_count++;
        }elsif ($status_cluster =~ /^CN_Neutral_LOH/){
            if ($length >= 15000000){ $lst_score++; }
            if ($length >= 10000000){ $loh_score++; }
            if ($length >= 3000000 and $start < 1000000){ $tai_score++; }
            if ($length >= 3000000 and $end_term < 1000000){ $tai_score++; }
            $loh_count++;
        }elsif ($status_cluster =~ /^Ambiguous/){
            $ambiguous_count++;
        }else {
            die "ERROR! Not Defined \"$status_cluster\" \n";
        }
    } 
    #HRD-model score
    #(0.11XHRD-LOH + 0.25XHRD-TAI + 0.12XHRD-LST)
    my $total = $gain_count + $normal_count + $loss_count + $loh_count + $ambiguous_count;
    my $total_HRD = $loh_score + $tai_score + $lst_score;
    my $HRD_score = 0.11*$loh_score + 0.25*$tai_score + 0.12*$lst_score;
    print $fh_result "$patient_id\t$gain_count\t$loss_count\t$normal_count\t$loh_count\t$ambiguous_count\t$total\t$loh_score\t$lst_score\t$tai_score\t$total_HRD\t$HRD_score\n";
    close $fh_seg;
}
close $fh_result;

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


sub printUsage{
    print "perl $0 <in.config> \n";
    exit;
}

sub checkFile{
    my $file = shift;
    if (!-f $file){
        die "ERROR ! not found <$file>\n";
    }
}
