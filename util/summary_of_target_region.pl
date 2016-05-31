use strict;
use warnings;

if (@ARGV != 1) {
    printUsage();
}

my $in_config = $ARGV[0];
my $output_file = $ARGV[1];

my %info;
read_config ($in_config, \%info);

my $bcftools = $info{bcftools};
my $project_path = $info{project_path};
my $delivery_tbi_id = $info{delivery_tbi_id};
my $project_id = $info{project_id};

my @delivery_tbi_id = split /\,/, $delivery_tbi_id;
my $vcftools_path = "/BiO/BioTools/vcftools/0.1.12b";
my $tabix_path = "/BiO/BioTools/tabix/tabix-v0.2.5";
my $vcf_merge_pl = "/BiO/BioPeople/brandon/hmkim/BioScript/vcf/vcf_merge.pl";

my $candidate_pos = $info{candidate_position};
my @candidate_list = split /\,/, $candidate_pos;

my @my_vcf_list;
foreach (@delivery_tbi_id) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
    push (@my_vcf_list, "$project_path/result/13_gatk_unifiedgenotyper/$tbi_id/$tbi_id.BOTH.vcf");
    push (@my_vcf_list, " ");
}

my $my_vcf_list = join (" ", @my_vcf_list);
#print $my_vcf_list;

my $vcf_stat_path = "$project_path/result/00_vcf_target_stat";
make_dir ($vcf_stat_path);

my $merged_vcf_gz = "$vcf_stat_path/merged.vcf.gz";
my $cmd_merged = "perl $vcf_merge_pl -V $vcftools_path -T $tabix_path \"$my_vcf_list\" $merged_vcf_gz";
my $cmd_tabix = "$tabix_path/tabix $merged_vcf_gz";
print $cmd_merged."\n";
print $cmd_tabix."\n";

if ( !-f $merged_vcf_gz) {
    system($cmd_merged);
    system($cmd_tabix);
}

######snpeff to vcf########
my $snpeff = $info{snpeff};
my $snpsift = $info{snpsift};
my $snpeff_config = $info{snpeff_config};
my $java = $info{java_1_7};
my $snpeff_db = $info{snpeff_db};
my $tmp_path = "Djava.io.tmpdir=$vcf_stat_path/tmp/";
make_dir("$vcf_stat_path/tmp");

my $cosmic_db = $info{cosmic_db};
my $exac_db = $info{exac_db};
my $knih_db = $info{knih_db};
my $kpgp_db = $info{kpgp_db};

my $memory = "Xmx2g";
my $sh_path = "$project_path/result/sh_log_file/00_vcf_target_stat/";
my $snpeff_vcf = "$vcf_stat_path/$project_id.snpeff.vcf";
make_dir($sh_path);
my $sh_snpeff = "$sh_path/$project_id.snpeff.sh";


open my $fh_snpeff, '>', $sh_snpeff or die; 

print $fh_snpeff "#!/bin/bash \n";
print $fh_snpeff "date \n";
print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpeff \\\n";
print $fh_snpeff "\t-geneId \\\n";
print $fh_snpeff "\t-c $snpeff_config \\\n";
print $fh_snpeff "\t-v $snpeff_db \\\n";
print $fh_snpeff "\t-o vcf \\\n";
print $fh_snpeff "\t$merged_vcf_gz \| \\\n\n"; ##gzip

