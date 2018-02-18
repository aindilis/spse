package SPSE2::GUI::Tab::View2::Node;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Source EntryID GraphVizNode Selected Hidden Type MyView DisplayData /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyView($args{View});
  $self->Source($args{Source});
  $self->EntryID($args{EntryID});
  $self->GraphVizNode($args{GraphVizNode});
  $self->DisplayData({});

  # $self->Data->{Nodes}->{"node$nodename"} = $args{FullEntry};
  # $self->Data->{iNodes}->{$args{FullEntry}} = "node$nodename";
}

sub Equals {
  my ($self,%args) = @_;
  if (! defined $args{Node}) {
    return 0;
  }
  if ($self->Source eq $args{Node}->Source and
      $self->EntryID == $args{Node}->EntryID and
      # just for good measure
      $self->Description eq $args{Node}->Description) {
    return 1;
  }
  return 0;
}

sub NodeInterlingua {
  my ($self,%args) = @_;
  return [
	  "entry-fn",
	  $self->Source,
	  $self->EntryID,
	 ];
}

sub NodeInterlinguaDumper {
  my ($self,%args) = @_;
  return Dumper($self->NodeInterlingua);
}

sub DisplayPosition {
  my ($self,%args) = @_;
  my $tkgv = $args{TkGraphViz};
  my $nodeid = $self->GraphVizNode;
  my $width;
  my $height;
  foreach my $line (@{$tkgv->{SubWidget}->{scrolled}->{layout}}) {
    if ($line =~ /\s*graph \[bb="0,0,(\d+),(\d+)"\]/) {
      $width = $1;
      $height = $2;
    } elsif ($line =~ /\s*node$nodeid \[label/) {
      # parse this line
      # node154 [label="Fix the problem with the system\\ndisplaying the wrong relations after\\ndoing the unary relation removal.", color=black, fillcolor=lightgray, style=filled, pos="155,4243", width="3.64", height="0.82"];',
      if ($line =~ /pos="(\d+),(\d+)"/) {
	my $x = $1;
	my $y = $2;
	return {
		X => $x,
		Y => $y,
		Width => $width,
		Height => $height,
		XFraction => $x / $width,
		YFraction => $y / $height,
		Success => 1,
	       };
      }
    }
  }
  return {
	  Success => 0,
	 };
}

sub GetSetMetadata {
  my ($self,%args) = @_;
  my @values = @{$args{Values}};
  if (scalar @values) {
    my $value = shift @values;
    my $res = $self->MyView->MyMetadata->SetMetadata
      (
       Predicate => $args{Predicate},
       Item => $self->NodeInterlingua,
       Value => $value,
      );
  } else {
    my $res = $self->MyView->MyMetadata->GetMetadata
      (
       Predicate => $args{Predicate},
       Item => $self->NodeInterlingua,
      );
    if ($res->{Success}) {
      return $res->{Result};
    } else {
      # this could be an error
      return undef;
    }
  }
}

sub Severity {
  my $self = shift @_;
  $self->GetSetMetadata
    (
     Values => \@_,
     Predicate => "severity",
    );
}

sub Description {
  my $self = shift @_;
  $self->GetSetMetadata
    (
     Values => \@_,
     Predicate => "has-NL",
    );
}

sub Costs {
  my $self = shift @_;
  $self->GetSetMetadata
    (
     Values => \@_,
     Predicate => "costs",
    );
}

sub Earns {
  my $self = shift @_;
  $self->GetSetMetadata
    (
     Values => \@_,
     Predicate => "earns",
    );
}

sub IsHidden {
  my ($self,%args) = @_;
  return $self->Hidden;
}

1;
