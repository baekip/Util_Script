#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 1) {
    printUasge();
}

sub printUsage{
    print "Usage: perl $0 <in.config> \n";
    print "example: perl
