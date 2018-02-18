package SPSE2::GUI::Tab::AllTasks;

use Manager::Dialog qw(Approve ApproveCommands QueryUser);
use PerlLib::SwissArmyKnife;

use Class::ISA;
use GraphViz;
use Text::Wrap;
use Tk;
use Tk::GraphViz;

use base qw(SPSE2::GUI::Tab);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow MyFrame MyGraphViz MyTkGraphViz Edges Count
	Colors Entries Text H L LastScale MyMenu LastEvent LastTags
	InitialScale SkipCanvasBind /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyFrame($args{Frame});
  $UNIVERSAL::managerdialogtkwindow = $UNIVERSAL::spse2->MyGUI->MyMainWindow;
  $self->MyFrame->pack(-expand => 1, -fill => 'both');
  $self->InitialScale(125.0);
  $self->LastScale($self->InitialScale);
  $self->MyTkGraphViz({});
  $self->MyTkGraphViz->{MainWindow} = $self->MyFrame; # $UNIVERSAL::spse2->MyMainWindow;
  $self->MyTkGraphViz->{Scrolled} = $self->MyTkGraphViz->{MainWindow}->Scrolled
    (
     'GraphViz',
     -background => 'white',
     -scrollbars => 'sw',
    )->pack(-expand => '1', -fill => 'both' );
  $self->Count(0);
  $Text::Wrap::columns = 40;
  $self->MyGraphViz
    (GraphViz->new
     (
      directed => 1,
      rankdir => 'LR',
      node => {
	       shape => 'box',
	      },
     ));
  $self->Text({});
  $self->H({});
  $self->L({});

  $self->MyMenu({});
  $self->MyMenu->{Node} = $self->MyTkGraphViz->{MainWindow}->Menu(-tearoff => 0);
  $self->MyMenu->{Blank} = $self->MyTkGraphViz->{MainWindow}->Menu(-tearoff => 0);

  # Node

  $self->MyMenu->{Node}->add('command', -label => 'Dismiss Menu', -command => sub {});
  $self->MyMenu->{Node}->add
    (
     'command',
     -label => 'Mark Task as Complete',
     -command => sub {
       my %args = @{$self->LastTags};
       my $node = $args{node};
       if ($node =~ /^node(\d+)$/) {
	 my $id = $1;
	 $self->MyGraphViz->{NODES}->{$id}->{fillcolor} = "blue";
	 my $ref = ref $self->MyTkGraphViz->{Scrolled};
	 print Dumper(Class::ISA::super_path($ref));
	 $self->RestoreZoom();
       }
     },
    );

  $self->MyMenu->{Node}->add('command', -label => 'Cancel Task', -command => sub {});
  $self->MyMenu->{Node}->add('command', -label => 'Hide Node', -command => sub {});
  $self->MyMenu->{Node}->add('command', -label => 'Similarity Search', -command => sub {});
  $self->MyMenu->{Node}->add('command', -label => 'Explain Holdup', -command => sub {});
  $self->MyMenu->{Node}->add('command', -label => 'Add Subtasks', -command => sub {});
  $self->MyMenu->{Node}->add('command', -label => 'Dispute Task', -command => sub {});

  # Blank

  $self->MyMenu->{Blank}->add('command', -label => 'Dismiss Menu', -command => sub {});
  $self->MyMenu->{Blank}->add
    (
     'command',
     -label => 'Find Or Create Task',
     -command => sub {
       my %args = @{$self->LastTags};
       print Dumper(\%args);
       $self->FindOrCreateTask
	 (

	 );
     },
    );

  $self->Colors
    ({
      "Tk::GraphViz" => {
			 "depends" => "red",
			 "provides" => "blue",
			 "eases" => "green",
			},
     });
  $self->SkipCanvasBind(0);
}

sub Execute {
  my ($self,%args) = @_;
  $self->AddNode
    (
     EN => "Hey",
     FullEntry => "Hey there",
    );
  $self->Display();
  $self->MyTkGraphViz->{Scrolled}->zoom(-in => $self->LastScale);
  $self->MyTkGraphViz->{Scrolled}->repeat(1, sub {$self->Check()});
}