print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpsift \\\n";
print $fh_snpeff "\tvarType -v - \| \\\n\n";
#cosmic
print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpsift \\\n";
print $fh_snpeff "\tannotate -noID -info COSMID -v $cosmic_db - \| \\\n\n";
#dbsnp
print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpsift \\\n";
print $fh_snpeff "\tannotate -dbsnp -v - \| \\\n\n";
#clinvar
print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpsift \\\n";
print $fh_snpeff "\tannotate -clinvar -v - \| \\\n\n";
#dbNSFP
print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpsift \\\n";
print $fh_snpeff "\tdbNSFP -v - \| \\\n\n";
#ExAC
print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpsift \\\n";
print $fh_snpeff "\tannotate -v $exac_db \| \\\n\n";
#KOREADB
print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpsift \\\n";
print $fh_snpeff "\tannotate -v $knih_db \| \\\n\n ";
#KPGPDB
print $fh_snpeff "$java -$memory \\\n";
print $fh_snpeff "\t-$tmp_path \\\n";
print $fh_snpeff "\t-jar $snpsift \\\n";
print $fh_snpeff "\tannotate -v $kpgp_db ";

print $fh_snpeff "> $snpeff_vcf \n";
print $fh_snpeff "date";

close $fh_snpeff;

##run_sh###
if (!-f $snpeff_vcf){
    my $cmd_qsub = "qsub -V -e $sh_path -o $sh_path -S /bin/bash $sh_snpeff";
    #print $cmd_qsub."\n";
    system ($cmd_qsub);
}

my $snpeff_gz = "$vcf_stat_path/$project_id.snpeff.vcf.gz";
my $snpeff_gz_tbi = "$vcf_stat_path/$project_id.snpeff.vcf.gz.tbi";

if( !-f $snpeff_gz ) {
    my $cmd_bgzip = "/BiO/BioTools/tabix/tabix-v0.2.5/bgzip -c $vcf_stat_path/$project_id.snpeff.vcf > $snpeff_gz";
    system($cmd_bgzip);
}
if ( !-f $snpeff_gz_tbi ) {
    my $cmd_tabix = "/BiO/BioTools/tabix/tabix-v0.2.5/tabix -p vcf $snpeff_gz";
    system($cmd_tabix);
}

foreach (@candidate_list){
    my ($my_gene, $my_region) = split /\|/, $_;
    # my $my_region = $_;
    my $gene_dir = "$vcf_stat_path/gene_list";
    make_dir($gene_dir);
    my $gene_output = "$gene_dir/$my_gene.txt";
    if (!-f $gene_output){
        # my $cmd_bcftools = "$bcftools query -H -r \'$my_region\' -f \'%CHROM\\t%POS\\t%REF\\t%ALT\\t[\\t%AD]\\n\' $vcf_stat_path/merged.vcf.gz > $gene_dir/$my_gene.txt" ;
        my $cmd_bcftools = "$bcftools query -r \'$my_region\' -f \'$my_gene\\t%CHROM\\t%POS\\t%REF\\t%ALT\\t%ANN\\t%ID\\t%COSMID\\t%dbNSFP_1000Gp1_AF\\t%dbNSFP_ESP6500_AA_AF\\t%CLNDBN\\t%CLNORIGIN\\t%CLNSIG\\t%INHOUSE_AF[\\t%AD]\\n\' $vcf_stat_path/$project_id.snpeff.vcf.gz > $gene_dir/$my_gene.txt" ;
        print $cmd_bcftools."\n";
        system($cmd_bcftools);
    }
}

##Merged Gene Files ###

my $total_output_file = "$vcf_stat_path/Total_Candidate_Summary_Output.txt";
open my $fh_total, '>', $total_output_file or die;
print $fh_total "\#Gene\tCHROM\tPOS\tREF\tALT\tANN\tdbSNP141\tCOSMID\t1000Gp1_AF\tESP6500_AA_AF\tCLNDBN\tCLNORIGIN\tCLNSIG\tKORDB";
foreach (@delivery_tbi_id) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/,$_;
    print $fh_total "\t$delivery_id:AD";
}
print $fh_total "\n";
close $fh_total;

foreach (@candidate_list){
    my($my_gene, $my_region) = split /\|/, $_;
    my $gene_dir = "$vcf_stat_path/gene_list";
    my $gene_output = "$gene_dir/$my_gene.txt";
    my $cmd_merged = "cat $gene_output >> $total_output_file";
    system($cmd_merged);
}

