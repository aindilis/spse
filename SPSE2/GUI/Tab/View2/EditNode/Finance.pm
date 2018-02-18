package SPSE2::GUI::Tab::View2::EditNode::Finance;

use PerlLib::SwissArmyKnife;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow Top1 MyView Costs Earns EntryID Rel MyNode /

  ];

sub init {
  my ($self,%args) = @_;
  # 31531
  $self->MyNode($args{Node});
  $self->EntryID($args{EntryID});
  $self->Rel(["entry-fn","pse",$self->EntryID]);
  $self->MyMainWindow($args{MainWindow});
  $self->MyView($args{MyView});
  $self->Top1
    ($self->MyMainWindow->Toplevel
     (
      -title => "Financial Properties",
     ));
  my ($costs,$earns);
  # go ahead and load the information
  $costs = $self->MyNode->Costs;
  $earns = $self->MyNode->Earns;
  $self->Costs(\$costs);
  $self->Earns(\$earns);

  my $bottomframe = $self->Top1->Frame();

  my $valuesframe = $bottomframe->Frame();

  my $costsframe = $valuesframe->Frame();
  my $costslabel = $costsframe->Label
    (
     -text => "Costs",
    )->pack(-side => 'left');

  my $costsentry = $costsframe->Entry
    (
     -width => 100,
     -textvariable => \$costs,
    )->pack(-side => 'right');
  $costsframe->pack();

  my $earnsframe = $valuesframe->Frame();
  my $earnslabel = $earnsframe->Label
    (
     -text => "Earns",
    )->pack(-side => 'left');

  my $earnsentry = $earnsframe->Entry
    (
     -width => 100,
     -textvariable => \$earns,
    )->pack(-side => 'right');
  $earnsframe->pack();
  $valuesframe->pack();

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

  if (defined ${$self->Costs} and ${$self->Costs} =~ /./) {
    my $res = $self->MyView->MyMetadata->SetMetadata
      (
       Item => $self->Rel,
       Predicate => "costs",
       Value => ${$self->Costs},
      );
  } else {
    my $res = $self->MyView->MyMetadata->DeleteMetadata
      (
       Item => $self->Rel,
       Predicates => ["costs"],
      );
  }
  if (defined ${$self->Earns} and ${$self->Earns} =~ /./) {
    my $res = $self->MyView->MyMetadata->SetMetadata
      (
       Item => $self->Rel,
       Predicate => "earns",
       Value => ${$self->Earns},
      );
  } else {
    my $res = $self->MyView->MyMetadata->DeleteMetadata
      (
       Item => $self->Rel,
       Predicates => ["earns"],
      );
  }
  # now close the window
  $self->Top1->destroy;
}

1;
