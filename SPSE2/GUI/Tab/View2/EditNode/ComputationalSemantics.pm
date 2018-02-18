package SPSE2::GUI::Tab::View2::EditNode::ComputationalSemantics;

use Capability::Tokenize;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow Top1 MyView EntryID Rel MyNode /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyNode($args{Node});
  $self->EntryID($args{EntryID});
  $self->Rel(["entry-fn","pse",$self->EntryID]);
  $self->MyMainWindow($args{MainWindow});
  $self->MyView($args{MyView});
  $self->Top1
    ($self->MyMainWindow->Toplevel
     (
      -title => "Computational Semantics",
     ));

  # we want to load up a semantic representation of the text, just use
  # copied and pasted text for now, since not sure how want to do this

  # use the resources to get access to the formalize system

  # have it formalize it as logic form

  # also have an ontology of actors and types in the verber domains,
  # use this to edit different possible referents.  have it be able to
  # create and elaborate and rework goals as part of the semantics
  # tab.  for instance if a goal can be broken down into two tabs,
  # have that decided here.

  # show referents, predicates, DRSes, proposed PDDL, preconditions
  # and effects

  # first create the text windows, display the original text and the logic form of the text

  # add buttons for things like "Compute Likely Action Duration", "Find Similar", "Find Entailed", "Extract PDDL Elements"

  my $frame = $self->Top1->Frame();
  my $displayframe = $frame->Frame();
  my $originaltextframe = $displayframe->Frame;
  my $originaltextlabel = $originaltextframe->Label
    (
     -text => "Original Text",
    )->pack(-side => 'left');

  my $originaltext = $originaltextframe->Text
    (
     -relief       => 'sunken',
     -borderwidth  => 2,
     -width        => 80,
     -height        => 3,
    )->pack();
  $originaltext->Contents($self->MyNode->Description);
  $originaltextframe->pack(-side => "top");

  my $lftextframe = $displayframe->Frame;
  my $lftextlabel = $lftextframe->Label
    (
     -text => "Logic Form",
    )->pack(-side => 'left');

  my $lftext = $lftextframe->Text
    (
     -relief       => 'sunken',
     -borderwidth  => 2,
     -width        => 80,
     -height        => 25,
     -wrap => 'none',
    )->pack();
  $lftext->Contents($self->GetDRSForGoal);
  $lftextframe->pack(-side => "bottom");
  $displayframe->pack(-side => "left");

  my $buttonframe = $frame->Frame();
  $buttonframe->Button
    (
     -text => "Estimate Goal Duration",
     -command => sub {

     },
    )->pack(-side => 'bottom');

  $buttonframe->Button
    (
     -text => "Find Similar",
     -command => sub {

     },
    )->pack(-side => 'bottom');

  $buttonframe->Button
    (
     -text => "Find Entailed",
     -command => sub {

     },
    )->pack(-side => 'bottom');

  $buttonframe->Button
    (
     -text => "Find Entailing",
     -command => sub {

     },
    )->pack(-side => 'bottom');

  $buttonframe->Button
    (
     -text => "Extract PDDL Elements",
     -command => sub {

     },
    )->pack(-side => 'bottom');
  $buttonframe->pack();

  $buttonframe->Button
    (
     -text => "Refactor Goal",
     -command => sub {

     },
    )->pack(-side => 'bottom');
  $buttonframe->pack();

  my $buttonframe2 = $frame->Frame();
  my $assert = $buttonframe2->Button
    (
     -text => "Assert",
     -command => sub {
       $self->ActionAssert();
     },
    )->pack(-side => 'left');
  my $reset = $buttonframe2->Button
    (
     -text => "Reset",
     -command => sub {
       $self->ActionReset();
     },
    )->pack(-side => 'left');
  my $cancel = $buttonframe2->Button
    (
     -text => "Cancel",
     -command => sub {
       $self->ActionCancel();
     },
    )->pack(-side => 'left');
  $buttonframe2->pack(-side => "bottom");
  $frame->pack();
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
  print "Not yet implemented\n";
}

sub GetDRSForGoal {
  my ($self,%args) = @_;
  my $text = $self->MyNode->Description;
  my $res = $self->NonServerLogicForm(Text => $text);
  my @final;
  foreach my $line (split /\n/, $res) {
    if ($line =~ /^\%\%\%(.*)$/) {
      push @final, $1;
    }
  }
  return join("\n",@final);
}

sub NonServerLogicForm {
  my ($self,%args) = @_;
  open (OUT, ">/tmp/candctext") or die "death!\n";
  print OUT tokenize_treebank($args{Text});
  close (OUT);
  my $dir = `pwd`;
  chdir "/var/lib/myfrdcsa/sandbox/candc-1.00/candc-1.00";
  system "bin/candc --input /tmp/candctext --models models/boxer > /tmp/test.ccg";
  my $res = `bin/boxer --input /tmp/test.ccg --box true --flat true`;
  return CleanUp(Result => $res);
}

sub CleanUp {
  my (%args) = @_;
  # clean the text up nicely
  return $args{Result};
}

1;
