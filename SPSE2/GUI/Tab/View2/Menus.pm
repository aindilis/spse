package SPSE2::GUI::Tab::View2::Menus;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMenu Menus Functions MyView Debug MyInfo MyDomainManager /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug});
  $self->MyView($args{View});
  $self->MyInfo($args{Info});
  $self->MyDomainManager($args{DomainManager});
  $self->MyMenu({});
  $self->MyMenu->{Node} = $args{MainWindow}->Menu(-tearoff => 0);
  $self->MyMenu->{Blank} = $args{MainWindow}->Menu(-tearoff => 0);
  # have a draggable selection for goals, along with shift, etc,
  # clicking to select, etc
  # have zoom be bound to a control and something
  # Node
  my @modes = ("True",[],"False",[],"Independent",[]);

  my $createbinary = [];
  my $binary = [];
  my $unary = [];
  foreach my $inversiblebinarypredicate (@{$self->MyInfo->InversibleBinaryPredicates}) {
    push @$createbinary, "New ".$self->MyInfo->GetEnglishGlossForPredicate(Predicate => $inversiblebinarypredicate), [];
    # push @$createbinary, "New ".$self->MyInfo->GetEnglishGlossForPredicateInverse(Predicate => $inversiblebinarypredicate), [];
    push @$binary, $self->MyInfo->GetEnglishGlossForPredicate(Predicate => $inversiblebinarypredicate), [@modes];
    push @$binary, $self->MyInfo->GetEnglishGlossForPredicateInverse(Predicate => $inversiblebinarypredicate), [@modes];
  }
  foreach my $unarypredicate (@{$self->MyInfo->UnaryPredicates}) {
    push @$unary, $self->MyInfo->GetEnglishGlossForPredicate(Predicate => $unarypredicate), [@modes];
  }
  # print SeeDumper($unary);

  my @actions;
  my @relations;
  my @fields;
  foreach my $domain ($self->MyDomainManager->MyDomains->Values) {
    push @quick, $domain->Name, $domain->Control->MyMenus->MyDomainMenus->{Quick};
    push @actions, $domain->Name, $domain->Control->MyMenus->MyDomainMenus->{Actions};
    push @relations, $domain->Name, $domain->Control->MyMenus->MyDomainMenus->{Relations};
    push @fields, $domain->Name, $domain->Control->MyMenus->MyDomainMenus->{Fields};
  }
  $self->Menus
    ({
      Node =>
      [
       "Dismiss Menu", [],
       "Quick", [@quick],
       "Actions", [@actions],
       "Relations", [@relations],
       "Fields", [@fields],
       "Selection",
       [
	"All", [],
	"None", [],
	"Invert", [],
	"By Search", [],
	"By Regex", [],
	"By Similarity", [],
	"By Entailment", [],
       ],
      ],
      Blank =>
      [
       "Dismiss Menu", [],
      ],
     });

  $self->Functions
    ({
      "All" => sub {
	$self->MyView->Select
	  (Selection => "All");
      },
      "None" => sub {
	$self->MyView->Select
	  (Selection => "None");
      },
      "Invert" => sub {
	$self->MyView->Select
	  (Selection => "Invert");
      },
      "By Search" => sub {
	$self->MyView->Search
	  (
	   Type => "Search",
	  );
      },
      "By Regex" => sub {
	$self->MyView->Search
	  (
	   Type => "Regex",
	  );
      },
      "By Similarity" => sub {
	$self->MyView->Search
	  (
	   Type => "Similarity",
	  );
      },
      "By Entailment" => sub {
	$self->MyView->Search
	  (
	   Type => "Entailment",
	  );
      },
      "Actions" => sub {},
      "Blank Menu" => sub {},
      "Clear" => sub {},
      "Dismiss Menu" => sub {},
      "Fields" => sub {},
      "File" => sub {},
      "Fit Graph" => sub {},
      "Flags" => sub {},
      "Hide" => sub {},
      "Load Data" => sub {},
      "Main Menu" => sub {},
      "Node" => sub {},
      "Options" => sub {},
      "Relations" => sub {},
      "Save Data" => sub {},
      "View" => sub {},
     });

  foreach my $domain ($self->MyDomainManager->MyDomains->Values) {
    foreach my $key (keys %{$domain->Control->MyMenus->MyDomainMenus->{Functions}}) {
      $self->Functions->{$key} = $domain->Control->MyMenus->MyDomainMenus->{Functions}->{$key};
    }
  }

  foreach my $inversiblebinaryrelation (@{$self->MyInfo->InversibleBinaryPredicates}) {
    my $gloss = $self->MyInfo->GetEnglishGlossForPredicate(Predicate => $inversiblebinaryrelation);
    my $glossinverse = $self->MyInfo->GetEnglishGlossForPredicateInverse(Predicate => $inversiblebinaryrelation);
    foreach my $value (qw(True False Independent)) {
      $self->Functions->{"$gloss|$value"} = sub {
	$self->MyView->ModifyBinaryRelation
	  (
	   Relation => $gloss,
	   Value => $value,
	  );
      };
      $self->Functions->{"$glossinverse|$value"} = sub {
	$self->MyView->ModifyBinaryRelation
	  (
	   Relation => $glossinverse,
	   Value => $value,
	  );
      };
      $self->Functions->{"New $gloss"} = sub {
	$self->MyView->FindOrCreateGoal
	  (
	   Relation => $gloss,
	  );
      };
      $self->Functions->{"New $glossinverse"} = sub {
	$self->MyView->FindOrCreateGoal
	  (
	   Relation => $glossinverse,
	  );
      };
    }
  }
  foreach my $unarypredicate (@{$self->MyInfo->UnaryPredicates}) {
    my $gloss = $self->MyInfo->GetEnglishGlossForPredicate(Predicate => $unarypredicate);
    foreach my $value (qw(True False Independent)) {
      $self->Functions->{"$gloss|$value"} = sub {
	$self->MyView->ModifyUnaryRelation
	  (
	   Predicate => $gloss,
	   Value => $value,
	  );
      };
    }
  }
  foreach my $field (@{$self->MyInfo->Fields}) {
    my $gloss = $self->MyInfo->GetEnglishGlossForPredicate(Predicate => $field);
    $self->Functions->{$gloss} = sub {
      $self->MyView->ModifyField
	(
	 Field => $gloss,
	);
    };
  }
}

