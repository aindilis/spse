package SPSE2::Resources;

use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;
use Verber::Util::DateManip;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyImportExport MyDateManip /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyImportExport
    (KBS2::ImportExport->new);
  $self->MyDateManip
    (Verber::Util::DateManip->new);
}

sub Execute {
  my ($self,%args) = @_;

}

1;


