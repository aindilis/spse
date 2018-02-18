package SPSE2::GUI::Tab::View2::Domain::Planning::Control::Menus;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMenu Menus Functions MyView Debug MyInfo MyDomainMenus
   MyDomain MyGUI /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyDomain($args{Domain});
  $self->MyGUI($args{GUI});
  $self->Debug($args{Debug});
  $self->MyView($args{View2});
  $self->MyInfo($self->MyView->MyInfo);
  # $self->MyMenu({});
  # $self->MyMenu->{Node} = $args{MainWindow}->Menu(-tearoff => 0);
  # $self->MyMenu->{Blank} = $args{MainWindow}->Menu(-tearoff => 0);
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

  # we are going to add to the various components of the menu

  $self->Functions
    ({
      "New Goal" => sub {
	$self->MyView->FindOrCreateNode();
      },
      "Help For Goal" => sub {
	$self->MyDomain->Control->ActionHelpForGoal();
      },
      "Hide" => sub {
	$self->MyDomain->Control->ActionHide();
      },
      "Move to Different Planning Domain" => sub {
	$self->MyDomain->Control->ActionMoveToDifferentPlanningDomain();
      },
      "Do Action For Goal" => sub {
	$self->MyDomain->Control->ActionDoActionForGoal(@_);
      },
      "Add" => sub {},
      "Agenda Editor" => sub {},
      "Due Date" => sub {},
      "Duration" => sub {},
      "Edit" => sub {
	$self->MyView->EditNode(@_);
      },
      "Edit Due Date" => sub {},
      "Generate" => sub {},
      "Goal" => sub {},
      "Goal Menu" => sub {},
      "Similar Goals" => sub {},
      "Remove Node" => sub {
	$self->MyView->RemoveNode(@_);
      },
      "Remove Selected" => sub {
	$self->MyView->RemoveSelectedNodes();
      },
      "Incomplete" => sub {},
      "LPG" => sub {},
      "Plan" => sub {},
      "Planner" => sub {},
      "Query Completed" => sub {},
      "Quick" => sub {},
      "Remit" => sub {},
      # "Remove" => sub {},
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
      "Completed" => sub {
	$self->MyView->ModifyUnaryRelation
	  (
	   Predicate => "completed",
	   Value => "True",
	  );
      },


     });

  foreach my $time ("10 minutes","1 day","1 hour","1 month","1 week","30 minutes","3 days","3 hours","9 hours") {
    $self->Functions->{$time} = sub {
      $self->MyView->FindOrCreateNode
	(
	 Due => $time,
	);
    };
  }
  $self->MyDomainMenus
    ({
      Quick => [
		"Completed", [],
	       ],
      Actions => [
		  "Help For Goal", [],
		  "Do Action For Goal", [],
		  "Edit", [],
		  "Create", $createbinary,
		  "Similar Goals", [],
		  "Groups", [],
		  "Move to Different Planning Domain", [],
		  "Hide", [],
		  "Remove Node", [],
		  "Remove Selected", [],
		 ],
      Relations => [
		    "Unary", $unary,
		    "Binary", $binary,
		   ],
      Fields => [
		 "Costs", [],
		 "Dispute", [],
		 "Comment", [],
		 "Describe Solution", [],
		 "Has Feeling", [],
		 "Assigned By", [],
		 "Assigned To", [],
		 "Belongs to System", [],
		],
      Functions => $self->Functions,
     });
}

