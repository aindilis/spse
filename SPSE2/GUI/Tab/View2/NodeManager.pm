package SPSE2::GUI::Tab::View2::NodeManager;

use PerlLib::Collection;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Nodes Data MyView SelectionOrder /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Nodes
    (PerlLib::Collection->new
     (Type => "SPSE2::GUI::Tab::View2::Node"));
  $self->Nodes->Contents({});
  $self->SelectionOrder([]);
  $self->MyView($args{MyView});
}

sub AddNode {
  my ($self,%args) = @_;
  $self->Nodes->AddAutoIncrement
    (
     Item => $args{Node},
    );
}

sub GetNode {
  my ($self,%args) = @_;
  my @matches;
  if (exists $args{GraphVizNode}) {
    foreach my $node ($self->Nodes->Values) {
      if ($node->GraphVizNode eq $args{GraphVizNode}) {
	push @matches, $node;
      }
    }
  }
  if (exists $args{NodeInterlingua}) {
    foreach my $node ($self->Nodes->Values) {
      if ($node->NodeInterlinguaDumper eq Dumper($args{NodeInterlingua})) {
	push @matches, $node;
      }
    }
  }
  if (exists $args{Selected}) {
    if (1) {
      @matches = @{$self->SelectionOrder};
    } else {
      foreach my $node ($self->Nodes->Values) {
	if (defined $node->Selected and $node->Selected eq $args{Selected}) {
	  push @matches, $node;
	}
      }
    }
  }
  if (exists $args{Unselected}) {
    foreach my $node ($self->Nodes->Values) {
      if (! $node->Selected) {
	push @matches, $node;
      }
    }
  }
  if (exists $args{Point}) {
    if (scalar @{$self->SelectionOrder} >= 1) {
      my $size = scalar @{$self->SelectionOrder};
      @matches = $self->SelectionOrder->[0];
    }
  }
  if (exists $args{Mark}) {
    if (scalar @{$self->SelectionOrder} >= 2) {
      my $size = scalar @{$self->SelectionOrder};
      @matches = $self->SelectionOrder->[1];
    }
  }
  if (exists $args{Description}) {
    foreach my $node ($self->Nodes->Values) {
      if ($node->Description eq $args{Description}) {
	push @matches, $node;
      }
    }
  }
  if (exists $args{Severity}) {
    my $on = 0;
    my @matching;
    foreach my $severity ("Wishlist","Unimportant","Important","Very Important") {
      if ($args{Severity} eq lc($severity)) {
	$on = 1;
      }
      if ($on) {
	push @matching, lc($severity);
      }
    }
    my $regex = "(".join("|",@matching).")";
    print SeeDumper({Regex => $regex});
    foreach my $node ($self->Nodes->Values) {
      if ($node->Severity =~ /^$regex$/) {
	push @matches, $node;
      }
    }
  }
  if (exists $args{All}) {
    foreach my $node ($self->Nodes->Values) {
      push @matches, $node;
    }
  }
  if (exists $args{Reference}) {
    my $hash = {};
    foreach my $node ($self->Nodes->Values) {
      $hash->{$node} = $node;
    }
    return $hash->{$args{Reference}};
  }
  return \@matches;
}

