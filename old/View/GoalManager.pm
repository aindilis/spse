package SPSE2::GUI::Tab::View::GoalManager;

use PerlLib::Collection;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Goals Data MyView SelectionOrder /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Goals
    (PerlLib::Collection->new
     (Type => "SPSE2::GUI::Tab::View::Goal"));
  $self->Goals->Contents({});
  $self->SelectionOrder([]);
  $self->MyView($args{MyView});
}

sub AddGoal {
  my ($self,%args) = @_;
  $self->Goals->AddAutoIncrement
    (
     Item => $args{Goal},
    );
}

sub GetGoal {
  my ($self,%args) = @_;
  my @matches;
  if (exists $args{GraphVizNode}) {
    foreach my $goal ($self->Goals->Values) {
      if ($goal->GraphVizNode eq $args{GraphVizNode}) {
	push @matches, $goal;
      }
    }
  }
  if (exists $args{Selected}) {
    if (1) {
      @matches = @{$self->SelectionOrder};
    } else {
      foreach my $goal ($self->Goals->Values) {
	if (defined $goal->Selected and $goal->Selected eq $args{Selected}) {
	  push @matches, $goal;
	}
      }
    }
  }
  if (exists $args{Description}) {
    foreach my $goal ($self->Goals->Values) {
      if ($goal->Description eq $args{Description}) {
	push @matches, $goal;
      }
    }
  }
  return \@matches;
}

sub Select {
  my ($self,%args) = @_;
  my $goal1;
  if (exists $args{Goal}) {
    $goal1 = $args{Goal};
  }
  if ($args{Selection} eq "Toggle-Single") {
    # this means to toggle the item selected and deselect everything
    # else
    $self->Select
      (
       Selection => "None",
       Skip => [
		$goal1,
	       ],
      );
    # now toggle this goal
    $self->ToggleSelected
      (
       Goal => $goal1,
      );
  }
  if ($args{Selection} eq "Toggle-Union") {
    # this means to toggle the item selected
    $self->ToggleSelected
      (
       Goal => $goal1,
      );
  }
  if ($args{Selection} eq "All") {
    foreach my $goal ($self->Goals->Values) {
      if (! $self->Skip
	  (
	   Skip => $args{Skip},
	   Goal => $goal,
	  )) {
	$self->AddGoalToSelection(Goal => $goal);
      }
    }
  }
  if ($args{Selection} eq "None") {
    foreach my $goal ($self->Goals->Values) {
      if (! $self->Skip
	  (
	   Skip => $args{Skip},
	   Goal => $goal,
	  )) {
	$self->RemoveGoalFromSelection
	  (
	   Goal => $goal,
	  );
      }
    }
  }
  if ($args{Selection} eq "Invert") {
    foreach my $goal ($self->Goals->Values) {
      if (! $self->Skip
	  (
	   Skip => $args{Skip},
	   Goal => $goal,
	  )) {
	$self->ToggleSelected
	  (
	   Goal => $goal,
	  );
      }
    }
  }
  if ($args{Selection} eq "By Search") {
    # pop a window asking for a search, and match by name
    my $regex = QueryUser("Please enter Search:");
    if ($regex) {
      foreach my $goal ($self->Goals->Values) {
	if ($goal->Description =~ /$regex/i) {
	  if (! $self->Skip
	      (
	       Skip => $args{Skip},
	       Goal => $goal,
	      )) {
	    $self->AddGoalToSelection(Goal => $goal);
	  }
	}
      }
    }
  }
  if ($args{Selection} eq "By Regex") {
    # pop a window asking for a search, and match by name
    my $regex = QueryUser("Please enter Regex:");
    if ($regex) {
      foreach my $goal ($self->Goals->Values) {
	if ($goal->Description =~ /$regex/i) {
	  if (! $self->Skip
	      (
	       Skip => $args{Skip},
	       Goal => $goal,
	      )) {
	    $self->AddGoalToSelection(Goal => $goal);
	  }
	}
      }
    }
  }
  if ($args{Selection} eq "By Entailment") {
    my $entailment = QueryUser("Please enter Entailment:");
    if ($entailment) {
      foreach my $goal ($self->Goals->Values) {
	if (Entails
	    (
	     T => $entailment,
	     H => $goal->Description,
	    )) {
	  if (! $self->Skip
	      (
	       Skip => $args{Skip},
	       Goal => $goal,
	      )) {
	    $self->AddGoalToSelection(Goal => $goal);
	  }
	}
      }
    }
  }
  $self->PrintSelectionOrder();
}

sub Skip {
  my ($self,%args) = @_;
  if ($args{Skip}) {
    foreach my $goal2 (@{$args{Skip}}) {
      if ($args{Goal}->Equals(Goal => $goal2)) {
	return 1;
      }
    }
  }
  return 0;
}

sub ToggleSelected {
  my ($self,%args) = @_;
  my $goal1 = $args{Goal};
  if (defined $goal1) {
    if ($goal1->Selected) {
      $self->RemoveGoalFromSelection
	(
	 Goal => $goal1,
	);
    } else {
      $self->AddGoalToSelection
	(
	 Goal => $goal1,
	);
    }
  }
}

sub AddGoalToSelection {
  my ($self,%args) = @_;
  my $goal1 = $args{Goal};
  # first remove the goal from the selection if it already exists
  $self->RemoveGoalFromSelection
    (
     Goal => $goal1,
    );
  # then add it
  push @{$self->SelectionOrder}, $goal1;
  $goal1->Selected(1);
}

sub RemoveGoalFromSelection {
  my ($self,%args) = @_;
  my $goal1 = $args{Goal};

  # could have something here which looked to see if it was already
  # deselected and just skipped it
  if (! $goal1->Selected) {
    return;
  }

  my @newqueue;
  foreach my $goal2 (@{$self->SelectionOrder}) {
    if (! $goal1->Equals(Goal => $goal2)) {
      push @newqueue, $goal2;
    }
  }
  $self->SelectionOrder(\@newqueue);
  $goal1->Selected(0);
}

sub PrintSelectionOrder {
  my ($self,%args) = @_;
  foreach my $goal (@{$self->SelectionOrder}) {
    print "[".$goal->Source.", ".$goal->EntryID."]\n";
  }
}

sub Entails {
  my ($self,%args) = @_;
  print "Entailment not yet implemented\n";
  return 0;
}

1;
