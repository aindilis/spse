#!/usr/bin/perl -w

use Tk;

use SPSE2::GUI::Util::TextWindow;

my $mw = MainWindow->new;

my $contents = "";
foreach my $i (1..100) {
  $contents .= "$i\n";
}

my $textwindow = SPSE2::GUI::Util::TextWindow->new
  (
   MainWindow => $mw,
   Title => "Scrollbar Test",
   Contents => $contents,
  );

MainLoop;
