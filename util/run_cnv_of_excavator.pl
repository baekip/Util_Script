#!/usr/bin/perl

if ( @ARGV != 1 ) {
    printUsage();
}

my $in_config = $ARGV[0];

my %info;
read_config($in_config, \%info);

##Requirement##
my $excavator_path = $info{excavator_path};
my $project_path = $info{project_path};
my $target_bed = $info{target_bed};
my $bam_path = "$project_path/result/12_gatk_printrecal";
my @target_bed = split /\//,$target_bed;
my $bed_name = substr($target_bed[-1],0,-4);
my $reference = $info{reference};
my $hg_version = $info{snpeff_db};
my $pair_id = $info{pair_id};
my $samtools = $info{samtools};
my $project_id = $info{project_id};

my $cnv_output = "$project_path/result/41_cna_call";
make_dir ($cnv_output);

##############################################################################################
###############################Make a SourceTarget.txt########################################
##############################################################################################
#/BiO/BioTools/EXCAVATOR_Package_v2.2.2/EXCAVATOR/data/hg19_uniqueome.coverage.base-space.25.1.Wig /BiO/BioResources/References/Human/hg19/hg19.fa

my $source_target_txt = "$cnv_output/SourceTarget.txt";
open (my $fh_target,'>',$source_target_txt) or die;
print $fh_target "$excavator_path/data/hg19_uniqueome.coverage.base-space.25.1.Wig $reference";
close $fh_target;

##############################################################################################
###############################Make Read_Input.txt############################################
##############################################################################################
#OneSeq hg19 /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result/12_gatk_printrecal/TN1511D0287-1/TN1511D0287-1.printrecal.bam BuffyCoat C1
#OneSeq hg19 /BiO/BioProjects/Asan-Human-WES-2015-12-TBD150418/result/12_gatk_printrecal/TN1511D0306/TN1511D0306.printrecal.bam OV_044 T1

my @list_sample_id = split /\,/, $info{delivery_tbi_id};
my @list_pair_id = split /\,/, $pair_id;
my %delivery_hash;
delivery_split (\@list_sample_id, \%delivery_hash);

my $log_path = "$project_path/result/sh_log_file/41_cna_call/";
make_dir($log_path);

for (my $i=0; $i<@list_pair_id; $i++){
    my $sh_dir = "$log_path/$list_pair_id[$i]";
    make_dir ($sh_dir);
    
    my $read_input_txt = "$log_path/$list_pair_id[$i]/Read_Input_$list_pair_id[$i].txt";
    open (my $fh_input,'>',$read_input_txt) or die;
    
    my $j = $i+1;
    my ($control, $case) = split /\_/, $list_pair_id[$i];
    my $delivery_case = "$delivery_hash{$case}_$j";
    print "CNV Processing: $delivery_case \n";
    my $control_bam = "$bam_path/$control/$control.printrecal.bam";
    my $case_bam = "$bam_path/$case/$case.printrecal.bam";
    print $fh_input "$bed_name $hg_version $control_bam $delivery_case"."_control C$j \n";
    print $fh_input "$bed_name $hg_version $case_bam $delivery_case T$j \n";
    close $read_input_txt;
}

###############################################################################################
###################################Running_sh_script###########################################
###############################################################################################
#export PATH=$PATH:/BiO/BioTools/samtools/samtools-0.1.19/samtools

my $samtools_path = "export PATH=\$PATH:$samtools";
system($samtools_path);

my $cmd_target_perl = "perl $excavator_path/TargetPerla.pl $source_target_txt $target_bed $bed_name";
#my $cmd_read_perl = "perl $excavator_path/ReadPerla.pl $read_input_txt $cnv_output --mode somatic";

for (my $i=0; $i<@list_pair_id; $i++){
    my $j = $i+1;
    my ($control, $case) = split /\_/, $list_pair_id[$i];
    my $delivery_case = "$delivery_hash{$case}_$j";
    my $convert_sh = "$log_path/$list_pair_id[$i]/convert_png.$list_pair_id[$i].sh";
    open (my $fh_convert ,'>',$convert_sh) or die;
    
    my $plot_path = "$cnv_output/$list_pair_id[$i]/Plots/$delivery_case";
    for (my $k=1; $k<23; $k++){
        print $fh_convert "convert -density 150 $plot_path/PlotResults_chr$k.pdf -quality 100 $plot_path/PlotResults_chr$k.png\n";
    }
    print $fh_convert "convert -density 150 $plot_path/PlotResults_chrX.pdf -quality 100 $plot_path/PlotResults_chr23.png\n";
    print $fh_convert "convert -density 150 $plot_path/PlotResults_chrY.pdf -quality 100 $plot_path/PlotResults_chr24.png\n";
    close $fh_convert;

    my $read_input_txt = "$log_path/$list_pair_id[$i]/Read_Input_$list_pair_id[$i].txt";
    my $excavator_sh = "$log_path/$list_pair_id[$i]/excavator.$list_pair_id[$i].sh";
    my $cnv_pair_output_path = "$cnv_output/$list_pair_id[$i]";
   
    make_dir ($cnv_pair_output_path);

    open (my $fh_sh,'>', $excavator_sh) or die;
    print $fh_sh "#!/bin/bash\n";
    print $fh_sh "date\n";
    print $fh_sh "export PATH=\$PATH:/BiO/BioTools/samtools/samtools-0.1.19/\n";
    print $fh_sh $cmd_target_perl ."\n";
    print $fh_sh "perl $excavator_path/ReadPerla.pl $read_input_txt $cnv_pair_output_path --mode somatic\n";
    print $fh_sh "bash $convert_sh\n";
    print $fh_sh "date\n";
    close $fh_sh;
    
    my $cmd_qsub_sh = "qsub -V -e $log_path/$list_pair_id[$i] -o $log_path/$list_pair_id[$i] -S /bin/bash $excavator_sh";
    system ($cmd_qsub_sh);
}

###############################################################################################
###################################Sub_module##################################################
###############################################################################################
sub make_dir {
    my $dir_name = shift;
    if (!-d $dir_name){
        my $cmd_mkdir = "mkdir -p $dir_name";
        system ($cmd_mkdir);
    }
}

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    for (@$delivery_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
    }
}

sub read_config {
    my ($file, $hash_ref) = @_;
    open $fh, '<:encoding(UTF-8)', $file or die;
    while ( my $row = <$fh>) {
        chomp $row;
        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim($value);
        $hash_ref->{$key}=$value;
    }
    close $fh;
}

sub trim {
    @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @result:$result[0];
}

sub printUsage {
    print "perl $0 <in.sample.config> \n";
    print "example: perl $0 wes_config.human.txt\n";
    exit;
}

