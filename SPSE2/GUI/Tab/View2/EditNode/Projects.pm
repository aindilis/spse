package SPSE2::GUI::Tab::View2::EditNode::Projects;

use MyFRDCSA qw(Dir);
use PerlLib::SwissArmyKnife;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow Top1 MyView Costs Earns EntryID Rel MyNode MyMenu
   MyButton MyProjects MyText /

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
      -title => "Project Properties",
     ));
  my ($costs,$earns);

  my $menu = $self->Top1->Menu(-tearoff => 0);
  $menu->add
    (
     'command',
     -label => 'Dismiss Menu',
     -command => sub {
     },
    );
  my $menu1 = $menu->cascade
    (
     -label => 'FRDCSA',
     -tearoff => 0,
    );
  my $menu2 = $menu1->cascade
    (
     -label => 'Internal Codebases',
     -tearoff => 0,
    );
  my $icodebases2 = $self->ListProjects(ProjectType => "internal codebases");
  foreach my $icodebase (@$icodebases2) {
    $menu2->command
      (
       -label => $icodebase,
       -command => sub {
	 $self->AddContainingProject
	   (
	    ProjectName => $icodebase,
	   );
       },
      );
  }
  my $menu3 = $menu1->cascade
    (
     -label => 'Minor Codebases',
     -tearoff => 0,
    );
  my $icodebases3 = $self->ListProjects(ProjectType => "minor codebases");
  foreach my $mcodebase (@$icodebases3) {
    $menu3->command
      (
       -label => $mcodebase,
       -command => sub {
	 $self->AddContainingProject
	   (
	    ProjectName => $mcodebase,
	   );
       },
      );
  }
  $self->MyMenu($menu);

  # go ahead and load the information

  my $bottomframe = $self->Top1->Frame();

  my $valuesframe = $bottomframe->Frame();
  my $addcontainingprojectbutton = $valuesframe->Button
    (
     -text => "Add Containing Project",
     -command => sub {
       $self->ShowMenu();
     },
    )->pack(-side => 'left');
  $self->MyButton($addcontainingprojectbutton);

  my $text = $valuesframe->Text
    (
     -relief       => 'sunken',
     -borderwidth  => 2,
     -width        => 25,
     -height        => 10,
    )->pack();
  $self->MyText($text);
  $valuesframe->pack();

  $self->MyProjects({});

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
  return;
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

sub ShowMenu {
  my ($self,%args) = @_;
  $self->MyMenu->post($self->MyButton->rootx,$self->MyButton->rooty);
}

sub ListProjects {
  my ($self,%args) = @_;
  my $qdir = shell_quote(Dir($args{ProjectType}));
  my @projects;
  foreach my $file (split /\n/, `ls -1 $qdir`) {
    push @projects, $file;
  }
  return \@projects;
}

sub AddContainingProject {
  my ($self,%args) = @_;
  $self->MyProjects->{$args{ProjectName}} = 1;
  $self->MyText->Contents(join("\n",sort keys %{$self->MyProjects}));
}

1;
