#!/usr/bin/perl
use strict;
use warnings;

use feature qw(say);
use Encode;
use utf8;
use File::Temp qw/tempdir/;
binmode STDOUT, ":utf8";

my $p;

# 前日分の高値,安値,終値を取得
{
    my $tempdir = tempdir(CLEANUP => 1);
    local $ENV{LANG} = "C";
    chdir $tempdir;
    system("curl -s http://www.tfx.co.jp/kawase/document/PRT-010-CSV-003-\$(date +%Y%m%d -d '2 days ago').CSV > input.csv") and die $!;
    open(my $fh, "<:encoding(Shift-JIS)","input.csv") or die $!;
    while(<$fh>){
        if (/米ドル・日本円取引所為替証拠金取引/){
            my @fx = split(/,/);
            $p = Pivot->new(High => $fx[8], Low => $fx[10], Close => $fx[12]);
        }
    }
    close $fh;
}
chdir "/tmp";

my ($title, $val);
format STDOUT =
@<: @<<<<<<<
$title,$val
.

for (qw(H R2 R1 P S1 S2 L)){
    $title = $_;
    $val = $p->{$_};
    write;
}

package Pivot;
sub new {
    my $class = shift;
    my $self = {
        @_,
    };
    $self->{P}  = ($self->{'High'} + $self->{'Low'} + $self->{'Close'})/3;

    $self->{S1} = $self->{'P'}  - ($self->{'High'} - $self->{'P'});
    $self->{R1} = $self->{'P'}  + ($self->{'P'}    - $self->{'Low'});

    $self->{S2} = $self->{'P'}  - ($self->{'High'} - $self->{'Low'});
    $self->{R2} = $self->{'P'}  + ($self->{'High'} - $self->{'Low'});

    $self->{L}  = $self->{'S1'} - ($self->{'High'} - $self->{'Low'});
    $self->{H}  = $self->{'R1'} + ($self->{'High'} - $self->{'Low'});

    my $keta = sub {
        my $source_ref = shift;
        $$source_ref = sprintf("%.3f",$$source_ref);
    };
    for (qw(P S1 R1 S2 R2 L H)){
        $keta->(\$self->{$_});
    }
    return bless $self, $class;
}
