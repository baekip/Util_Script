#!/usr/bin/perl

use warnings;
use strict;

if ( @ARGV !=2 ) {
    printUsage();
}

my $in_bed_file = $ARGV[0];
my $out_bed_file = $ARGV[1];

open my $fh, '<:encoding(UTF-8)', $in_bed_file or die;
open my $fh_out, '>', $out_bed_file;

while (my $row = <$fh>){
    chomp $row;
    my @bed_contents = split /\t/, $row;
    
    my $chr = $bed_contents[0];
    my $start = $bed_contents[1];
    my $end = $bed_contents[2];

    print $fh_out "$chr\t$start\t$end\t.\t0\t.\n";
}

close $fh;
close $fh_out;

sub printUsage {
    print "perl $0 <in.bed.file> <out.bed.file> \n";
    exit;
}
