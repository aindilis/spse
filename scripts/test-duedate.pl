#!/usr/bin/perl -w

use Verber::Util::DateManip;

use Data::Dumper;
use Date::ICal;
use Date::Parse;
use DateTime;
use DateTime::Duration;
use DateTime::Format::ICal;
use DateTime::Format::Strptime;

use Tk;

my $mw = MainWindow->new
  (
   Title => "DueDate Test",
   Width => 800,
   Height => 600,
  );

my $datemanip = Verber::Util::DateManip->new();
my $statedate = $self->MyDateManip->GetPresent();
my $units = DateTime::Duration->new
  (
   hours => 1,
  );

my $dateinformation = "";
$datemanip->FormatDatetime
  (
   Datetime => $dateinformation,
  );


MainLoop();
