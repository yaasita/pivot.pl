#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use Encode;
use utf8;
use File::Temp qw/tempdir/;
use Time::Piece;
use Time::Seconds;

binmode STDOUT, ":utf8";

my $p;
my $previous_day = &latest_data;

# 前日分の高値,安値,終値を取得
{
    my $tempdir = tempdir(CLEANUP => 1);
    local $ENV{LANG} = "C";
    chdir $tempdir;
    system("curl -fs http://www.tfx.co.jp/kawase/document/PRT-010-CSV-003-$previous_day.CSV > input.csv") and die $!;
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

my ($line, $val);
format STDOUT_TOP =
@<<<年@<月@<日(@)データ
substr($previous_day,0,4),substr($previous_day,4,2),substr($previous_day,6,2),&wday($previous_day)

.
format STDOUT =
@<: @<<<<<<<
$line,$val
.

for (qw(H R2 R1 P S1 S2 L)){
    $line = $_;
    $val = $p->{$_};
    write;
}

sub wday {
    my $yyyymmdd = shift;
    my @wdays = ("日","月","火","水","木","金","土");
    my $t = Time::Piece->strptime($yyyymmdd,"%Y%m%d");
    return $wdays[$t->_wday];
}
sub latest_data {
    open (my $web,'-|:encoding(Shift-JIS)',"curl -fs http://www.tfx.co.jp/cgi-bin/statistics_forex_j.cgi") or die $!;
    while (<$web>){
        if ($_ =~ m#/kawase/document/PRT-\d{3}-CSV-\d{3}-(\d{8}).CSV>.*CSV形式#){
            return $1;
        }
    }
}

package Pivot;
sub new {
    my $class = shift;
    my $self = {
        @_,
    };
    $self->{P}  = ($self->{'High'} + $self->{'Low'}   + $self->{'Close'})/3;

    $self->{S1} = $self->{'P'}     - ($self->{'High'} - $self->{'P'});
    $self->{R1} = $self->{'P'}     + ($self->{'P'}    - $self->{'Low'});

    $self->{S2} = $self->{'P'}     - ($self->{'High'} - $self->{'Low'});
    $self->{R2} = $self->{'P'}     + ($self->{'High'} - $self->{'Low'});

    $self->{L}  = $self->{'S1'}    - ($self->{'High'} - $self->{'Low'});
    $self->{H}  = $self->{'R1'}    + ($self->{'High'} - $self->{'Low'});

    my $keta = sub {
        my $source_ref = shift;
        $$source_ref = sprintf("%.3f",$$source_ref);
    };
    for (qw(P S1 R1 S2 R2 L H)){
        $keta->(\$self->{$_});
    }
    return bless $self, $class;
}