sub PopulateMenus {
  my ($self,%args) = @_;
  my $menu_file = $self->MyGUI->DomainMenus->{menu_file_domainmenu}->cascade
    (
     -label => 'Planning',
     -tearoff => 0,
    );
  $menu_file->command
    (
     -label => 'Import .do File',
     -command => sub {
       $self->MyDomain->Model->LoadDotDoFile();
     },
     -underline => 0,
    );
  ############################################################
  my $menu_select = $self->MyGUI->DomainMenus->{menu_select_domainmenu}->cascade
    (
     -label => 'Planning',
     -tearoff => 0,
    );
  foreach my $action ("All","None","Invert","By Search","By Regex","By Entailment") {
    $menu_select->command
      (
       -label => $action,
       -command => sub {
	 $self->MyDomain->Model->Select
	   (Selection => $action);
       },
      );
  }
  ############################################################
  my $menu_action = $self->MyGUI->DomainMenus->{menu_action_domainmenu}->cascade
    (
     -label => 'Planning',
     -tearoff => 0,
    );
  my $generatemenu = $menu_action->cascade
    (
     -label => 'Generate Plan',
     -tearoff => 0,
    );
  foreach my $method ("Selected","Very Important","Important","Unimportant","Wishlist","All") {
    $generatemenu->command
      (
       -label => $method,
       -command => sub {
	 $self->MyDomain->Control->ActionGeneratePlan
	   (
	    Method => $method,
	   );
     },
     -underline => 0,
    );
  }
  my $syncmenu = $menu_action->cascade
    (
     -label => 'Sync',
     -tearoff => 0,
    );
  $syncmenu->command
    (
     -label => 'Calendar',
     -command => sub {
       $self->MyDomain->Control->ActionSyncCalendar();
     },
     -underline => 0,
    );
  $syncmenu->command
    (
     -label => 'Finance',
     -command => sub {
       $self->MyDomain->Control->ActionSyncFinance();
     },
     -underline => 0,
    );

  $menu_action->command
    (
     -label => 'Agenda Editor',
     -command => sub {
       $self->MyDomain->Model->AgendaEditor();
     },
     -underline => 0,
    );
  $menu_action->command
    (
     -label => 'Query Completed',
     -command => sub {
       $self->MyDomain->Model->QueryCompleted();
     },
     -underline => 0,
    );

  my $contextmenu = $menu_action->cascade
    (
     -label => 'Context',
     -tearoff => 0,
    );
  $contextmenu->command
    (
     -label => "Edit",
     -command => sub {
       $self->MyDomain->Model->EditContext();
     },
    );
  $contextmenu->command
    (
     -label => "Check Consistency",
     -command => sub {
       $self->MyDomain->Model->CheckContextConsistency();
     },
    );
  $contextmenu->command
    (
     -label => "Clean Up",
     -command => sub {
       $self->MyDomain->Model->CleanUpContext();
     },
    );

  $menu_action->pack
    (
     -side => 'left',
    );

  ############################################################
  my $menu_analysis = $self->MyGUI->DomainMenus->{menu_analysis_domainmenu}->cascade
    (
     -label => 'Planning',
     -tearoff => 0,
    );

  $menu_analysis->command
    (
     -label => 'Ripe Goals',
     -command => sub {

     },
     -underline => 0,
    );
  $menu_analysis->command
    (
     -label => 'Goal Importance',
     -command => sub {

     },
     -underline => 0,
    );
  $menu_analysis->command
    (
     -label => 'Redundant Transitive Relations',
     -command => sub {

     },
     -underline => 0,
    );
  $menu_analysis->pack
    (
     -side => 'left',
    );
}

1;

#        "Create",
#        [
# 	"New Goal", [],
#        ],
#        "Quick",
#        [
# 	"Goal",
# 	[
# 	 "10 minutes", [],
# 	 "30 minutes", [],
# 	 "1 hour", [],
# 	 "3 hours", [],
# 	 "9 hours", [],
# 	 "1 day", [],
# 	 "3 days", [],
# 	 "1 week", [],
# 	 "1 month", [],
# 	 "completed", [],
# 	],
#        ],
#        "Selection",
#        [
# 	"All", [],
# 	"None", [],
# 	"Invert", [],
# 	"By Search", [],
# 	"By Regex", [],
# 	"By Entailment", [],
#        ],

  #        "Temporal Constraints",
  #        [
  # 	"Due Date",
  # 	[
  # 	 "Set", [],
  # 	 "Remove", [],
  # 	 "Set Start Date", [],
  # 	 "Set End Date", [],
  # 	 "Set Hard Deadline", [],
  # 	 "Set Due Date From Calendar", [],
  # 	 "Edit Due Date", [],
  # 	 "Set Due Date Duration", [],
  # 	],
  #        "Remit",
  #        [
  # 	"10 minutes", [],
  # 	"30 minutes", [],
  # 	"1 hour", [],
  # 	"3 hours", [],
  # 	"9 hours", [],
  # 	"1 day", [],
  # 	"3 days", [],
  # 	"1 week", [],
  # 	"1 month", [],
  #        ],
  #        "Duration",
  #        [
  # 	"Add", [],
  # 	"Clear", [],
  # 	"View", [],
  # 	"Set Event Duration", [],
  #        ],
