#!/usr/bin/perl -w

use Tk;
use strict;

my $mw = MainWindow->new;
$mw->title("Scrollbar Test");
my $topframe = $mw->Frame()->pack(-side => 'top');
my $bottomframe = $mw->Frame()->pack(-side => 'bottom');
my $scroll_text = $topframe->Scrollbar();

my $main_text = $topframe->Text(-yscrollcommand => ['set', $scroll_text]);

$scroll_text->configure(-command => ['yview', $main_text]);

$scroll_text->pack(-side=>"right", -expand => "no", -fill => "y");
$main_text->pack(-side => "left", -anchor => "w",
                 -expand => "yes", -fill => "both");

my $contents = "";
foreach my $i (1..100) {
  $contents .= "$i\n";
}
$main_text->Contents($contents);

$bottomframe->Button
  (
   -text => "Ok",
   -command => sub { },
  )->pack(-side => 'bottom');

MainLoop;
