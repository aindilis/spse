package SPSE2::GUI::Tab::View2::Domain::Planning::Control::SyncCalendar;

use Manager::Dialog qw(Approve SubsetSelect);
use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View2::Domain::Planning::Model::Calendar;
use SPSE2::GUI::Tab::View2::Domain::Planning::Control::PlanningContextParser;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyCalendar Top1 Verbose Data Fields MyView MyModel /

  ];

sub init {
  my ($self,%args) = @_;
  # generate the domain and problem files
  $self->MyView($args{View});
  $self->MyModel($self->MyView->MyDomainManager->MyDomains->Contents->{Planning}->Model);

  $self->Verbose($args{Verbose} || 0);
  $self->Top1
    ($self->MyView->MyTkGraphViz->{MainWindow}->Toplevel
     (
      -title => "Sync Calendar GUI",
      -height => 600,
      -width => 800,
     ));
  $self->MyCalendar
    (SPSE2::GUI::Tab::View2::Domain::Planning::Model::Calendar->new());
  $self->Data({});
}

sub Execute {
  my ($self,%args) = @_;
  # parse the planning context with the parser
  # choose which calendar (just offer GMAIL for now)
  $self->Data->{Username} = "adougher9";
  $self->Data->{Password} = "8Bluskye";

  # when you do what you need to do when it needs to be done, then you
  # can do what you want to do when you want to"
  my @order = ("Username", "Password");
  my $fields =
    {
     "Username" => {
		  Description => "GMail username",
		  Args => ["tinytext"],
		  TextVar => $self->Data->{Username},
		 },
     "Password" => {
		   Description => "GMail password",
		   Args => ["tinytext"],
		   TextVar => $self->Data->{Password},
		  },
    };
  $self->Fields($fields);
  $options = $self->Top1->Frame();
  foreach my $field (@order) {
    if (! exists $fields->{$field}->{Args}) {
      $options->Checkbutton
	(
	 -text => $field,
	 -command => sub { },
	)->pack(-fill => "x");	# , -anchor => 'left');
    } else {
      my $frame = $options->Frame(-relief => 'raised', -borderwidth => 2);
      my @items;
      foreach my $arg2 (@{$fields->{$field}->{Args}}) {
	my $ref = ref $arg2;
	if ($ref eq "ARRAY") {
	  # skip for now
	  $options->Checkbutton
	    (
	     -text => $field,
	     -command => sub { },
	    )->pack(-fill => "x");
	} elsif ($ref eq "") {
	  if ($arg2 eq "tinytext") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );
	    my $name = $frame2->Entry
	      (
	       -state => 'disabled',
	       -relief       => 'sunken',
	       -borderwidth  => 2,
	       -textvariable => \$fields->{$field}->{TextVar},
	       -width        => 25,
	      );
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } elsif ($arg2 eq "text") {
	    my $frame2 = $frame->Frame();
	    my $state;
	    if ($fields->{$field}->{Normal}) {
	      $state = "normal";
	    } else {
	      $state = "disabled";
	    }
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => $state,
	      );
	    my $name = $frame2->Text
	      (
	       -relief       => 'sunken',
	       -borderwidth  => 2,
	       -width        => 120,
	       -height        => 25,
	      );
	    $name->Contents($fields->{$field}->{TextVar});
	    $name->configure(-state => $state);
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } else {
	    # print Dumper({Huh => $arg2});
	  }
	}
      }
      my $checkbutton = $frame->Checkbutton
	(
	 -text => $field,
	 -command => sub {
	   foreach my $item (@items) {
	     if ($item->{name}->cget('-state') eq 'disabled') {
	       $item->{name}->configure(-state => "normal");
	       $item->{nameLabel}->configure(-state => "normal");
	     } else {
	       $item->{name}->configure(-state => "disabled");
	       $item->{nameLabel}->configure(-state => "disabled");
	     }
	   }
	 },
	);
      if ($fields->{$field}->{Normal}) {
	$checkbutton->{'Value'} = 1;
      } else {
	$checkbutton->{'Value'} = 0;
      }

      $checkbutton->pack(-fill => "x");
      foreach my $item (@items) {
	$item->{frame}->pack;
      }
      $frame->pack();
    }
  }
  $options->pack;

  $buttons = $self->Top1->Frame();
  $buttons->Button
    (
     -text => "Choose Calendars",
     -command => sub {$self->ActionChooseCalendars},
    )->pack(-side => "left");
  $buttons->Button
    (
     -text => "Cancel",
     -command => sub { $self->Top1->destroy; },
    )->pack(-side => "right");
  $buttons->pack;
}

sub ActionChooseCalendars {
  my ($self,%args) = @_;
  my $res = $self->MyCalendar->ListGMailCalendars
    (
     Username => $self->Data->{Username},
     Password => $self->Data->{Password},
    );
  if ($res->{Success}) {
    my @res2 = SubsetSelect
      (
       Set => [@{$res->{Titles}}],
       Selection => {},
      );
    my $filter = {};
    foreach my $title (@res2) {
      $filter->{$title} = 1;
    }

    # FIXME
    # put a lock on new generation of assertions

    $self->MyModel->MyListProcessor->GetPSEEntryIDCounter();
    my $res3 = $self->MyCalendar->Sync
      (
       PSEEntryIDCounter => $self->MyModel->MyListProcessor->PSEEntryIDCounter,
       Username => $self->Data->{Username},
       Password => $self->Data->{Password},
       Filter => $filter,
      );
    if ($res3->{Success}) {
      # now we wish to show these to the users and have them
      my $res4 = $self->MyModel->MyImportExport->Convert
	(
	 Input => $res3->{Assertions},
	 InputType => "Interlingua",
	 OutputType => "Emacs String",
	);
      if ($res4->{Success}) {
	print $res4->{Output}."\n";
	if (Approve("Look at the terminal output.  Add these assertions?")) {
	  my $res5 = $self->MyView->ModifyAxiomsCautiously
	    (
	     Entries => [
			 {
			  Assertions => $res3->{Assertions},
			 },
			],
	    );
	  if ($res5->{Success} and $res5->{Changes}) {
	    $self->MyModel->MyListProcessor->PSEEntryIDCounter($res3->{PSEEntryIDCounter});
	  }
	}
      }
    }
  }
}

1;
