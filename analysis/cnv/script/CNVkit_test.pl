#!/bin/usr/perl

use strict;
use warnings;

use File::Basename qw(dirname fileparse);
use Cwd qw(abs_path);
use lib dirname (abs_path $0) . '/../library';
use CNV qw(cnv_target);
use Utirs qw(read_config);

my $id = "test";
cnv_target ($id, 