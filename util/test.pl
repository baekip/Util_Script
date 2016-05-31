package BioTools;


#fuction 
#IN
#   input (file or directory)
#       custom
#   output (file or directory)
#       custom
#   tool
#       -param (one_line or key:value pair)
#           default or custom
#       -tool_exec_name (like.. bowtie, bwa)
#           default
#       -tool_path  (export PATH)
#           default or custom
#
#OUT
#   command
#


use File::Basename;
use Data::Dumper;

my %actions = (
    bowtie => \&bowtie,
    Sortsam => \&picard_SortSam,
    htseq_count => \&htseq_count,
    baz => sub { print 'baz!' }
);

sub new {
    my ($class, $config) = @_;
    my $self = $config;

    my $appName = $self->{tool}->{exec_name}
    if ($actions{$appName}){
        return $

