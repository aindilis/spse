package SPSE2::GUI::Tab::View2::EditNode::DateTime;

use Manager::Dialog qw(Message);
use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View2::EditNode::DateTime::Recurrence;
use Verber::Util::DateManip;

use DateTime;
use DateTime::Format::ICal;
use Tk;
use Tk::Month;
# use Tk::TimePick;
use Diamond::Lib::Tk::TimePick2;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow Top1 MyView StartDate EndDate Duration Selector
   MyDateManip EntryID Rel TimeZone HardTimeConstraints Habitual SoonerThanLater /

  ];

sub init {
  my ($self,%args) = @_;
  # 31531
  $self->EntryID($args{EntryID});
  $self->Rel(["entry-fn","pse",$self->EntryID]);
  $self->MyMainWindow($args{MainWindow});
  $self->MyView($args{MyView});
  $self->Top1
    ($self->MyMainWindow->Toplevel
     (
      -title => "Temporal Properties",
     ));
  $self->MyDateManip(Verber::Util::DateManip->new());
  $self->TimeZone("America/Chicago");
  my ($startdate,$startdatedate,$startdatetime,$enddate,$enddatedate,$enddatetime,$duration);
  # go ahead and load the information

  my $resstart = $self->MyView->MyMetadata->GetMetadata
    (
     Item => $self->Rel,
     Predicate => "start-date",
    );
  if ($resstart->{Success}) {
    $startdate = $resstart->{Result};
  }
  my $resend = $self->MyView->MyMetadata->GetMetadata
    (
     Item => $self->Rel,
     Predicate => "end-date",
    );
  if ($resend->{Success}) {
    $enddate = $resend->{Result};
  }
  my $resduration = $self->MyView->MyMetadata->GetMetadata
    (
     Item => $self->Rel,
     Predicate => "event-duration",
    );
  if ($resduration->{Success}) {
    $duration = $resduration->{Result};
  }
  # print SeeDumper($resstart,$resend,$resduration);
  $self->StartDate(\$startdate);
  $self->EndDate(\$enddate);
  $self->Duration(\$duration);
  my $selector = "End Date";
  $self->Selector(\$selector);

  my ($hardtimeconstraints,$habitual,$soonerthanlater);
  my $hardtimeconstraintsres = $self->MyView->MyMetadata->GetMetadata
    (
     Item => $self->Rel,
     Predicate => "hard-time-constraints",
    );
  if ($hardtimeconstraintsres->{Success}) {
    $hardtimeconstraints = $hardtimeconstraintsres->{Result};
  }
  my $habitualres = $self->MyView->MyMetadata->GetMetadata
    (
     Item => $self->Rel,
     Predicate => "habitual",
    );
  if ($habitualres->{Success}) {
    $habitual = $habitualres->{Result};
  }
  my $soonerthanlaterres = $self->MyView->MyMetadata->GetMetadata
    (
     Item => $self->Rel,
     Predicate => "sooner-rather-than-later",
    );
  if ($soonerthanlaterres->{Success}) {
    $soonerthanlater = $soonerthanlaterres->{Result};
  }
  $self->HardTimeConstraints(\$hardtimeconstraints);
  $self->Habitual(\$habitual);
  $self->SoonerThanLater(\$soonerthanlater);

  my $topframe = $self->Top1->Frame();
  my $calendarframe = $topframe->Frame();

  my ($sdt, $edt);
  my $months =
    {
     "January" => 1,
     "February" => 2,
     "March" => 3,
     "April" => 4,
     "May" => 5,
     "June" => 6,
     "July" => 7,
     "August" => 8,
     "September" => 9,
     "October" => 10,
     "November" => 11,
     "December" => 12,
    };

  # get the current month and date
  my $cdt = $self->MyDateManip->GetCurrentDateTime;

  my $month = $cdt->month_name;
  my $year = $cdt->year;

  my $m = $calendarframe->Month
    (
     -printformat   => '%a %e',
     -includeall    => 0,
     -month         => $month,
     -year          => $year,
     -command       => sub {
       my ($ym, $wd) = @_;

       my ($month, $year) = split( /\s+/ , $ym );
       my ($wday, $date)  = split( /\s+/ , $wd->[0] );
       $self->UpdateDateTime
	 (
	  Date => {
		   Month => $months->{$month},
		   Day => $date,
		   Year => $year,
		  },
	 );
     },
    );
  $m->pack;
  $calendarframe->pack(-side => 'left');

  my $timeframe = $topframe->Frame();
  my $l1 = $timeframe->Label(-text => "Start Time");
  # my $tp1 = $timeframe->TimePick()->pack();
  my $tp1 = Diamond::Lib::Tk::TimePick2->new($timeframe)->pack();
  my $b1 = $timeframe->Button
    (
     -text           => "Time",
     -command        => sub
     {
       my $timestring = $tp1->GetTimeString();
       my ($h,$m,$s) = split /:/, $timestring;
       $self->UpdateDateTime
	 (
	  Time => {
		   Hour => $h,
		   Minute => $m,
		   Second => $s,
		  },
	 );
     }
    )->pack();

  $timeframe->pack();


  my $periodframe = $topframe->Frame();
  my $pb1 = $periodframe->Button
    (
     -text           => "All Day",
     -command        => sub { $self->SetTimePeriod(Period => "all day"); },
    )->pack();
  my $pb2 = $periodframe->Button
    (
     -text           => "Morning",
     -command        => sub { $self->SetTimePeriod(Period => "morning"); },
    )->pack();
  my $pb3 = $periodframe->Button
    (
     -text           => "Afternoon",
     -command        => sub { $self->SetTimePeriod(Period => "afternoon"); },
    )->pack();
  my $pb4 = $periodframe->Button
    (
     -text           => "Evening",
     -command        => sub { $self->SetTimePeriod(Period => "evening"); },
    )->pack();
  my $pb5 = $periodframe->Button
    (
     -text           => "Night",
     -command        => sub { $self->SetTimePeriod(Period => "night"); },
    )->pack();

  $periodframe->pack(-side => 'right');

  $topframe->pack(-side => 'top');

  my $bottomframe = $self->Top1->Frame();

  my $radiobuttonframe = $bottomframe->Frame();
  my $lbl_gender = $radiobuttonframe->Label( -text => "Choose Time")->pack();

  my $startdateframe = $bottomframe->Frame();
  my $startdatelabel = $startdateframe->Label
    (
     -text => "Start Date",
    )->pack(-side => 'left');

  my $startdateentry = $startdateframe->Entry
    (
     -width => 100,
     -textvariable => \$startdate,
    )->pack(-side => 'right');
  $startdateframe->pack();


  my $enddateframe = $bottomframe->Frame();
  my $enddatelabel = $enddateframe->Label
    (
     -text => "End Date",
    )->pack(-side => 'left');

  my $enddateentry = $enddateframe->Entry
    (
     -width => 100,
     -textvariable => \$enddate,
    )->pack(-side => 'right');
  $enddateframe->pack();

  my $durationframe = $bottomframe->Frame();
  my $durationlabel = $durationframe->Label
    (
     -text => "Duration",
    )->pack(-side => 'left');
  my $durationentry = $durationframe->Entry
    (
     -textvariable => \$duration,
    )->pack(-side => 'right');
  $durationframe->pack();

  my $moreoptionsframe = $bottomframe->Frame();
  my $hardtimeconstraintscheckbutton = $moreoptionsframe->Checkbutton
    (
     -text => "Hard Time Constraints",
     -variable => \$hardtimeconstraints,
     -command => sub {
     },
    )->pack(-side => "left");
  my $habitualcheckbutton = $moreoptionsframe->Checkbutton
    (
     -text => "Habitual",
     -variable => \$habitual,
     -command => sub {
     },
    )->pack(-side => "right");
  my $soonerthanlatercheckbutton = $moreoptionsframe->Checkbutton
    (
     -text => "Sooner than Later",
     -variable => \$soonerthanlater,
     -command => sub {
     },
    )->pack(-side => "right");

  my $recurrencebutton = $moreoptionsframe->Button
    (
     -text => "Edit Recurrence",
     -command => sub {
       my $recurrence = SPSE2::GUI::Tab::View2::EditNode::DateTime::Recurrence->new
	   (
	    View => $self->MyView,
	    MainWindow => $self->MyMainWindow,
	    StartsOn => "2010/12/15",
	    EndsOn => "2011/12/15",
	    Time => "10:15:00",
	   );
     },
    )->pack(-side => "right");
  $moreoptionsframe->pack();

#   my $frame = $options->Frame(-relief => 'raised', -borderwidth => 2);
#   my $checkbutton = $frame->Checkbutton
#     (
#      -text => $field,
#      -command => sub {
#        foreach my $item (@items) {
# 	 if ($item->{name}->cget('-state') eq 'disabled') {
# 	   $item->{name}->configure(-state => "normal");
# 	   $item->{nameLabel}->configure(-state => "normal");
# 	 } else {
# 	   $item->{name}->configure(-state => "disabled");
# 	   $item->{nameLabel}->configure(-state => "disabled");
# 	 }
#        }
#      },
#     );

  my $buttonframe = $bottomframe->Frame();
  my $assert = $buttonframe->Button
    (
     -text => "Assert",
     -command => sub {
       $self->ActionAssert();
     },
    )->pack(-side => 'left');
  my $reset = $buttonframe->Button
    (
     -text => "Reset",
     -command => sub {
       $self->ActionReset();
     },
    )->pack(-side => 'left');
  my $cancel = $buttonframe->Button
    (
     -text => "Cancel",
     -command => sub {
       $self->ActionCancel();
     },
    )->pack(-side => 'left');

  $buttonframe->pack();
  $bottomframe->pack(-side => 'bottom');
}

