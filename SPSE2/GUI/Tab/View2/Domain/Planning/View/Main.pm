package SPSE2::GUI::Tab::View2::Domain::Planning::View::Main;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyDomain MyView2 /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyDomain($args{Domain});
  $self->MyView2($args{View2});
}

1;


