package SPSE2::GUI::Tab::TextBuffer;

use PerlLib::SwissArmyKnife;

use Tk;

use base qw(SPSE2::GUI::Tab);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyFrame MyMainWindow MyText Tabname /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMainWindow($args{MainWindow});
  # V3

  # Model
  $self->Tabname($args{Tabname});

  # View
  $self->MyFrame($args{Frame});

  $self->MyFrame->pack(-expand => 1, -fill => 'both');
  $self->MyText($self->MyFrame->Text()->pack());
}

sub Execute {
  my ($self,%args) = @_;
}

sub Display {
  my ($self,%args) = @_;
}

sub Generate {
  my ($self,%args) = @_;
}

sub Check {
  my ($self,%args) = @_;
}

sub ZoomIn {
  my ($self,%args) = @_;
}

sub ZoomOut {
  my ($self,%args) = @_;
}

sub Show {
  my ($self,%args) = @_;
}

sub Redraw {
  my ($self,%args) = @_;
}

sub Recenter {
  my ($self,%args) = @_;
}

sub Search {
  my ($self,%args) = @_;
}

sub ScrollDown {
  my ($self,%args) = @_;
}

sub ScrollUp {
  my ($self,%args) = @_;
}

sub ScrollRight {
  my ($self,%args) = @_;
}

sub ScrollLeft {
  my ($self,%args) = @_;
}

sub BeginningOfContextVertical {
  my ($self,%args) = @_;
}

sub EndOfContextVertical {
  my ($self,%args) = @_;
}

sub BeginningOfContextHorizontal {
  my ($self,%args) = @_;
}

sub EndOfContextHorizontal {
  my ($self,%args) = @_;
}

sub NarrowToRegion {
  my ($self,%args) = @_;
}

sub Widen {
  my ($self,%args) = @_;
}

sub MovePoint {
  my ($self,%args) = @_;
}

sub MoveToNextNodeVertical {
  my ($self,%args) = @_;
}

sub MoveToPreviousNodeVertical {
  my ($self,%args) = @_;
}

sub MoveToNextNodeHorizontal {
  my ($self,%args) = @_;
}

sub MoveToPreviousNodeHorizontal {
  my ($self,%args) = @_;
}

1;
