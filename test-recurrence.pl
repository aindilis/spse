#!/usr/bin/perl -w

use Recurrence;

use Tk;

my $mw = MainWindow->new();

my $recurrence = Recurrence->new
  (
   MainWindow => $mw,
   StartsOn => "12/15/2010",
   EndsOn => "12/15/2011",
  );

MainLoop();
