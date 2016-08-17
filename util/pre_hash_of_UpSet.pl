#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Data::Dumper; 
use Cwd qw(abs_path);

my $input_path = dirname( abs_path $ARGV[1] );

if (@ARGV != 2) {
    printUsage();
}

my $union_file = "$input_path/$ARGV[0]";
checkFile($union_file);
my $sample_file = "$input_path/$ARGV[1]";
checkFile($sample_file);


my %scaffold_ids;
read_scaffold_ids($union_file,\%scaffold_ids);
#print Dumper %scaffold_ids;

my @sample_ids = read_sample_ids ($sample_file);
#print Dumper @sample_ids;

my %result;
foreach my $sample_id (@sample_ids) {
    my $target_file = "$input_path/$sample_id.venninput";
    checkFile($target_file);
    
    open my $fh, '<:encoding(UTF-8)', $target_file or die; 
    while (my $row = <$fh>){
        chomp $row;

        if ($scaffold_ids{$row}){ # if exist the scaffold ids in target_file
            $result{$row}{$sample_id}++;
        }
    }
    close ($fh);
}

## print table

my $output_file = "$input_path/output.upset.summary.csv";
open my $fh_output, '>', $output_file or die;
my $header = join ";", @sample_ids;
print $fh_output "Scaffold_ids;$header\n";

foreach my $scaffold (keys %scaffold_ids){
    my @line_result;
    foreach my $sample_id (@sample_ids){
        my $value;
        if ($result{$scaffold}{$sample_id}){
            $value = 1;
        }else{
            $value = 0;
        }
        push @line_result, $value;
    }
    my $line = join ";", @line_result;
    print $fh_output "$scaffold;$line\n";
}
close $fh_output;



sub read_sample_ids {
    my $file = shift;
    my @array;
    open my $fh, '<:encoding(UTF-8)', $file or die; 
    while (my $row = <$fh>){
        chomp $row;
        push @array, $row;
    }
    close ($fh);
    return @array;
}


sub read_scaffold_ids {
    my $file = shift;
    my $hash_ref = shift;

    open my $fh, '<:encoding(UTF-8)', $file or die; 
    while (my $row = <$fh>){
        chomp $row;
        $hash_ref->{$row}++ #value count
    }
    close ($fh);
}

=pod
my @union_list;
while (my $row_union = <$fh_union>){
    chomp $row_union;
    push @union_list, $row_union;
}close $fh_union;

=pod
my $check_file = "$input_path/JB.venninput";
checkFile($check_file);
print "$check_file\n";
open my $fh_check, '<:encoding(UTF-8)', $check_file or die;
while (my $row_check = <$fh_check>) {
    chomp $row_check;
    foreach (@union_list){  
       if(@union_list eq grep { $_ eq $row_check } @union_list){
            print "$sample_name;$_;1\n";
        }else{
             print "$sample_name;$_;0\n";
            next;
        }
    }
}close $fh_check;
=cut

=pod
foreach (@sample_list){
    my $sample_name = $_;
    print $sample_name."\n";
    my $check_file = "$input_path/$sample_name.venninput";
    checkFile($check_file);
    print "$check_file\n";
    open my $fh_check, '<:encoding(UTF-8)', $check_file or die;
    while (my $row_check = <$fh_check>) {
        chomp $row_check;
        foreach (@union_list){  
           if(@union_list eq grep { $_ eq $row_check } @union_list){
                print "$sample_name;$_;1\n";
            }else{
#                print "$sample_name;$_;0\n";
                next;
            }
        }
   }close $fh_check;
}
=cut
=pod
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
=cut    
#sub module

sub checkFile {
    my $file = shift;
    if (!-f $file){
        die "ERROR ! not found <$file>\n";
    }
}


sub printUsage{
    print "Usage: perl $0 <Union.file> <Sample.list.file> <output.result.file>\n";
    print "Example: perl $0 SNP.union.txt Sample_list UpSet_Input\n";
    exit;
}