sub LoadMenus {
  my ($self,%args) = @_;
  $self->AddMenus
    (
     Menu => $self->MyMenu->{Node},
     Spec => $self->Menus->{Node},
    );
  $self->AddMenus
    (
     Menu => $self->MyMenu->{Blank},
     Spec => $self->Menus->{Blank},
    );
}

sub AddMenus {
  my ($self,%args) = @_;
  my $spec = $args{Spec};
  my $ref = ref $spec;
  if ($ref eq "ARRAY") {
    while (scalar @$spec) {
      my $name = shift @$spec;
      my @genealogy;
      if (exists $args{Genealogy}) {
	push @genealogy, @{$args{Genealogy}};
      }
      push @genealogy, $name;
      my $newspec = shift @$spec;
      my $ref2 = ref $newspec;
      if ($ref2 eq "ARRAY") {
	if (! scalar @$newspec) {
	  # this is an empty menu item, so we should go ahead and
	  # look
	  print SeeDumper({NAME => $name}) if $self->Debug;
	  my $subroutine;
	  my @genealogycopy = @genealogy;
	  my $string;
	  while (scalar @genealogycopy and ! exists $self->Functions->{$string = join("|", @genealogycopy)}) {
	    shift @genealogycopy;
	    # print $string."\n";
	  }
	  if ($string ne "" and exists $self->Functions->{$string}) {
	    $args{Menu}->command
	      (
	       -label => $name,
	       -command => $self->Functions->{$string},
	      );
	  } else {
	    print "Error 1\n" if $self->Debug;
	  }
	} else {
	  print "<$name>\n" if $self->Debug;
	  my $newmenu = $args{Menu}->cascade
	    (
	     -label => $name,
	     -tearoff => 0,
	    );
	  print SeeDumper({Newspec => $newspec}) if $self->Debug;
	  $self->AddMenus
	    (
	     Genealogy => \@genealogy,
	     Menu => $newmenu,
	     Spec => $newspec,
	    );
	}
      } else {
	print "Error 2\n" if $self->Debug;
      }
    }
  } else {
    print "Error 3\n" if $self->Debug;
  }
}

1;
