package SPSE2::GUI::Tab::View::VerberGUI;

use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View::PlanningContextParser;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyPlanningContextParser Top1 Verbose Data Fields MyView /

  ];

sub init {
  my ($self,%args) = @_;
  # generate the domain and problem files
  $self->MyView($args{View});
  $self->Verbose($args{Verbose} || 0);
  $self->Top1
    ($self->MyView->MyTkGraphViz->{MainWindow}->Toplevel
     (
      -title => "Verber GUI",
      -height => 600,
      -width => 800,
     ));
  # get the selected goals
  my $res = $self->MyView->MyGoalManager->GetGoal
    (
     Selected => 1,
    );
  my @goals;
  foreach my $goal (@$res) {
    push @goals, $goal->Interlingua;
  }
  $self->MyPlanningContextParser
    (SPSE2::GUI::Tab::View::PlanningContextParser->new
     (
      Database => $args{Database},
      Context => $self->MyView->Context,
      Goals => \@goals,
     ));
  $self->Data({});
}

sub Execute {
  my ($self,%args) = @_;
  # parse the planning context with the parser
  $self->MyPlanningContextParser->Generate();
  $self->Data->{Domain} = $self->MyPlanningContextParser->MyDomain->Generate
    (
     Output => "verb",
    );
  $self->Data->{Problem} = $self->MyPlanningContextParser->MyProblem->Generate
    (
     Output => "verb",
    );

  # when you do what you need to do when it needs to be done, then you
  # can do what you want to do when you want to"
  my @order = ("Domain", "Problem");
  my $fields =
    {
     "Domain" => {
		  Description => "Verber file for PDDL Domain",
		  Args => ["text"],
		  TextVar => $self->Data->{Domain},
		 },
     "Problem" => {
		   Description => "Verber file for PDDL Problem",
		   Args => ["text"],
		   TextVar => $self->Data->{Problem},
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
     -text => "Generate Plan",
     -command => sub {$self->ActionGeneratePlan},
    )->pack(-side => "left");
  $buttons->Button
    (
     -text => "Cancel",
     -command => sub { $self->Top1->destroy; },
    )->pack(-side => "right");
  $buttons->pack;
}

sub ActionGeneratePlan {
  my ($self,%args) = @_;
  $self->MyPlanningContextParser->GeneratePlan();
}

1;

# Generate Plan

# we can probably take our model here, and export it as PDDL, then
# run verber on it, get the output plan, and either display it, or
# execute it

# the interactive execution monitor would then come out
