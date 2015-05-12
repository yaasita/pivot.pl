#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw/tempdir/;
use feature qw(say);
use Cwd;

# 前日分の高値,安値,終値を取得
{
    my $tempdir = tempdir(CLEANUP => 1);
    local $ENV{LANG} = "C";
    chdir $tempdir;
}
chdir "/tmp";
