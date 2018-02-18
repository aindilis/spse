package SPSE2::GUI::Tab::View2::Domain::Planning;

use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View2::Domain::Planning::Model::Main;
use SPSE2::GUI::Tab::View2::Domain::Planning::View::Main;
use SPSE2::GUI::Tab::View2::Domain::Planning::Control::Main;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name MyView2 Model View Control /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Name("Planning");
  $self->MyView2($args{View2});
  $self->Model
    (SPSE2::GUI::Tab::View2::Domain::Planning::Model::Main->new
     (
      View2 => $self->MyView2,
      Domain => $self,
     ));
  $self->View
    (SPSE2::GUI::Tab::View2::Domain::Planning::View::Main->new
     (
      View2 => $self->MyView2,
      Domain => $self,
     ));
  $self->Control
    (SPSE2::GUI::Tab::View2::Domain::Planning::Control::Main->new
     (
      View2 => $self->MyView2,
      Domain => $self,
     ));
}

sub ProcessAssertions {
  my ($self,%args) = @_;
  foreach my $assertion (@{$args{Assertions}}) {
    $self->Model->PreProcessAssertion
      (
       Assertion => $assertion,
       Render => $args{Render},
      );
  }
  foreach my $assertion (@{$args{Assertions}}) {
    $self->Model->ProcessAssertion
      (
       Assertion => $assertion,
       Render => $args{Render},
      );
  }
  $self->Model->ProcessAssertionRest();
}

1;