###change to charactor####
######12######
#1-germline; 2-somatic; 4-inherited; 8-patenal; 16-maternal; 32-de-novo; 64-biparental; 128-uniparental; 256-not-tested; 
#512-tested-inconclusive; 1073741824-other
open my $fh_output_file, '<:encoding(UTF-8)', $total_output_file or die;
my $transfer_output_file = "$vcf_stat_path/Total_Candidate_Summary_Modified_Output.txt";
print $total_output_file."\n";

my $clnorigin_ref = {
    '0' => 'unknown',
    '1' => 'germline','2'=> 'somatic','3' => 'germline and somatic',
    '4' => 'inherited','8' => 'patenal','16' => 'maternal',
    '32' => 'de-novo','64' => 'biparental','128' => 'uniparental',
    '256' => 'not-tested','512' => 'tested-inconclusive','1073741824' => 'other'
};

my $clnsig_ref = {
    '0' => 'Uncertain significance', 
    '1' => 'Not provided',
    '2' => 'Benign','3' => 'Likely benign',
    '4' => 'Likely pathogenic','5' => 'Pathogenic',
    '6' => 'Drug response','7' => 'Histocompatibility',
    '255' => 'Other'
};
#####
open my $fh_transfer, '>', $transfer_output_file or die;
print $fh_transfer "\#Gene\tCHROM\tPOS\tREF\tALT\tANN\tdbSNP141\tCOSMID\t1000Gp1_AF\tESP6500_AA_AF\tCLNDBN\tCLNORIGIN\tCLNSIG\tKORDB";
foreach (@delivery_tbi_id) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/,$_;
    print $fh_transfer "\t$delivery_id:AD";
}
print $fh_transfer "\n";

