package SPSE2::GUI::Tab::AllTasks;

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
	Colors Entries Text H L LastScale MyMenu LastEvent LastTags /


  ];

sub init {
  my ($self,%args) = @_;
  $self->MyFrame($args{Frame});

  $self->LastScale(2500.0);
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

  $self->MyMenu
    ($self->MyTkGraphViz->{MainWindow}->Menu());

  $self->MyMenu->add('command', -label => 'Dismiss Menu', -command => sub {});
  $self->MyMenu->add
    (
     'command',
     -label => 'Mark Task as Complete',
     -command => sub {
       my %args = @{$self->LastTags};
       my $node = $args{node};
       if ($node =~ /^node(\d+)$/) {
	 my $id = $1;
	 $self->MyGraphViz->{NODES}->{$id}->{fillcolor} = "darkgray";
	 my $ref = ref $self->MyTkGraphViz->{Scrolled};
	 print Dumper(Class::ISA::super_path($ref));
	 $self->MyTkGraphViz->{Scrolled}->show( $self->MyGraphViz );
	 # $self->MyTkGraphViz->{Scrolled}->zoom(-in => $self->LastScale);
       }
     },
    );
  $self->MyMenu->add('command', -label => 'Cancel Task', -command => sub {});
  $self->MyMenu->add('command', -label => 'Hide Node', -command => sub {});
  $self->MyMenu->add('command', -label => 'Similarity Search', -command => sub {});
  $self->MyMenu->add('command', -label => 'Explain Holdup', -command => sub {});
  $self->MyMenu->add('command', -label => 'Add Subtasks', -command => sub {});
  $self->MyMenu->add('command', -label => 'Dispute Task', -command => sub {});

  $self->Colors
    ({
      "Tk::GraphViz" => {
			 "depends" => "red",
			 "provides" => "blue",
			 "eases" => "green",
			},
     });
  $self->MyFrame->pack();
}

sub Execute {
  my ($self,%args) = @_;
  $self->Display();
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

sub Display {
  my ($self,%args) = @_;
  $self->MyMainLoop();
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
     -from => 0,
     -to => 5000,
    )->pack(-side => "right");
  $self->MyTkGraphViz->{Scale}->set(2500.0);
  $instrumentationframe->pack
    (
     -side => 'bottom',
     -fill => 'none',
     -expand => 0,
    );

  $self->MyTkGraphViz->{Scrolled}->show( $self->MyGraphViz );
  $self->MyTkGraphViz->{Scrolled}->zoom(-in => $self->LastScale);
  $self->MyTkGraphViz->{Scrolled}->createBindings();
  $self->MyTkGraphViz->{Scrolled}->bind
    (
     'all',
     '<3>',
     sub {
       $self->LastTags([$self->MyTkGraphViz->{Scrolled}->gettags('current')]);
       pop @{$self->LastTags};
       $self->ShowMenu(@_);
     },
    );
  $self->MyMainLoop();
}

sub MyMainLoop {
  my ($self,%args) = @_;
  $self->MyTkGraphViz->{Scrolled}->repeat(1, sub {$self->Check()});
  MainLoop();
}

sub Check {
  my ($self,%args) = @_;
  return;
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
  my ($self,@items) = @_;
  my $w = shift @items;
  my $Ev = $w->XEvent;
  $self->LastEvent($Ev);
  $self->MyMenu->post($Ev->X, $Ev->Y);
}

sub myformat {
  my $text = shift;
  $text =~ s/-/ /g;
  $text = wrap('', '', $text);
  $text =~ s/\n/\\n/g;
  return $text;
}

1;
