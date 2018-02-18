#!/usr/bin/perl -w

use Tk;

use SPSE2::GUI::Tab::AllTasks3::EditTask;

my $mw = MainWindow->new();
$mw->withdraw;

my $edittask = SPSE2::GUI::Tab::AllTasks3::EditTask->new
  (MainWindow => $mw);

$edittask->Execute();
MainLoop();
