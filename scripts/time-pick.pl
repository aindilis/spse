#!/usr/bin/perl -w

use Tk;
use Tk::TimePick;
my $mw = MainWindow->new();
my $tp = $mw->TimePick()->pack();
my $b = $mw->Button(
		    -text           => "Time",
		    -command        => sub
		    {
		      my $time_as_string = $tp->GetTimeString();
		      # my $time_as_string = $tp->GetTime();
		      #***
		      # Here we do something with the time as string
		      #***
		    }
		   )->pack();
MainLoop();
