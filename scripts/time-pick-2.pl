#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use Tk;
use Diamond::Lib::Tk::TimePick2;

my $mw = MainWindow->new();
my $tp = Diamond::Lib::Tk::TimePick2->new($mw)->pack();
my $b = $mw->Button(
		    -text           => "Time",
		    -command        => sub
		    {
		      my $time_as_string = $tp->GetTimeString();
		      # my $time_as_string = $tp->GetTime();
		      #***
		      # Here we do something with the time as string
		      #***
		      print Dumper($time_as_string);
		    }
		   )->pack();

MainLoop();
