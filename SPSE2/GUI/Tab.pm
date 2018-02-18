package SPSE2::GUI::Tab;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name MyTkWidget /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name} || "Random-Tab-".int(10000*rand()));
  $self->MyTkWidget($args{TkWidget} || "must create a new one");
}

sub Show {
  my ($self,%args) = @_;
}

sub Hide {
  my ($self,%args) = @_;
}

# sub DESTROY {
# }

1;
