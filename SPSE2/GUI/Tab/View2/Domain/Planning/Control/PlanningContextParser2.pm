package SPSE2::GUI::Tab::View2::Domain::Planning::Control::PlanningContextParser2;

# this is to be the version of PSEx that uses KBS2

use KBS2::Util;
use PerlLib::SwissArmyKnife;
use PerlLib::Util;
use Verber::Ext::PDDL::Problem;
use Verber::Ext::PDDL::Domain;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyDomain MyProblem Context Goals PSEx3Response PSEx3PlanResponse  /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Goals($args{Goals});
  $self->Context
    ($args{Context} || "Org::FRDCSA::Verber::PSEx2::Verber");
  $self->MyDomain
    (Verber::Ext::PDDL::Domain->new());
  $self->MyProblem
    (Verber::Ext::PDDL::Problem->new());
}

sub Generate {
  my ($self,%args) = @_;
  my $response = $UNIVERSAL::agent->QueryAgent
    (
     Receiver => "Verber",
     Data => {
	      Command => "plan",
	      Name => "psex3",
	      Context => $args{Context} || $self->Context,
	      Goals => $args{Goals} || $self->Goals,
	      NoPlan => 1,
	     },
    );
  my $capsule = $response->{Data}{World}{MyCapsule};
  my $domaincontents = read_file($capsule->{DomainFileFull});
  $self->MyDomain
    (Verber::Ext::PDDL::Domain->new
     (
      Contents => $domaincontents,
     ))->Parse;
  my $problemcontents = read_file($capsule->{ProblemFileFull});
  $self->MyProblem
    (Verber::Ext::PDDL::Problem->new
     (
      Contents => $problemcontents,
     ))->Parse;

  $self->PSEx3Response($response);
}

sub GeneratePlan {
  my ($self,$preference) = @_;
  my $response = $UNIVERSAL::agent->QueryAgent
    (
     Receiver => "Verber",
     Data => {
	      Command => "plan",
	      Name => "psex3",
	      Context => $args{Context} || $self->Context,
	      Goals => $args{Goals} || $self->Goals,
	     },
    );
  $self->PSEx3PlanResponse($response);
  my $world = $self->PSEx3PlanResponse->Data->{World};

  # we will want to take the world, and send it on to the IEM if it is
  # valid
  $UNIVERSAL::agent->SendContents
    (
     Receiver => "IEM2",
     Data => {
  	      World => $world,
  	      # Extra => {
  	      # 		EntryMap => $self->EntryMap,
  	      # 		Context => $self->Context,
  	      # 	       },
  	     },
    );
}

1;
