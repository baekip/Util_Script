#############################################################
#CNVkit report V0.3.1
#Date - 2017.01.13
#Author - baekip
#############################################################
#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(cp_file read_config trim checkFile make_dir); 

my $in_config;
GetOptions(
    'config=s' => \$in_config,
);

if (!defined $in_config or !-f $in_config){
    die "ERROR! check your config file with -c option \n";
}

my $config_path = dirname (abs_path $in_config);
$in_config =  "$config_path/$in_config";
print "read config: $in_config \n";

my %info;
read_config($in_config, \%info);

#############################################################
#Requirement 
#############################################################
my $project_path=$info{project_path};
my $sample_id=$info{sample_id};
my $pair_id=$info{pair_id};
my $bcftools=$info{bcftools};
my $cytoband=$info{cytoband};
my @sample_list=split /\,/, $sample_id;
my @paired_list=split /\,/, $pair_id;

#############################################################
#1.make table description
#############################################################
my $cnv_path="$project_path/result/00_Somatic_SV_run/01_cnv_run";

foreach my $id (@paired_list){
    my $gainloss_input = "$cnv_path/$id/$id\.gene.gainloss";
    my $gainloss_cyto = "$cnv_path/$id/$id\.cyto.gainloss";
    open my $fh_cyto, '>', $gainloss_cyto or die;
    open my $fh, '<:encoding(UTF-8)', $gainloss_input or die;
    print $fh_cyto "gene\tchromosome\tstart\tend\tlog2\tdepth\twight\tcn\tprobes\tcytoband\n";
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^gene/){
            next;
        }
        my ($gene, $chr, $start, $end, $log2, $depth, $weight, $cn, $probes) = split /\t/, $row;
        my $cyto_input = "$chr:$start-$end";
        my $cyto_val = cytoband_run($cyto_input);
        $cyto_val = trim ($cyto_val);
        print $fh_cyto "$row\t$cyto_val\n";
#        print "$gene\t$chr\t$start\t$end\t$log2\t$depth\t$weight\t$cn\t$probes\t$cyto_val\n";
    }
    close $fh;
    close $fh_cyto;
}

#############################################################
#sub 
#############################################################
sub cytoband_run { 
    my $input = shift;
    my $val = `bash $cytoband $input`;
    $val = trim ($val);
    return $val;
}
