#!/usr/bin/perl -w

use Tk;
use Tk::MiniCalendar;

my $mainwindow = MainWindow->new(-title => "Test");

my $minical = $mainwindow->MiniCalendar
  (
   -day   => 5,
   -month => 12,
   -year  => 2010,
   -day_names   => ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],
   -month_names => ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
  )->pack();

MainLoop();
