#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);

my $p = Pivot->new(High => 120.255, Low => 119.555, Close => 119.7);
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
