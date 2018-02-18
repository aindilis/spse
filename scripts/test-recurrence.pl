#!/usr/bin/perl -w

use SPSE2::GUI::Tab::View2::EditNode::DateTime::Recurrence;

use Tk;

my $mw = MainWindow->new();

my $recurrence = SPSE2::GUI::Tab::View2::EditNode::DateTime::Recurrence->new
  (
   MainWindow => $mw,
   StartsOn => "2010/12/15",
   EndsOn => "2011/12/15",
   Time => "10:15:00",
  );

MainLoop();