sub UpdateDateTime {
  my ($self,%args) = @_;
  # figure out what the selected date is, update that component
  my $selector = ${$self->Selector};
  if (defined $selector) {
    if ($selector eq "Start Date") {
      if ($args{Date}) {
	$startdatedate = $args{Date};
      }
      if ($args{Time}) {
	$startdatetime = $args{Time};
      }
      my %opts = (
		  year => $startdatedate->{Year},
		  month => $startdatedate->{Month},
		  day => $startdatedate->{Day},
		 );
      if (defined $startdatetime) {
	$opts{hour} = $startdatetime->{Hour};
	$opts{minute} = $startdatetime->{Minute};
	$opts{second} = $startdatetime->{Second};
      }
      $sdt = DateTime->new(
			   %opts,
			   time_zone => $self->TimeZone,
			  );
      ${$self->StartDate} = DateTime::Format::ICal->format_datetime($sdt);
    } elsif ($selector eq "End Date") {
      if ($args{Date}) {
	$enddatedate = $args{Date};
      }
      if ($args{Time}) {
	$enddatetime = $args{Time};
      }
      my %opts = (
		  year => $enddatedate->{Year},
		  month => $enddatedate->{Month},
		  day => $enddatedate->{Day},
		 );
      if (defined $enddatetime) {
	$opts{hour} = $enddatetime->{Hour};
	$opts{minute} = $enddatetime->{Minute};
	$opts{second} = $enddatetime->{Second};
      }
      $edt = DateTime->new(
			   %opts,
			   time_zone => $self->TimeZone,
			  );
      ${$self->EndDate} = DateTime::Format::ICal->format_datetime
	($edt);
    }
  }
  if (defined $sdt and defined $edt) {
    $dur = $edt - $sdt;
    print SeeDumper($dur);
    ${$self->Duration} = $self->MyDateManip->DateTimeDurationToTimeSpecs
      (
       DateTimeDuration => $dur,
      );
  }
}

