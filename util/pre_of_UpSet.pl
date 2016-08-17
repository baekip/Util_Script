#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Cwd qw(abs_path);

my $input_path = dirname( abs_path $ARGV[1] );

if (@ARGV != 2) {
    printUsage();
}

my $union_file = "$input_path/$ARGV[0]";
checkFile($union_file);
my $sample_file = "$input_path/$ARGV[1]";
checkFile($sample_file);
my $output_file = "$input_path/output.upset.summary.txt";
#my $output_file = "$input_path/$ARGV[2]";

#print $union_file."\n";
#print $output_file."\n";

open my $fh_list, '<:encoding(UTF-8)', $sample_file or die;
open my $fh_output, '>', $output_file or die;


my @sample_list;
while (my $row_list = <$fh_list>){
    chomp $row_list;
    push @sample_list, $row_list;
}

my @union_list;
open my $fh_union, '<:encoding(UTF-8)', $union_file or die; 
while (my $row_union = <$fh_union>){
    chomp $row_union;
    push @union_list, $row_union;
}close $fh_union;

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
                print "$sample_name;$_;0\n";
                next;
            }
        }
   }close $fh_check;
}
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
        open my $fh_union, '<:encoding(UTF-8)', $union_file or die; 
        while (my $row_union = <$fh_union>){
            chomp $row_union;
            my @union_list;
            push @union_list,$row_union;
            if(@union_list == grep { $row_union eq $row_check } @union_list){
                print "$sample_name;$row_union;1\n";
            }else{
                print "$sample_name;$row_union;0\n";
            };
        }close $fh_union;
   }close $fh_check;
}
=cut
=pod
foreach (@sample_list){
    my $sample_name = $_;
    print $sample_name."\n";
    my $check_file = "$input_path/$sample_name.venninput";
    checkFile($check_file);
    print "$check_file\n";
    open my $fh_union, '<:encoding(UTF-8)', $union_file or die; 
    while (my $row_union = <$fh_union>){
        chomp $row_union;
        my @union_list;
        push @union_list,$row_union;
        open my $fh_check, '<:encoding(UTF-8)',$check_file or die;
        while(my $row_check = <$fh_check>){
            chomp $row_check;
            print $row_union."\n";
            if(@union_list == grep { $row_union eq $row_check } @union_list){
                print "$sample_name;$row_union;1\n";
            }else{
                print "$sample_name;$row_union;0\n";
            };
        }close $fh_check;
    }close $fh_union;
}
=cut
=pod
foreach (@sample_list){
    my $sample_name = $_;
    my $check_file = "$input_path/$sample_name.venninput";
    checkFile($check_file);
    print "$check_file\n";
    open my $fh_union, '<:encoding(UTF-8)', $union_file or die; 
    while (my $row_union = <$fh_union>){
        my $criterion = chomp $row_union;
        open my $fh_check, '<:encoding(UTF-8)',$check_file or die;
        while(my $row_check = <$fh_check>){
            chomp $row_check;
            my @check_list;
            push @check_list, $row_check;
            foreach (@check_list){
                my $check = $_;
                if ($criterion eq $check){
                    print "$sample_name;$criterion;1\n";
                }else{};
            }
        }
    }close $fh_union;
}
=cut
#while (my $row_union = <$fh_union>){
#    chomp $row_union;
#}
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
