package SPSE2::GUI::Tab::View2::Domain::Planning::Control::Main;

use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View2::Domain::Planning::Control::Menus;
use SPSE2::GUI::Tab::View2::Domain::Planning::Control::SyncCalendar;
use SPSE2::GUI::Tab::View2::Domain::Planning::Control::VerberGUI;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyDomain MyView2 MyGUI MyMenus MyDomainMenus /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyDomain($args{Domain});
  $self->MyView2($args{View2});
  $self->MyGUI($UNIVERSAL::spse2->MyGUI);
  $self->MyMenus
    (SPSE2::GUI::Tab::View2::Domain::Planning::Control::Menus->new
     (
      View2 => $self->MyView2,
      Domain => $self->MyDomain,
      GUI => $self->MyGUI,
     ));
  $self->MyMenus->PopulateMenus();
}

sub DomainMenus {
  my ($self,%args) = @_;
  return $self->MyMenus->DomainMenus;
}

sub ActionGeneratePlan {
  my ($self,%args) = @_;
  print "Generating plan using method: $args{Method}\n";
  my $verbergui = SPSE2::GUI::Tab::View2::Domain::Planning::Control::VerberGUI->new
    (
     Database => $self->MyView2->Database,
     View => $self->MyView2,
     Method => $args{Method},
    );
  $verbergui->Execute();
}

sub ActionSyncCalendar {
  my ($self,%args) = @_;
  my $calendargui = SPSE2::GUI::Tab::View2::Domain::Planning::Control::SyncCalendar->new
    (
     Database => $self->MyView2->Database,
     View => $self->MyView2,
    );
  $calendargui->Execute();
}

sub ActionDoActionForGoal {
  my ($self,%args) = @_;
  # figure out the current goal, and then run the software for do
  # action for goal, probably looking at
  my $node = $self->MyView2->GetNodeFromLastTags;
  my $command = "how-do-I ".shell_quote($node->Description);
  print "$command\n";
}

sub ActionHelpForGoal {
  my ($self,%args) = @_;
  # figure out the current goal, and then run the software for do
  # action for goal, probably looking at

  # get the goal contents, run the how-do-I program on the contents for
  # now
  my $node = $self->MyView2->GetNodeFromLastTags;
  my $command = "how-do-I ".shell_quote($node->Description);
  print "$command\n";
  system $command;
}

sub ActionHide {
  my ($self,%args) = @_;
  my $node = $self->MyView2->GetNodeFromLastTags;
  
}

sub ActionMoveToDifferentPlanningDomain {
  my ($self,%args) = @_;
  my $node = $self->MyView2->GetNodeFromLastTags;
  # have a domain selection mechanism
  
}

sub EditPointNode {
  my ($self,%args) = @_;
  # $args{Attribute};
  # $self->GetPointNode
  # edit this paritcular value, then update the model
}

1;