sub ActionCancel {
  my ($self,%args) = @_;
  $self->Top1->destroy;
}

sub ActionReset {
  my ($self,%args) = @_;
  print "Not yet implemented\n";
}

sub ActionAssert {
  my ($self,%args) = @_;
  # convert to the proper format now
  my $proceed = 1;
  if ((defined ${$self->StartDate} and ${$self->StartDate} =~ /./) and
      (defined ${$self->EndDate} and ${$self->EndDate} =~ /./)) {
    if (
	Date::ICal->new( ical => ${$self->StartDate})->epoch >
	Date::ICal->new( ical => ${$self->EndDate})->epoch
       ) {
      $proceed = 0;
      Message
	(
	 Message => "Cannot have a start date after an end date!",
	 GetSignalFromUserToProceed => 1,
	);
    }
  }
  return unless $proceed;

  if (defined ${$self->StartDate} and ${$self->StartDate} =~ /./) {
    my $res = $self->MyView->MyMetadata->SetMetadata
      (
       Item => $self->Rel,
       Predicate => "start-date",
       Value => ${$self->StartDate},
      );
  } else {
    my $res = $self->MyView->MyMetadata->DeleteMetadata
      (
       Item => $self->Rel,
       Predicates => ["start-date"],
      );
  }
  if (defined ${$self->EndDate} and ${$self->EndDate} =~ /./) {
    my $res = $self->MyView->MyMetadata->SetMetadata
      (
       Item => $self->Rel,
       Predicate => "end-date",
       Value => ${$self->EndDate},
      );
  } else {
    my $res = $self->MyView->MyMetadata->DeleteMetadata
      (
       Item => $self->Rel,
       Predicates => ["end-date"],
      );
  }
  if (defined ${$self->Duration} and ${$self->Duration} =~ /./) {
    my $res = $self->MyView->MyMetadata->SetMetadata
      (
       Item => $self->Rel,
       Predicate => "event-duration",
       Value => ${$self->Duration},
      );
  } else {
    my $res = $self->MyView->MyMetadata->DeleteMetadata
      (
       Item => $self->Rel,
       Predicates => ["event-duration"],
      );
  }
  if (${$self->HardTimeConstraints}) {
    $self->MyView->MyMetadata->SetUnaryPredicate
      (
       Predicate => "hard-time-constraints",
       Item => $self->Rel,
      );
  } else {
    $self->MyView->MyMetadata->UnsetUnaryPredicate
      (
       Predicate => "hard-time-constraints",
       Item => $self->Rel,
      );
  }
  if (${$self->Habitual}) {
    $self->MyView->MyMetadata->SetUnaryPredicate
      (
       Predicate => "habitual",
       Item => $self->Rel,
      );
  } else {
    $self->MyView->MyMetadata->UnsetUnaryPredicate
      (
       Predicate => "habitual",
       Item => $self->Rel,
      );
  }
  if (${$self->SoonerThanLater}) {
    $self->MyView->MyMetadata->SetUnaryPredicate
      (
       Predicate => "sooner-rather-than-later",
       Item => $self->Rel,
      );
  } else {
    $self->MyView->MyMetadata->UnsetUnaryPredicate
      (
       Predicate => "sooner-rather-than-later",
       Item => $self->Rel,
      );
  }

  # now close the window
  $self->Top1->destroy;
}

sub SetTimePeriod {
  my ($self,%args) = @_;
  my $selector = ${$self->Selector};
  if (defined $selector) {
    if ($selector eq "Start Date") {
      my ($h,$m,$s) = split /:/, $self->MyDateManip->TimePeriods->{$args{Period}}->[0];
      print SeeDumper([$h,$m,$s]);
      $self->UpdateDateTime
	(
	 Time => {
		  Hour => $h,
		  Minute => $m,
		  Second => $s,
		 },
	);
    } elsif ($selector eq "End Date") {
      my ($h,$m,$s) = split /:/, $self->MyDateManip->TimePeriods->{$args{Period}}->[1];
      print SeeDumper([$h,$m,$s]);
      $self->UpdateDateTime
	(
	 Time => {
		  Hour => $h,
		  Minute => $m,
		  Second => $s,
		 },
	);
    }
  }
}

1;
