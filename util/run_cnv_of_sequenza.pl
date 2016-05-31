#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use Cwd qw(abs_path);



my $script_path = dirname(abs_path $ARGV[0]);

if ( @ARGV != 1) {
    printUsage();
}

my $in_config = $ARGV[0];

my %info;
read_config($in_config, \%info);


my $project_path = $info{project_path};
my $sequenza_path = $info{sequenza};
my $samtools = $info{samtools};
my $hg19_ref = $info{reference};

my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id;


#tumor mplieup 
foreach (@delivery_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
    my $cmd_tumor_mplieup = "$samtools mpileup -f $hg19_ref -Q 20 $





print $project_path;


sub read_config {
    my ($config, $ref_hash) = @_;
    open my $fh, '<:encoding(UTF-8)', $config or die;
    while ( my $row = <$fh>){
        chomp $row;
        if ( $row =~ /^#/ ) {next;}
        if ( length ($row) == 0 ) { next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $ref_hash->{$key}=$value;
    }close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    } return wantarray ? @result:$result[0];
}

sub printUsage {
    print "perl $0 <in.config> \n";
    exit;
}

