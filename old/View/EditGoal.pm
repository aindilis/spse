package SPSE2::GUI::Tab::View::EditGoal;

# Manager::Dialog

use PerlLib::EasyPersist;
use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View::EditGoal::DateTime;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Top1 Verbose Data Fields MyView /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyView($args{View});
  $self->Verbose($args{Verbose} || 0);
  my $title;
  if (exists $args{Goal}) {
    my $goal = $args{Goal};
    print Dumper($goal);
    $self->Data({});
    $self->Data->{Source} = $goal->Source;
    my $tmp;
    $self->Data->{Description} = $goal->Description;
    $self->Data->{EntryID} = $goal->EntryID;
    $title = "Edit Goal";
  } else {
    $title = "New Goal";
    $self->Data
      ($args{Data} ||
       {
	Source => "pse",
	EntryID => undef,
	Description => "",
       });
  }
  $self->Top1
    ($args{MainWindow}->Toplevel
     (
      -title => $title,
      -height => 600,
      -width => 800,
     ));

  # might make more sense just to sql or iterate over the KB here
  # rather than query all of these?  then again, hrm, editable versus
  # consequential?

  my $term = [];
  my $queries =
    [
     # BINARY RELATIONS

     #  cross-term
     ["depends", $term, \*{'::?Term'}],
     ["eases", $term, \*{'::?Term'}],
     ["provides", $term, \*{'::?Term'}],
     ["prefer", $term, \*{'::?Term'}],

     ["depends", \*{'::?Term'}, $term],
     ["eases", \*{'::?Term'}, $term],
     ["provides", \*{'::?Term'}, $term],
     ["prefer", \*{'::?Term'}, $term],

     #  other
     ["has-NL", $term, \*{'::?NatLang'}],
     ["pse-has-property", $term, \*{'::?Property'}],
     ["due-date-for-entry", $term, \*{'::?DueDate'}],
     ["start-date", $term, \*{'::?StartDate'}],
     ["end-date", $term, \*{'::?EndDate'}],
     ["event-duration", $term, \*{'::?EventDuration'}],

     #  fields
     ["costs", $term, \*{'::?Cost'}],
     ["earns", $term, \*{'::?Cost'}],
     ["disputed", $term, \*{'::?Dispute'}],
     ["comment", $term, \*{'::?Cost'}],
     ["solution", $term, \*{'::?Solution'}],
     ["has-feeling", $term, \*{'::?Feeling'}],
     ["assigned-by", $term, \*{'::?AssignedBy'}],
     ["assigned-to", $term, \*{'::?AssignedTo'}],
     ["belongs-to-system", $term, \*{'::?System'}],

     # UNARY RELATIONS
     ["goal", $term],

     # editable
     ["showstopper", $term],
     ["completed", $term],
     ["deleted", $term],
     ["cancelled", $term],
     ["ridiculous", $term],
     ["obsoleted", $term],
     ["rejected", $term],
     ["skipped", $term],
    ];

  # when you do what you need to do when it needs to be done, then you can do what you want to do when you want to"

  my @order = ("Source", "Description", "Temporal Constraints",
	       "Recurrence", "Status", "Dependencies",
	       "Predependencies", "Eases", "Blocking Issues", "Labor
	       Involved");

  my $fields =
    {
     "Source" => {
		  Description => "source from which this goal came",
		  Args => ["tinytext"],
		  TextVar => $self->Data->{Source},
		 },
     "EntryID" => {
		   Description => "the id for the entry within the source",
		   Args => ["tinytext"],
		   TextVar => $self->Data->{EntryID},
		  },
     "Description" => {
		       Description => "goal description",
		       Args => ["text"],
		       TextVar => $self->Data->{Description},
		       Normal => 1,
		       TakeFocus => 1,
		      },
     "Temporal Constraints" => {
				Description => "timing considerations like due date, etc",
				Args => ["function"],
				Function => sub {
				  my $datetime = SPSE2::GUI::Tab::View::EditGoal::DateTime->new
				    (
				     MainWindow => $args{MainWindow},
				     EntryID => $self->Data->{EntryID},
				    );
				},
			       },
     "Recurrence" => {
		      Description => "schedule according to which this goal repeats",
		     },
     "Status" => {
		  Description => "whether the goal has been completed, etc",
		  Args => [["enum",["completed","deleted","etc"]]],
		 },
     "Dependencies" => {
			Description => "goals which this goal depends upon for its completion",
			Args => ["array"],
		       },
     "Predependencies" => {
			   Description => "goals which depend upon this goal for their completion",
			   Args => ["array"],
			  },
     "Eases" => {
		 Description => "other goals which this goal makes easier or enables",
		 Args => ["array"],
		},
     "Blocking Issues" => {
			   Description => "critical reasons this goal cannot currently be completed",
			   Args => ["array"],
			  },
     "Labor Involved" => {
			  Description => "the estimated amount of time and/or work required to complete this goal",
			  Args => ["array"],
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
	  my $state;
	  if ($fields->{$field}->{Normal}) {
	    $state = "normal";
	  } else {
	    $state = "disabled";
	  }
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
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => $state,
	      );
	    my $name = $frame2->Text
	      (
	       -relief       => 'sunken',
	       -borderwidth  => 2,
	       -width        => 80,
	       -height        => 5,
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
	  } elsif ($arg2 eq "function") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );
	    my $name = $frame2->Button
	      (
	       -text => $field,
	       -command => sub {$self->Fields->{$field}->{Function}->()},
	      );
	    $name->configure(-state => $state);
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
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
  if (exists $args{Goal}) {
    $buttons->Button
      (
       -text => "Defaults",
       -command => sub {$self->ActionDefaults},
      )->pack(-side => "left");
    $buttons->Button
      (
       -text => "Apply",
       -command => sub {$self->ActionApply},
      )->pack(-side => "left");
    $buttons->Button
      (
       -text => "Save Configuration",
       -command => sub {$self->ActionSaveConfiguration},
      )->pack(-side => "left");
    $buttons->Button
      (
       -text => "Cancel",
       -command => sub { $self->Cancel(); },
      )->pack(-side => "right");
  } else {
    $buttons->Button
      (
       -text => "Create New Goal",
       -command => sub {$self->FindOrCreateGoal},
      )->pack(-side => "left");
    $buttons->Button
      (
       -text => "Cancel",
       -command => sub { $self->Top1->destroy; },
      )->pack(-side => "right");
  }
  $buttons->pack;
  $self->Top1->bind
    (
     "all",
     "<Escape>",
     sub {
       $self->Cancel();
     },
    );
}

