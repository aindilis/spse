package SPSE2::GUI::Tab::Empty;

use PerlLib::SwissArmyKnife;

use base qw(SPSE2::GUI::Tab);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyFrame /


  ];

sub init {
  my ($self,%args) = @_;
  $self->MyFrame($args{Frame});
  $self->MyFrame->Label
    (
     -text => "hello",
    )->pack();
  $self->MyFrame->pack();
}

sub Execute {
  my ($self,%args) = @_;

}

1;



