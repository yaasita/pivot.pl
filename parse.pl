#!/usr/bin/perl
use strict;
use warnings;
use Encode;
use feature qw(say);
use utf8;

system("curl -s http://www.tfx.co.jp/kawase/document/PRT-010-CSV-003-\$(date +%Y%m%d -d '2 days ago').CSV > input.csv") and die $!;

binmode STDOUT, ":utf8";
open(my $fh, "<:encoding(Shift-JIS)","input.csv") or die $!;
while(<$fh>){
    if (/米ドル・日本円取引所為替証拠金取引/){
        my @fx = split(/,/);
        say "高値 => $fx[8]";
        say "安値 => $fx[10]";
        say "終値 => $fx[12]";
    }
}
close $fh;

