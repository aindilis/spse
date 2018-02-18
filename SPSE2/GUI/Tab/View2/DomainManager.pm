package SPSE2::GUI::Tab::View2::DomainManager;

use Manager::Dialog qw(Message SubsetSelect);
use PerlLib::Collection;
use PerlLib::SwissArmyKnife;


use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyView2 ListOfDomains MyDomains DefaultDomainName /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyView2($args{View2});
  Message(Message => "Initializing domains...");
  my $dir = "/var/lib/myfrdcsa/codebases/minor/spse/SPSE2/GUI/Tab/View2/Domain";
  my @names = map {$_ =~ s/.pm$//; $_} grep(/\.pm$/,split /\n/,`ls $dir`);
  print SeeDumper(\@names);
  # my @names = qw(AptCache);
  $self->ListOfDomains(\@names);
  $self->MyDomains
    (PerlLib::Collection->new
     (Type => "SPSE2::GUI::Tab::View2::Domain"));
  $self->MyDomains->Contents({});
  foreach my $name (@{$self->ListOfDomains}) {
    my $module = "/var/lib/myfrdcsa/codebases/minor/spse/SPSE2/GUI/Tab/View2/Domain/$name.pm";
    if (-f $module) {
      Message(Message => "Initializing $module...");
      require "$dir/$name.pm";
      my $s = "SPSE2::GUI::Tab::View2::Domain::$name"->new(View2 => $self->MyView2);
      $self->MyDomains->Add
	($name => $s);
    }
  }
  $self->DefaultDomainName($self->ListOfDomains->[0]);
}

sub SetContext {
  my ($self,%args) = @_;
  foreach my $domain ($self->MyDomains->Values) {
    $domain->Model->SetContext(Context => $args{Context});
  }
}

sub AddGlobalMenuItems {
  my ($self,%args) = @_;
}

sub AddContextMenuItems {
  my ($self,%args) = @_;
}

sub AddInfoItems {
  my ($self,%args) = @_;
}

sub Generate  {
  my ($self,%args) = @_;
  foreach my $domain ($self->MyDomains->Values) {
    $domain->Model->Generate();
  }
  $self->ProcessAssertions
    (Assertions => $args{Assertions});
}

sub ProcessAssertions {
  my ($self,%args) = @_;
  foreach my $domain ($self->MyDomains->Values) {
    $domain->ProcessAssertions
      (Assertions => $args{Assertions});
  }
}

1;