#######
while ( my $row = <$fh_output_file>) {
    chomp $row;
    if ($row =~/^#/){ next; }
    my @row_list = split/\t/, $row;
    
    my $clnorigin = $row_list[11];
    my $clnsig = $row_list[12];

    if ($clnorigin eq "."){
    }else{
        if ($clnorigin =~ /\,/){
            my @origin_arr = split /\,/, $clnorigin;
            foreach (@origin_arr){
                $_ = $clnorigin_ref->{$_};
            }
            $clnorigin = join ",", @origin_arr;
        }else{
            $clnorigin = $clnorigin_ref->{$clnorigin};
        }
    }
    # print $clnorigin."\n";
    
 ########13######## 
 ####clnsig column##
 ###0-Uncertain significance, 1-not provided, 2-Benign, 3-Likely benign, 4-Likely pathogenic, 5-pathogenic, 6-Drug response, 7-histocompatibility, 255-other

    $clnsig =~ s/255/Other/g;
    $clnsig =~ s/7/Histocompatibility/g;
    $clnsig =~ s/6/Drug response/g;
    $clnsig =~ s/5/Pathogenic/g;
    $clnsig =~ s/4/Likely pathogenic/g;
    $clnsig =~ s/3/Likely benign/g;
    $clnsig =~ s/2/Benign/g;
    $clnsig =~ s/1/Not provided/g;
    $clnsig =~ s/0/Uncertain significance/g;

    ###########################
#print $fh_transfer "$row_list[0]\t$row_list[1]\t$row_list[2]\t$row_list[3]\t$row_list[4]\t$row_list[5]\t$row_list[6]\t$row_list[7]\t$row_list[8]\t$row_list[9]\t$row_list[10]\t$clnorigin\t$clnsig\n";
    for (my $i=0; $i < 11; $i++){
        print $fh_transfer "$row_list[$i]\t";
    }print $fh_transfer "$clnorigin\t$clnsig";
    for (my $j=13; $j < @row_list; $j++){
        print $fh_transfer "\t$row_list[$j]";
    }print $fh_transfer "\n";

    
    
#    print $fh_transfer "$row_list[0]\t$row_list[1]\t$row_list[2]\t$row_list[3]\t$row_list[4]\t$row_list[5]\t$row_list[6]\t$row_list[7]\t$row_list[8]\t$row_list[9]\t$row_list[10]\t$clnorigin\t$clnsig\n";
    ###########################
=pod
 if ($clnsig eq "."){
    }else{
        if ($clnsig =~ /\,/){
            my @clnsig_arr = split /\,/, $clnsig;
            for (@clnsig_arr){
                my $check_point = $_;
                if ($check_point =~ /\|/){
                    my @pipe_arr = split /\|/, $check_point;

=cut
=pod
 if ($clnsig ne "."){
        my $input = $clnsig;

        my u$result;
        if ($input =~ /\,/){
            $result = func_split($input);
            print "$input\t$result\n";
        }else{
            $result = $input;
        }
    }
=cut
}
close $fh_transfer;

sub func_split{
    my $in = shift;
    # write spli function
    my @array = split /\,/, $in;
    foreach (@array){
        if (defined $clnsig_ref->{$_}){
            $_ = $clnsig_ref->{$_};
        }else{
            die "ERROR ! $in\n";
        }
    }
    my $result = join ",", @array;
    return $result;
}


#/BiO/BioTools/tabix/tabix-v0.2.5/bgzip -c TBD150418.snpeff.vcf > TBD150418.snpeff.vcf.g
#/BiO/BioTools/tabix/tabix-v0.2.5/tabix -p vcf TBD150418.snpeff.vcf.gz

#######mtach-up to Data Base#####################
#1. COSMIC
=pod
foreach (@candidate_list) {
    my ($my_gene, $my_region) = split /\|/, $_;
    my $candidate_gene_file = "$vcf_stat_path/$my_gene.txt";
    
    print $candidate_gene_file."\n";
    open my $fh_file,'<:encoding(UTF-8)',$candidate_gene_file or die;
    while (my $row = <$fh_file>) {
        chomp $row;
        my @contents;
        push @contents, split /\t/, $row;
        my $my_chr = $contents[0]; 
        my $my_pos = $contents[1];

        print $contents[0]."\n";
    }
}
=cut

sub make_dir {
    my $file = shift;
    if ( !-d $file) {
        my $cmd_mkdir = "mkdir -p $file";
        system ($cmd_mkdir);
    }
}

sub read_config {
    my ($config, $ref_hash)=@_;
    open my $fh, '<:encoding(UTF-8)',$config or die;
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/){next;}
        if (length($row) == 0){next;}
        my ($key,$value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $ref_hash->{$key}=$value;
    }close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result){
        s/^\s+//;
        s/\s+$//;
    } return wantarray ? @result:$result[0];
}

sub printUsage {
    print "perl $0 <in_config> \n";
    exit;
}
=pod
[Workflow command]
perl /BiO/BioPeople/brandon/hmkim/BioScript/vcf/vcf_merge.pl -V /BiO/BioTools/vcftools/0.1.12b -T /BiO/BioTools/tabix/tabix-v0.2.5 "PATH/*.vcf" out.vcf.gz
/BiO/BioTools/tabix/tabix-v0.2.5/tabix out.vcf.gz
/BiO/BioTools/bcftools/bcftools-1.2/bcftools query -r 'chrY:13506968' -f '%CHROM\t%POS\t%REF\t%ALT[\t%SAMPLE=%GT]\n' out.vcf.gz

[Query example]
$/BiO/BioTools/bcftools/bcftools-1.2/bcftools query -r 'chrY:13506950-13506975' -f '%CHROM\t%POS\t%REF\t%ALT[\t%SAMPLE=%GT]\n' ~/z.vcf.gz

[Extract sample list]
/BiO/BioTools/bcftools/bcftools-1.2/bcftools query -l ~/z.vcf.gz
=cut