sub ActionSaveConfiguration {
  my ($self,%args) = @_;
  # just print out the configuration for now
  # print Dumper($self->Fields);
}

sub ActionApply {
  my ($self,%args) = @_;

}

sub ActionDefaults {
  my ($self,%args) = @_;

}

sub Execute {
  my ($self,%args) = @_;
}

sub ExecuteCommand {
  my ($self,%args) = @_;
  # get all the options, and run them
  # print join(" ",@args)."\n";
  # iterate over all the frames contained here
  foreach my $child ($self->Top1->children) {
    print Dumper($child);
  }
}

sub FindOrCreateGoal {
  my ($self,%args) = @_;
  # now we should have all the information in the fields, go ahead and
  # first create the goal, then just do a "save changes" as you would
  # any other goal.

  my $description = $self->Fields->{Description}->{Widget}->Contents;
  $description =~ s/\s+$//s;
  my $goal = $self->MyView->FindOrCreateGoalHelper
    (
     Description => $description,
    );
  $self->ActionSaveConfiguration
    (
     Goal => $goal,
    );
  my $goals = $self->MyView->MyGoalManager->GetGoal
    (
     Description => $description,
    );
  $self->MyView->CenterCanvasWindowOnGoal
    (
     Goal => $goals->[0],
    );
  $self->Top1->destroy;
}

sub Cancel {
  my ($self,%args) = @_;
  # check for changes

  # if there are changes, prompt to determine whether to really cancel
  # or not

  $self->Top1->destroy;
}

1;
