use warnings;
use strict;

use Getopt::Long;

use File::Basename; 

my $cutadapt;
GetOptions(
        'cutadapt=s' => \$cutadapt,
);

if (!$cutadapt){
    $cutadapt = "/BiO/BioTools/miniconda3/bin/cutadapt";
}
checkFile($cutadapt);

if (@ARGV != 3){
    printUsage();
}
my $in_fastq = $ARGV[0];
my ($filename, $filepath, $fileext) = fileparse($in_fastq, qr/\.[^.]*/);
my $out_fastq = $ARGV[1];
my $wantLength = $ARGV[2];

my $cmd_oneSeq;
if ($fileext eq ".gz"){
    $cmd_oneSeq = "zcat $in_fastq | head -n 2 | tail -n 1";
}else{
    $cmd_oneSeq = "cat $in_fastq | head -n 2 | tail -n 1";
}

my $oneSeq = `$cmd_oneSeq`;
chomp($oneSeq);
my $length_oneSeq = length($oneSeq);

my $trimmedLength = $length_oneSeq - $wantLength;

if (!$trimmedLength or $trimmedLength <= 0){
    die "ERROR ! check your sequence length\n";
}

$trimmedLength = "-".$trimmedLength; # To remove the last {n} bases of each read:


my $cmd_cutadapt = cutadapt( $in_fastq, $out_fastq, $trimmedLength );
print $cmd_cutadapt."\n";
system($cmd_cutadapt);

#cutadapt -u 5 -o trimmed.fastq reads.fastq (first 5 base)
#cutadapt -u -7 -o trimmed.fastq reads.fastq (last seven base)


sub cutadapt{
    my ($in, $out, $length) = @_;
    my $command = "$cutadapt -u $length -o $out $in";
    return $command;
}

sub checkFile{
    my $file = shift;
    if (!-f $file){
        die "ERROR! not found <$file>\n";
    }

}

sub printUsage{
    print "Usage : perl $0 [-c $cutadapt] <in.fastq> <out.fastq> <remainedLength>\n";
    print "reaminedLength: sequence length after trimmed\n";
    exit;
}
