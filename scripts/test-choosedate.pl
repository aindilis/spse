#!/usr/bin/perl -w

use Tk;
use Tk::ChooseDate;

my $mw=tkinit;
$mw->ChooseDate(
		-textvariable=>\$date,
		-command=>sub{print "$date\n"},
	       )->pack(-fill=>'x', -expand=>1);
MainLoop;
