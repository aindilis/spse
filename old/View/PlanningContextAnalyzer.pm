
# this is for computing which goals are most important, so on and so
# forth

sub ComputePriorities {
  my ($self,%args) = @_;
  # first load the priorities into the dep structure
  $self->Dependencies({});
  my $agentid = 1;
  $self->UpdateGoals;

  my $res1 = $UNIVERSAL::score->MyMySQL->Do
    (Statement => "select ID from goals where AgentID=$agentid and ID < 400;",
     KeyField => "ID");

  my $res2 = $UNIVERSAL::score->MyMySQL->Do
    (Statement => "select dependencies.* from dependencies,goals where goals.AgentID=$agentid and dependencies.Parent=goals.ID;",
     KeyField => "ID");

  foreach my $id (keys %$res1) {
    $self->Dependencies->{$id} = [];
  }

  foreach my $id (keys %$res2) {
    push @{$self->Dependencies->{$res2->{$id}->{Parent}}}, $res2->{$id}->{Child};
  }

  Message(Message => "Computing importance");
  my $imp = {};
  my $newimp = {};
  my $norm = {};
  foreach my $node (keys %{$self->Dependencies}) {
    $imp->{$node} = 1;
  }

  my $i = 10;
  while ($i) {
    foreach my $node (keys %{$self->Dependencies}) {
      my $indegree = scalar @{$self->Dependencies->{$node}};
      $newimp->{$node} = $imp->{$node};
      foreach my $child (@{$self->Dependencies->{$node}}) {
	if ($indegree) {
	  my $delta = $imp->{$node}/(2 * $indegree);
	  $newimp->{$child} += $delta;
	  $newimp->{$node} -= $delta;
	}
      }
    }
    $imp = $newimp;
    --$i;
  }

  Message(Message => "Normalizing importance");
  my $maximp = 0;
  foreach my $node (keys %{$self->Dependencies}) {
    if ($imp->{$node} > $maximp) {
      $maximp = $imp->{$node};
    }
  }
  if ($maximp) {
    foreach my $node (keys %{$self->Dependencies}) {
      $norm->{$node} = $imp->{$node} / $maximp;
    }
  }
  $self->Importance($imp);
  $self->Norm($norm);
}
