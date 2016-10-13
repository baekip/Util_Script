#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage; 

my ($config, $pipeline);
GetOptions( 
    'config=c'=> \$config,
    'pipeline=p' => \$pipeline) or die ("Error in command line arguments\n");

print $config."\n";
print $pipeline."\n";

=pod
my %info;

read_general_config( $in_general_config, \%info );
#read_pipeline_config();

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};
my $project_path = $info{project_path};
my $read_length = $info{read_length};

my $alignment_statistics_xls = "$project_path/report/alignment.statistics.xls";
checkFile ( $alignment_statistics_xls );

#my $target_bed = $info{target_bed};
#my $bed_size = `awk '{ sum+=\$3-\$2+1 } END { print sum }' $target_bed`;
#chomp($bed_size);

my %hash_sample;
print "[[12],[],[],[110]]\n";

print "Sample ID\tSequence read\tRaw sequence depth\t".
	"On target\\nread\\n(%)\t".
	"On target\\ndepth\\n(mean)\t".
	"On target\\ndepth\\n(std)\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;
=pod
	my $sequence_read = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 2 | head -n 1`;
	chomp($sequence_read);
#        $sequence_read = num($sequence_read);

	my $sequence_base = $sequence_read * 101;
	chomp($sequence_base);

        $sequence_read = num($sequence_read);
        
        my $bed_size = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 15 | head -n 1`;

	my $raw_sequence_depth = $sequence_base/$bed_size;
	$raw_sequence_depth = &RoundXL ($raw_sequence_depth, 2);

	my $on_target_read_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 12 | head -n 1`;
	chomp($on_target_read_rate);

	my $on_target_depth_mean = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 13 | head -n 1`;
	chomp($on_target_depth_mean);

	my $on_target_depth_std = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 14 | head -n 1`;
	chomp($on_target_depth_std);
        $on_target_depth_std = &RoundXL ($on_target_depth_std, 2);

=cut
=pod
        my $sequence_read = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 2 | head -n 1`;
	chomp($sequence_read);

	my $sequence_base = $sequence_read * $read_length;
	chomp($sequence_base);
        
        $sequence_read = num($sequence_read);
        
        my $bed_size = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 20 | head -n 1`;

	my $raw_sequence_depth = $sequence_base/$bed_size;
	$raw_sequence_depth = &RoundXL ($raw_sequence_depth, 2);

	my $on_target_read_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 17 | head -n 1`;
	chomp($on_target_read_rate);

	my $on_target_depth_mean = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 18 | head -n 1`;
	chomp($on_target_depth_mean);

	my $on_target_depth_std = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 19 | head -n 1`;
	chomp($on_target_depth_std);
        $on_target_depth_std = &RoundXL ($on_target_depth_std, 2);

	print "$delivery_id\t$sequence_read\t$raw_sequence_depth\t$on_target_read_rate\t$on_target_depth_mean\t$on_target_depth_std\n";
}

=cut
sub RoundXL {
	sprintf("%.$_[1]f", $_[0]);
}

sub RoundToInt {
	int($_[0] + .5 * ($_[0] <=> 0));
}

sub read_pipeline_config{
	my $file = shift;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/ or $row =~ /^\s/){ next; }
	}
	close($fh);	
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

sub checkFile{
	my $file = shift;
	if (!-f $file){
		die "ERROR ! not found <$file>\n";
	}
}

sub num{
        my $cnum = shift;
        if ($cnum =~ /\d\./){
                return $cnum;
        }
        while( $cnum =~ s/(\d+)(\d{3})\b/$1,$2/ ) {
                1;
        }
        my $result = sprintf "%s", $cnum;
        return $result;
}


sub printUsage{
	print "Usage: perl $0 <in.config> <in.pipeline.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_pipeline_config.human.txt\n";
	exit;
}
