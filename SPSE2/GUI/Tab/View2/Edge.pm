package SPSE2::GUI::Tab::View2::Edge;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / DisplayData Node1 Node2 Hidden /

  ];

sub init {
  my ($self,%args) = @_;
  $self->DisplayData({});
  $self->Node1($args{Node1});
  $self->Node2($args{Node2});
}

sub IsHidden {
  my ($self,%args) = @_;
  return $self->Hidden || $self->Node1->IsHidden || $self->Node2->IsHidden;
}

1;
