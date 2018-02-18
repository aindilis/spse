#!/usr/bin/perl


use warnings;
use strict;

use Tk;
use Tk::Month;

my $mw = MainWindow->new();

my $month = "November";
my $year = "2006";
my $m = $mw->Month(
    -printformat   => '%a %e',
    -includeall    => 0,
    -month         => $month,
    -year          => $year,
    -command       => sub {
        my ($ym, $wd) = @_;
        my ($month, $year) = split( /\s+/ , $ym );
        my ($wday, $date)  = split( /\s+/ , $wd->[0] );
        print "$wday, $month $date $year\n";
    },
);
$m->pack;

MainLoop;