sub Select {
  my ($self,%args) = @_;
  my $node1;
  if (exists $args{Node}) {
    $node1 = $args{Node};
  }
  if ($args{Selection} eq "Toggle-Single") {
    # this means to toggle the item selected and deselect everything
    # else
    $self->Select
      (
       Selection => "None",
       Skip => [
		$node1,
	       ],
      );
    # now toggle this node
    $self->ToggleSelected
      (
       Node => $node1,
      );
  }
  if ($args{Selection} eq "Toggle-Union") {
    # this means to toggle the item selected
    $self->ToggleSelected
      (
       Node => $node1,
      );
  }
  if ($args{Selection} eq "All") {
    foreach my $node ($self->Nodes->Values) {
      if (! $self->Skip
	  (
	   Skip => $args{Skip},
	   Node => $node,
	  )) {
	$self->AddNodeToSelection(Node => $node);
      }
    }
  }
  if ($args{Selection} eq "None") {
    foreach my $node ($self->Nodes->Values) {
      if (! $self->Skip
	  (
	   Skip => $args{Skip},
	   Node => $node,
	  )) {
	$self->RemoveNodeFromSelection
	  (
	   Node => $node,
	  );
      }
    }
  }
  if ($args{Selection} eq "Invert") {
    foreach my $node ($self->Nodes->Values) {
      if (! $self->Skip
	  (
	   Skip => $args{Skip},
	   Node => $node,
	  )) {
	$self->ToggleSelected
	  (
	   Node => $node,
	  );
      }
    }
  }
  if ($args{Selection} eq "By Search") {
    # pop a window asking for a search, and match by name
    my $regex = QueryUser("Please enter Search:");
    if ($regex) {
      foreach my $node ($self->Nodes->Values) {
	if ($node->Description =~ /$regex/i) {
	  if (! $self->Skip
	      (
	       Skip => $args{Skip},
	       Node => $node,
	      )) {
	    $self->AddNodeToSelection(Node => $node);
	  }
	}
      }
    }
  }
  if ($args{Selection} eq "By Regex") {
    # pop a window asking for a search, and match by name
    my $regex = QueryUser("Please enter Regex:");
    if ($regex) {
      foreach my $node ($self->Nodes->Values) {
	if ($node->Description =~ /$regex/i) {
	  if (! $self->Skip
	      (
	       Skip => $args{Skip},
	       Node => $node,
	      )) {
	    $self->AddNodeToSelection(Node => $node);
	  }
	}
      }
    }
  }
  if ($args{Selection} eq "By Similarity") {
    # pop a window asking for a search, and match by name
    my $regex = QueryUser("Please enter search:");
    if ($regex) {
      foreach my $node ($self->Nodes->Values) {
	if ($node->Description =~ /$regex/i) {
	  if (! $self->Skip
	      (
	       Skip => $args{Skip},
	       Node => $node,
	      )) {
	    $self->AddNodeToSelection(Node => $node);
	  }
	}
      }
    }
  }
  if ($args{Selection} eq "By Entailment") {
    my $entailment = QueryUser("Please enter Entailment:");
    if ($entailment) {
      foreach my $node ($self->Nodes->Values) {
	if (Entails
	    (
	     T => $entailment,
	     H => $node->Description,
	    )) {
	  if (! $self->Skip
	      (
	       Skip => $args{Skip},
	       Node => $node,
	      )) {
	    $self->AddNodeToSelection(Node => $node);
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
    foreach my $node2 (@{$args{Skip}}) {
      if ($args{Node}->Equals(Node => $node2)) {
	return 1;
      }
    }
  }
  return 0;
}

sub ToggleSelected {
  my ($self,%args) = @_;
  my $node1 = $args{Node};
  if (defined $node1) {
    if ($node1->Selected) {
      $self->RemoveNodeFromSelection
	(
	 Node => $node1,
	);
    } else {
      $self->AddNodeToSelection
	(
	 Node => $node1,
	);
    }
  }
}

sub AddNodeToSelection {
  my ($self,%args) = @_;
  my $node1 = $args{Node};
  # first remove the node from the selection if it already exists
  $self->RemoveNodeFromSelection
    (
     Node => $node1,
    );
  # then add it
  push @{$self->SelectionOrder}, $node1;
  $node1->Selected(1);
}

sub RemoveNodeFromSelection {
  my ($self,%args) = @_;
  my $node1 = $args{Node};

  # could have something here which looked to see if it was already
  # deselected and just skipped it
  if (! $node1->Selected) {
    return;
  }

  my @newqueue;
  foreach my $node2 (@{$self->SelectionOrder}) {
    if (! $node1->Equals(Node => $node2)) {
      push @newqueue, $node2;
    }
  }
  $self->SelectionOrder(\@newqueue);
  $node1->Selected(0);
}

sub PrintSelectionOrder {
  my ($self,%args) = @_;
  foreach my $node (@{$self->SelectionOrder}) {
    print "[".$node->Source.", ".$node->EntryID."]\n";
  }
}

sub Entails {
  my ($self,%args) = @_;
  print "Entailment not yet implemented\n";
  return 0;
}

1;
