package Queue;
use strict;
use FindBin;
use Cwd 'abs_path';
use Carp qw(croak);
use File::Basename;

sub run_qsub{
    my ($command, $jobname, $log_path) = @_;

    if (!$log_path){
        $log_path = $ENV{"HOME"}."/".$jobname;
        if (!-d $log_path){
            system ("mkdir -p $log_path");
        }
    }
    my 