sub Display {
  my ($self,%args) = @_;
  my $instrumentationframe = $self->MyTkGraphViz->{MainWindow}->Frame;
  my $entryText = '';
  my $entry = $instrumentationframe->Entry
    (
     -width => 80,
     -textvariable => \$entryText,
    )->pack
      (
       -side => 'bottom',
       -expand => '1',
       -fill => 'x',
       -pady => 2,
      );
  $self->MyTkGraphViz->{Scale} = $instrumentationframe->Scale
    (
     -orient => "horizontal",
     -from => 50,
     -to => 500,
    )->pack
      (
       -side => "right",
       -fill => 'none',
       -expand => 1,
      );
  $self->MyTkGraphViz->{Scale}->set($self->InitialScale);
  $instrumentationframe->pack
    (
     -side => 'bottom',
     -fill => 'x',
     -expand => 0,
    );


  $self->MyTkGraphViz->{Scrolled}->show( $self->MyGraphViz );
  $self->MyTkGraphViz->{Scrolled}->createBindings();
  $self->MyTkGraphViz->{Scrolled}->bind
    (
     'all',
     '<3>',
     sub {
       $self->SkipCanvasBind(1);
       $self->LastTags([$self->MyTkGraphViz->{Scrolled}->gettags('current')]);
       pop @{$self->LastTags};
       $self->ShowMenu
	 (
	  Items => \@_,
	  Type => "Node",
	 );
     },
    );

  $self->MyTkGraphViz->{Scrolled}->CanvasBind
    (
     '<Button-3>',
     sub {
       if ($self->SkipCanvasBind) {
	 $self->SkipCanvasBind(0);
	 return;
       }
       $self->LastTags([$self->MyTkGraphViz->{Scrolled}->gettags('current')]);
       pop @{$self->LastTags};
       $self->ShowMenu
	 (
	  Items => \@_,
	  Type => "Blank",
	 );
     },
    );
}

sub AddNode {
  my ($self,%args) = @_;
  my $size = 25;
  my $label = substr($args{EN},0,$size);
  $self->Text->{$label} = myformat($args{FullEntry});
  $self->Count($self->Count + 1);
  $self->H->{$label} = $self->Count;
  $self->MyGraphViz->add_node
    (
     $self->H->{$label},
     label => $self->Text->{$label},
     style => 'filled',
     color => 'black',
     fillcolor => 'lightgray',
    );
}

sub AddEdge {
  my ($self,%args) = @_;
  my $entryname1 = $args{EN1};
  my $entryname2 = $args{EN2};
  my $size = 25;
  my $label1 = substr($entryname1,0,$size);
  my $label2 = substr($entryname2,0,$size);
  # $self->L->{$label1}->{$label2} = 1;
  $self->MyGraphViz->add_edge
    (
     $self->H->{$label1} => $self->H->{$label2},
     label => $args{Pred},
     color => $self->Colors->{"GraphViz"}->{$args{Pred}},
    );
}

sub Check {
  my ($self,%args) = @_;
  my $scale = $self->MyTkGraphViz->{Scale}->get();
  if ($self->LastScale != $scale) {
    my $adjustment = $scale / $self->LastScale;
    $self->LastScale($scale);
    print Dumper({
		  Scale =>  $scale,
		  Adjustment => $adjustment,
		 }) if 0;
    $self->MyTkGraphViz->{Scrolled}->zoom(-in => $adjustment);
  }
}

sub ShowMenu {
  my ($self,%args) = @_;
  my $w = shift @{$args{Items}};
  my $Ev = $w->XEvent;
  $self->LastEvent($Ev);
  $self->MyMenu->{$args{Type}}->post($Ev->X, $Ev->Y);
}

sub myformat {
  my $text = shift;
  $text =~ s/-/ /g;
  $text = wrap('', '', $text);
  $text =~ s/\n/\\n/g;
  return $text;
}

sub FindOrCreateTask {
  my ($self,%args) = @_;
  print Dumper(\%args);
  my $task = QueryUser("Task Name?");
  $self->AddNode
    (
     EN => $task,
     FullEntry => $task,
    );
  $self->MyTkGraphViz->{Scrolled}->show
    (
     $self->MyGraphViz
    );
  $self->RestoreZoom();
}

sub RestoreZoom {
  my ($self,%args) = @_;
  $self->FitGraph();
}

sub FitGraph {
  my ($self,%args) = @_;
  $self->MyTkGraphViz->{Scrolled}->fit();
  $self->MyTkGraphViz->{Scrolled}->zoom(-out => 1.5);
}

sub SaveData {
  my ($self,%args) = @_;
  if (Approve("Save Existing Data?")) {
    print "Saving not yet implemented\n";
  }
}

sub LoadData {
  my ($self,%args) = @_;
  if (Approve("Replace Existing Data?")) {
    print "Loading not yet implemented\n";
  }
}

1;
