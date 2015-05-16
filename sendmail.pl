#!/usr/bin/perl
use strict;
use warnings;
use Time::Piece;
use Time::Seconds;
use utf8;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);


my $TO_ADDRESS = $ARGV[0] || 'root@localhost';

{
    open (my $sml, "|-:encoding(UTF-8)", "/usr/sbin/sendmail -f $TO_ADDRESS $TO_ADDRESS") or die $!;
    print $sml mail_heder($TO_ADDRESS);
    my $source_data = `./pivot.pl`;
    print $sml encode_base64($source_data);
    close $sml;
}

sub mail_heder {
    my $mail_from = shift;
    my $hiduke;
    {
        my $t = localtime();
        $hiduke = $t->strftime("%Y-%m-%d");
    }
    my $date;
    {
        $ENV{'TZ'} = "JST-9";
        my ($sec,$min,$hour,$mday,$mon,$year,$wday) = localtime(time);
        my @week = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
        my @month = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
        $date = sprintf("%s, %d %s %04d %02d:%02d:%02d +0900 (JST)", $week[$wday],$mday,$month[$mon],$year+1900,$hour,$min,$sec);
    } 
    my $subject = `echo "今日のピボット $hiduke" | nkf -W -M -w`;
    chomp $subject;
    my $message_id = md5_hex($subject) . "."  . time() . "." . $mail_from;
    my $head = <<"HEADER";
From: $mail_from
To: $mail_from
Content-Type: text/plain; charset=UTF-8
Message-Id: <$message_id>
Date: $date
Subject: $subject
Content-Transfer-Encoding: Base64

HEADER
    return $head;
}

