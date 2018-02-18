package SPSE2::GUI::Tab::View::Menus;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMenu Menus Functions MyView Debug MyInfo /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug});
  $self->MyView($args{View});
  $self->MyInfo($args{Info});
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
  if (0) {
    $createbinary =
      [
       "New Depends on", [],
       "New Precondition for", [],
       "New Eases", [],
       "New Eased by", [],
       "New Provides", [],
       "New Provided by", [],
       "New Prefer", [],
       "New Deferred to", [],
      ];
    $binary =
      [
       "Depends on", [@modes],
       "Precondition for", [@modes],
       "Eases", [@modes],
       "Eased by", [@modes],
       "Provides", [@modes],
       "Provided by", [@modes],
       "Prefer", [@modes],
       "Deferred to", [@modes],
      ];
    $unary =
      [
       "Showstopper", [@modes],
       "Completed", [@modes],
       "Deleted", [@modes],
       "Cancelled", [@modes],
       "Ridiculous", [@modes],
       "Obsoleted", [@modes],
       "Rejected", [@modes],
       "Skipped", [@modes],
      ];
  } else {
    foreach my $inversiblebinarypredicate (@{$self->MyInfo->InversibleBinaryPredicates}) {
      push @$createbinary, "New ".$self->MyInfo->GetEnglishGlossForPredicate(Predicate => $inversiblebinarypredicate), [];
      # push @$createbinary, "New ".$self->MyInfo->GetEnglishGlossForPredicateInverse(Predicate => $inversiblebinarypredicate), [];
      push @$binary, $self->MyInfo->GetEnglishGlossForPredicate(Predicate => $inversiblebinarypredicate), [@modes];
      push @$binary, $self->MyInfo->GetEnglishGlossForPredicateInverse(Predicate => $inversiblebinarypredicate), [@modes];
    }
    foreach my $unarypredicate (@{$self->MyInfo->UnaryPredicates}) {
      push @$unary, $self->MyInfo->GetEnglishGlossForPredicate(Predicate => $unarypredicate), [@modes];
    }
    print Dumper($unary);
  }

  $self->Menus
    ({
      Main =>
      [
       "File",
       [
	"Load Data", [],
	"Save Data", [],
       ],
       "View",
       [
	"Fit Graph", [],
       ],
       "Options",
       [
	"Planner",
	[
	 "LPG", [],
	],
       ],
       "Actions",
       [
	"Plan",
	[
	 "Generate",
	],
	"Query Completed", [],
	"Agenda Editor", [],
       ],
      ],
      Node =>
      [
       "Dismiss Menu", [],
       "Actions",
       [
	"Do Action For Goal", [],
	"Edit", [],
	"Create", $createbinary,
	"Similar Goals", [],
	"Groups", [],
	"Hide", [],
	"Remove", [],
       ],
       "Relations",
       [
	"Unary", $unary,
	"Binary", $binary,
       ],
       "Temporal Constraints",
       [
	"Due Date",
	[
	 "Set", [],
	 "Remove", [],
	 "Set Start Date", [],
	 "Set End Date", [],
	 "Set Hard Deadline", [],
	 "Set Due Date From Calendar", [],
	 "Edit Due Date", [],
	 "Set Due Date Duration", [],
	],
	"Remit",
	[
	 "10 minutes", [],
	 "30 minutes", [],
	 "1 hour", [],
	 "3 hours", [],
	 "9 hours", [],
	 "1 day", [],
	 "3 days", [],
	 "1 week", [],
	 "1 month", [],
	],
	"Duration",
	[
	 "Add", [],
	 "Clear", [],
	 "View", [],
	 "Set Event Duration", [],
	],
       ],

       "Fields",
       [
	"Costs", [],
	"Dispute", [],
	"Comment", [],
	"Describe Solution", [],
	"Has Feeling", [],
	"Assigned By", [],
	"Assigned To", [],
	"Belongs to System", [],
       ],
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
       "Create",
       [
	"New Goal", [],
       ],
       "Quick",
       [
	"Goal",
	[
	 "10 minutes", [],
	 "30 minutes", [],
	 "1 hour", [],
	 "3 hours", [],
	 "9 hours", [],
	 "1 day", [],
	 "3 days", [],
	 "1 week", [],
	 "1 month", [],
	 "completed", [],
	],
       ],
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
      "New Goal" => sub {$self->MyView->FindOrCreateGoal},
      "Do Action For Goal" => sub {},
      "Actions" => sub {},
      "Add" => sub {},
      "Agenda Editor" => sub {},
      "Blank Menu" => sub {},
      "Clear" => sub {},
      "Dismiss Menu" => sub {},
      "Due Date" => sub {},
      "Duration" => sub {},
      "Edit" => sub {
	$self->MyView->EditGoal(@_);
      },
      "Edit Due Date" => sub {},
      "Fields" => sub {},
      "File" => sub {},
      "Fit Graph" => sub {},
      "Flags" => sub {},
      "Generate" => sub {},
      "Goal" => sub {},
      "Goal Menu" => sub {},
      "Similar Goals" => sub {},
      "Hide" => sub {},
      "Remove" => sub {
	$self->MyView->RemoveGoal(@_);
      },
      "Incomplete" => sub {},
      "Load Data" => sub {},
      "LPG" => sub {},
      "Main Menu" => sub {},
      "Node" => sub {},
      "Options" => sub {},
      "Plan" => sub {},
      "Planner" => sub {},
      "Query Completed" => sub {},
      "Quick" => sub {},
      "Relations" => sub {},
      "Remit" => sub {},
      # "Remove" => sub {},
      "Save Data" => sub {},
      "Set" => sub {},
      "Set Due Date Duration" => sub {},
      "Set Due Date From Calendar" => sub {},
      "Set End Date" => sub {},
      "Set Event Duration" => sub {},
      "Set Hard Deadline" => sub {},
      "Set Start Date" => sub {},
      "Temporal Constraints" => sub {},
      "Uncancelled" => sub {},
      "Undeleted" => sub {},
      "View" => sub {},
     });
  foreach my $time ("10 minutes","1 day","1 hour","1 month","1 week","30 minutes","3 days","3 hours","9 hours") {
    $self->Functions->{$time} = sub {
      $self->MyView->FindOrCreateGoal
	(
	 Due => $time,
	);
    };
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
  # print Dumper($self->Functions);
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
	  print Dumper({NAME => $name}) if $self->Debug;
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
	  print Dumper({Newspec => $newspec}) if $self->Debug;
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
