#!/usr/bin/perl -w

use Tk;
use Tk::Animation;
use Tk::Canvas;

my $animation_toplevel = MainWindow->new
     (
      -title => "Test Animation",
      -width => 1024,
      -height => 768,
     );

my $canvas = $animation_toplevel->Canvas;

my $file1 = "/var/lib/myfrdcsa/codebases/minor/spse/flammes-10.gif";
my $file2 = "/var/lib/myfrdcsa/codebases/minor/spse/image.gif";
my $img1 = $canvas->Photo
  (
   -file => $file1,
  );
my $img2 = $canvas->Animation
  (
   -format => "gif",
   -file => $file1,
  );
$canvas->createImage( 50,50, -image=> $img2);
$canvas->pack();
$img2->start_animation(200);
MainLoop();
