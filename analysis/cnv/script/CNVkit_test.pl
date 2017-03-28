#!/bin/usr/perl

=head1 Name

    CNVkit_test.pl -- test perl script

=head1 Descript

    This program throw the jobs nad control them running on linux SGE system.

=head1 Version

    Author: baekip, inpyo.baek@theragenetex.com
    Version: 0.1, Date: 2017-02-09

=head1 Usage

    perl CNVkit_test.pl <blank>

=cut


use strict;
use warnings;

use File::Basename qw(dirname fileparse);
use Cwd qw(abs_path);
use lib dirname (abs_path $0) . '/../library';
use CNV qw(cnv_target);
use Utils qw(read_config);
use Data::Dumper;
use File::Spec;
use Getopt::Long;

#die `pod2text $0` if(;

my @test_array;
push @test_array ,"asd","sad","\tsad\n";

#test_check(@test_array, "mm");

foreach (@test_array){
    print $_."\\\n";
}

sub test_check {
    my @array = shift;
    my $type  = shift;
    my @result = push @array, $type;
    return @result;
}
#sub printerr {
#    print STDERR @_;
#    print LOG @_;
#}
#my %data = ('a', 45, 'b', 30, 'c', 20);
#print "\$data{'a'}=$data{'a'}\n";
=cut
sub run_qsub {
    my ($coomand, $jobname, $log_path) =@_;
    if (!$log_path) {
        $log_path = $ENV{"HOME"}."/".$jobname;
        if (!-d $log_path){
            system ("mkdir -p $log_path");
        }
    }
    my $script_fn = $log_path."/".$jobname.".sh";
    my $stdout = $log_path."/".$jobname.".log";
    my $queue = "all.q";
    my $job = {
        job => $jobnamd,
        command => $command,
        script_fn => $script_fn,
        stdout => $stdout,
        wc_queue_list => $queue
    };
    $job = write_qsub_script($job);

sub write_qsub_script {
    my $self = shift;

    my @arr;
    push @arr, "#!/bin/bash";
    if ($self->{path_list}){
        push @arr, "#\$ -S $self->{path_list}";
    }else{
        push @arr, "#\$ -q all.q";
    }
}


my %data =(
    'a' => 45,
    'b' => 30, 
    'c' => 20
);

my @name = keys %data;
foreach (@name){
    print $_."\n";
}
my @value = values %data;
foreach (@value){
    print $_."\n";
}

if (exists($data{'d'})){
    print "'a' is $data{'a'} \n";
}else{
    print "no\n";
}
print Dumper (\%data);
