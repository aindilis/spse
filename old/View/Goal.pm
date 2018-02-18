package SPSE2::GUI::Tab::View::Goal;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Source EntryID Description GraphVizNode Selected /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Source($args{Source});
  $self->EntryID($args{EntryID});
  $self->Description($args{Description});
  $self->GraphVizNode($args{GraphVizNode});
  # $self->Data->{Nodes}->{"node$nodename"} = $args{FullEntry};
  # $self->Data->{iNodes}->{$args{FullEntry}} = "node$nodename";
}

sub Equals {
  my ($self,%args) = @_;
  if (! defined $args{Goal}) {
    return 0;
  }
  if ($self->Source eq $args{Goal}->Source and
      $self->EntryID == $args{Goal}->EntryID and
      # just for good measure
      $self->Description eq $args{Goal}->Description) {
    return 1;
  }
  return 0;
}

sub Interlingua {
  my ($self,%args) = @_;
  return [
	  "entry-fn",
	  $self->Source,
	  $self->EntryID,
	 ];
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

1;
