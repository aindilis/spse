package SPSE2::GUI::Tab::View::EditGoal::DateTime;

use PerlLib::SwissArmyKnife;
use Verber::Util::DateManip;

use DateTime;
use DateTime::Format::ICal;
use Tk;
use Tk::Month;
use Tk::TimePick;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow Top1 StartDate EndDate Duration Selector MyDateManip EntryID /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMainWindow($args{MainWindow});
  $self->Top1
    ($self->MyMainWindow->Toplevel
     (
      -title => "Temporal Properties",
     ));
  $self->EntryID($args{EntryID});

  $self->MyDateManip(Verber::Util::DateManip->new());

  my ($startdate,$startdatedate,$startdatetime,$enddate,$enddatedate,$enddatetime,$duration);
  my $selector = "Start Date";

  $self->StartDate(\$startdate);
  $self->EndDate(\$enddate);
  $self->Duration(\$duration);
  $self->Selector(\$selector);



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
  my $month = "August";
  my $year = "2010";
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
  my $tp1 = $timeframe->TimePick()->pack();
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

  $timeframe->pack(-side => 'right');
  $topframe->pack(-side => 'top');

  my $bottomframe = $self->Top1->Frame();

  my $radiobuttonframe = $bottomframe->Frame();
  my $lbl_gender = $radiobuttonframe->Label( -text => "Choose Time")->pack();
  my $rdb_s = $radiobuttonframe -> Radiobutton
    (
     -text => "Start Date",
     -value => "Start Date",
     -variable => \$selector,
    )->pack(-side => 'left');
  my $rdb_e = $radiobuttonframe -> Radiobutton
    (
     -text => "End Date",
     -value => "End Date",
     -variable => \$selector,
    )->pack(-side => 'right');
  $radiobuttonframe->pack();

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

  my $buttonframe = $bottomframe->Frame();
  my $cancel = $buttonframe->Button
    (
     -text => "Cancel",
     -command => sub {
       $self->ActionCancel();
     },
    )->pack(-side => 'left');

  my $reset = $buttonframe->Button
    (
     -text => "Reset",
     -command => sub {
       $self->ActionReset();
     },
    )->pack(-side => 'left');

  my $assert = $buttonframe->Button
    (
     -text => "Assert",
     -command => sub {
       $self->ActionAssert();
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
			  );
      ${$self->EndDate} = DateTime::Format::ICal->format_datetime
	($edt);
    }
  }
  if (defined $sdt and defined $edt) {
    $dur = $edt - $sdt;
    print Dumper($dur);
    ${$self->Duration} = $self->MyDateManip->DurationToString
      (
       Duration => $dur,
      );
  }
}

sub ActionCancel {
  my ($self,%args) = @_;
}

sub ActionReset {
  my ($self,%args) = @_;
}

sub ActionAssert {
  my ($self,%args) = @_;
  # convert to the proper format now
  my $rel = ["entry-fn","pse",31531];
  my $assertions = [];
  if (defined ${$self->StartDate}) {
    push @$assertions, ["start-date",$rel,${$self->StartDate}];
  }
  if (defined ${$self->EndDate}) {
    push @$assertions, ["end-date",$rel,${$self->EndDate}];
  }
  if (defined ${$self->Duration}) {
    push @$assertions, ["event-duration",$rel,${$self->Duration}];
  }
  print Dumper($assertions);
}

1;
