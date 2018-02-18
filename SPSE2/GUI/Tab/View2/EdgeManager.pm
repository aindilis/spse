package SPSE2::GUI::Tab::View2::EdgeManager;

use PerlLib::Collection;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Edges Data MyView SelectionOrder /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Edges
    (PerlLib::Collection->new
     (Type => "SPSE2::GUI::Tab::View2::Edge"));
  $self->Edges->Contents({});
}

sub AddEdge {
  my ($self,%args) = @_;
  $self->Edges->AddAutoIncrement
    (
     Item => $args{Edge},
    );
}

sub GetEdge {
  my ($self,%args) = @_;
  if ($args{All}) {
    return [values %{$self->Edges->Contents}];
  }
}

1;
