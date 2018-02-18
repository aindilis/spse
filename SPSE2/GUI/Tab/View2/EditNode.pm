package SPSE2::GUI::Tab::View2::EditNode;

# Manager::Dialog

use PerlLib::EasyPersist;
use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View2::EditNode::ComputationalSemantics;
use SPSE2::GUI::Tab::View2::EditNode::DateTime;
use SPSE2::GUI::Tab::View2::EditNode::Finance;
use SPSE2::GUI::Tab::View2::EditNode::Projects;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Top1 Verbose Data Fields MyView Rel DelayedActions /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyView($args{View});
  $self->Verbose($args{Verbose} || 0);
  my $title;
  if (exists $args{Node}) {
    my $node = $args{Node};
    # print SeeDumper($node);
    $self->Data({});
    $self->Data->{EntryID} = $node->EntryID;
    $self->Rel(["entry-fn","pse",$self->Data->{EntryID}]);

    # $UNIVERSAL::OKIEDOKIE = 1;
    my $nodeassertions;
    my $assertions = $self->MyView->GetAllReferringAssertions
      (
       Node => $self->Rel,
      );
    my $res2 = $UNIVERSAL::spse2->MyResources->MyImportExport->Convert
      (
       Input => $assertions,
       InputType => "Interlingua",
       OutputType => "Emacs String",
      );
    $nodeassertions = $res2->{Output};
    $self->Data->{"All Asserted Knowledge"} = $nodeassertions;


    $self->Data->{Source} = $node->Source;
    $self->Data->{Description} = $node->Description;
    print SeeDumper({Description =>     $self->Data->{Description}});
    $self->Data->{Severity} = $node->Severity;

    $title = "Edit Node";
  } else {
    $title = "New Node";
    $self->Data
      ($args{Data} ||
       {
	Type => "goal",
	Source => "pse",
	EntryID => undef,
	Description => "",
       });
  }
  $self->DelayedActions([]);
  $self->Top1
    ($args{MainWindow}->Toplevel
     (
      -title => $title,
      -height => 600,
      -width => 800,
     ));

  # might make more sense just to sql or iterate over the KB here
  # rather than query all of these?  then again, hrm, editable versus
  # consequential?

  my $term = [];
  my $queries =
    [
     # BINARY RELATIONS

     #  cross-term
     ["depends", $term, \*{'::?Term'}],
     ["eases", $term, \*{'::?Term'}],
     ["provides", $term, \*{'::?Term'}],
     ["prefer", $term, \*{'::?Term'}],

     ["depends", \*{'::?Term'}, $term],
     ["eases", \*{'::?Term'}, $term],
     ["provides", \*{'::?Term'}, $term],
     ["prefer", \*{'::?Term'}, $term],

     #  other
     ["has-NL", $term, \*{'::?NatLang'}],
     ["pse-has-property", $term, \*{'::?Property'}],
     ["due-date-for-entry", $term, \*{'::?DueDate'}],
     ["start-date", $term, \*{'::?StartDate'}],
     ["end-date", $term, \*{'::?EndDate'}],
     ["event-duration", $term, \*{'::?EventDuration'}],

     #  fields
     ["costs", $term, \*{'::?Cost'}],
     ["earns", $term, \*{'::?Cost'}],
     ["disputed", $term, \*{'::?Dispute'}],
     ["comment", $term, \*{'::?Cost'}],
     ["solution", $term, \*{'::?Solution'}],
     ["has-feeling", $term, \*{'::?Feeling'}],
     ["assigned-by", $term, \*{'::?AssignedBy'}],
     ["assigned-to", $term, \*{'::?AssignedTo'}],
     ["belongs-to-system", $term, \*{'::?System'}],

     # UNARY RELATIONS
     ["node", $term],

     # editable
     ["showstopper", $term],
     ["completed", $term],
     ["deleted", $term],
     ["cancelled", $term],
     ["ridiculous", $term],
     ["obsoleted", $term],
     ["rejected", $term],
     ["skipped", $term],
     ["shoppinglist", $term],
    ];

  # when you do what you need to do when it needs to be done, then you can do what you want to do when you want to"

  my @order;
  if (exists $args{Node}) {
    @order = (
	       "Source",
	       "EntryID",
	       "Description",
	       "Temporal Constraints",
	       "Financial Constraints",
	       "Project Membership",
	       "Computational Semantics",
	       "Severity",
	       "Status",
	       "All Asserted Knowledge",
	       #	       "Relations",
	       # 	       "Dependencies",
	       # 	       "Predependencies",
	       # 	       "Eases",
	       # 	       "Blocking Issues",
	       # 	       "Labor Involved",
	      );
  } else {
    @order = (
	      "Type",
	      "Source",
	      "Description",
	     );
  }

  my $fields =
    {
     "Type" => {
		Description => "source from which this node came",
		Args => ["dropdown"],
		TextVar => $self->Data->{Type},
		Function => sub { },
		Options => ["goal","condition"],
	       },
     "Source" => {
		  Description => "source from which this node came",
		  Args => ["tinytext"],
		  TextVar => $self->Data->{Source},
		 },
     "EntryID" => {
		   Description => "the id for the entry within the source",
		   Args => ["tinytext"],
		   TextVar => $self->Data->{EntryID},
		  },
     "Description" => {
		       Description => "node description",
		       Args => ["text"],
		       TextVar => $self->Data->{Description},
		       Normal => (! exists $args{Node}),
		       TakeFocus => 1,
		      },
     "Temporal Constraints" => {
				Description => "timing considerations like due date, etc",
				Args => ["function"],
				Function => sub {
				  my $datetime = SPSE2::GUI::Tab::View2::EditNode::DateTime->new
				    (
				     MainWindow => $args{MainWindow},
				     EntryID => $self->Data->{EntryID},
				     MyView => $self->MyView,
				    );
				},
			       },
     "Financial Constraints" => {
				 Description => "financial considerations like costs, earns",
				 Args => ["function"],
				 Function => sub {
				   my $finance = SPSE2::GUI::Tab::View2::EditNode::Finance->new
				     (
				      MainWindow => $args{MainWindow},
				      EntryID => $self->Data->{EntryID},
				      MyView => $self->MyView,
				      Node => $args{Node},
				     );
				 },
				},
     "Project Membership" => {
			      Description => "which projects a node belongs to",
			      Args => ["function"],
			      Function => sub {
				my $projects = SPSE2::GUI::Tab::View2::EditNode::Projects->new
				  (
				   MainWindow => $args{MainWindow},
				   EntryID => $self->Data->{EntryID},
				   MyView => $self->MyView,
				   Node => $args{Node},
				  );
			      },
			     },
     "Computational Semantics" => {
				   Description => "interpretting the meaning of the goal",
				   Args => ["function"],
				   Function => sub {
				     my $datetime = SPSE2::GUI::Tab::View2::EditNode::ComputationalSemantics->new
				       (
					MainWindow => $args{MainWindow},
					EntryID => $self->Data->{EntryID},
					MyView => $self->MyView,
					Node => $args{Node},
				       );
				   },
				  },
     "Severity" => {
		    Description => "How important is the goal",
		    Args => ["dropdown"],
		    TextVar => $self->Data->{Severity},
		    Function => sub { $self->SetSeverity(Severity => ${$self->Fields->{Severity}->{TextVar}}) },
		    Options => ["very important","important","unimportant","wishlist"],
		   },
     "Status" => {
		  Description => "whether the node has been completed, etc",
		  Args => ["dropdown"],
		  TextVar => $self->Data->{Status},
		  Function => sub { $self->SetStatus(Status => ${$self->Fields->{Status}->{TextVar}}) },
		  Options => ["completed","ridiculous","cancelled"],
		 },
     "All Asserted Knowledge" => {
				  Description => "all the assertions that have been put forth about the text",
				  Args => ["text"],
				  TextVar => $self->Data->{"All Asserted Knowledge"},
				  # Normal => 0,
				  Size => [80,10],
				 },
     "Dependencies" => {
			Description => "nodes which this node depends upon for its completion",
			Args => ["array"],
		       },
     "Predependencies" => {
			   Description => "nodes which depend upon this node for their completion",
			   Args => ["array"],
			  },
     "Eases" => {
		 Description => "other nodes which this node makes easier or enables",
		 Args => ["array"],
		},
     "Blocking Issues" => {
			   Description => "critical reasons this node cannot currently be completed",
			   Args => ["array"],
			  },
     "Labor Involved" => {
			  Description => "the estimated amount of time and/or work required to complete this node",
			  Args => ["array"],
			 },
    };
  $self->Fields($fields);

  $options = $self->Top1->Frame();
  foreach my $field (@order) {
    if (! exists $fields->{$field}->{Args}) {
      $options->Checkbutton
	(
	 -text => $field,
	 -command => sub { },
	)->pack(-fill => "x");	# , -anchor => 'left');
    } else {
      my $frame = $options->Frame(-relief => 'raised', -borderwidth => 2);
      my @items;
      foreach my $arg2 (@{$fields->{$field}->{Args}}) {
	my $ref = ref $arg2;
	if ($ref eq "ARRAY") {
	  # skip for now
	  $options->Checkbutton
	    (
	     -text => $field,
	     -command => sub { },
	    )->pack(-fill => "x");
	} elsif ($ref eq "") {
	  my $state;
	  if ($fields->{$field}->{Normal}) {
	    $state = "normal";
	  } else {
	    $state = "disabled";
	  }
	  if ($arg2 eq "tinytext") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );
	    my $name = $frame2->Entry
	      (
	       -state => 'disabled',
	       -relief       => 'sunken',
	       -borderwidth  => 2,
	       -textvariable => \$fields->{$field}->{TextVar},
	       -width        => 25,
	      );
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } elsif ($arg2 eq "text") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => $state,
	      );
	    my $width = 80;
	    my $height = 5;
	    if (exists $fields->{$field}->{Size}) {
	      $width = $fields->{$field}->{Size}->[0];
	      $height = $fields->{$field}->{Size}->[1];
	    }
	    my $name = $frame2->Text
	      (
	       -relief       => 'sunken',
	       -borderwidth  => 2,
	       -width        =>  $width,
	       -height        => $height,
	      );
	    $name->Contents($fields->{$field}->{TextVar});
	    $name->configure(-state => $state);
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } elsif ($arg2 eq "function") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );
	    my $name = $frame2->Button
	      (
	       -text => $field,
	       -command => sub {$self->Fields->{$field}->{Function}->()},
	      );
	    $name->configure(-state => $state);
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	    if ($args{Attribute} eq $field) {
	      push @{$self->DelayedActions},
		sub {
		  $self->Fields->{$field}->{Function}->();
		};
	    }
	  } elsif ($arg2 eq "dropdown") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );

	    my $name = $frame2->BrowseEntry
	      (
	       -variable => \$fields->{$field}->{TextVar},
	       -width => $fields->{$field}->{Width} || 25,
	      )->pack;
	    $name->configure(-state => $state);
	    # Configure dropdown
	    $name->configure
	      (
	       # What to do when an entry is selected
	       -browsecmd => $self->Fields->{$field}->{Function},
	      );
	    $name->bind
	      (
	       '<Return>' => $self->Fields->{$field}->{Function},
	      );
	    foreach my $option (@{$self->Fields->{$field}->{Options}}) {
	      $name->insert('end',$option);
	    }
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    # $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } else {
	    # print SeeDumper({Huh => $arg2});
	  }
	}
      }
      my $checkbutton = $frame->Checkbutton
	(
	 -text => $field,
	 -command => sub {
	   foreach my $item (@items) {
	     if ($item->{name}->cget('-state') eq 'disabled') {
	       $item->{name}->configure(-state => "normal");
	       $item->{nameLabel}->configure(-state => "normal");
	     } else {
	       $item->{name}->configure(-state => "disabled");
	       $item->{nameLabel}->configure(-state => "disabled");
	     }
	   }
	 },
	);
      if ($fields->{$field}->{Normal}) {
	$checkbutton->{'Value'} = 1;
      } else {
	$checkbutton->{'Value'} = 0;
      }

      $checkbutton->pack(-fill => "x");
      foreach my $item (@items) {
	$item->{frame}->pack;
      }
      $frame->pack();
    }
  }
  $options->pack;

  $buttons = $self->Top1->Frame();
  if (exists $args{Node}) {
    $buttons->Button
      (
       -text => "Defaults",
       -command => sub {$self->ActionDefaults},
      )->pack(-side => "left");
    $buttons->Button
      (
       -text => "Apply",
       -command => sub {$self->ActionApply},
      )->pack(-side => "left");
    $buttons->Button
      (
       -text => "Save Configuration",
       -command => sub {$self->ActionSaveConfiguration},
      )->pack(-side => "left");
    $buttons->Button
      (
       -text => "Cancel",
       -command => sub { $self->ActionCancel(); },
      )->pack(-side => "right");
  } else {
    $buttons->Button
      (
       -text => "Create New Node",
       -command => sub {$self->FindOrCreateNode},
      )->pack(-side => "left");
    $buttons->Button
      (
       -text => "Cancel",
       -command => sub { $self->Top1->destroy; },
      )->pack(-side => "right");
  }
  $buttons->pack;
  $self->Top1->bind
    (
     "all",
     "<Escape>",
     sub {
       $self->ActionCancel();
     },
    );
}

sub ActionSaveConfiguration {
  my ($self,%args) = @_;
  # just print out the configuration for now
  # print SeeDumper($self->Fields);
}

sub ActionApply {
  my ($self,%args) = @_;
  # go ahead and update any changes to anything, currently
  # description, status, etc
  # use metadata to accomplish this, find out where that metadata is
  # for now just dump the new values

  my $predmap = {
		 "Description" => "has-NL",
		 "Severity" => "severity",
		};
  my $render = 0;
  foreach my $field (keys %$predmap) {
    my $value = $self->GetValueForField(Field => $field);
    if ($field eq "Description") {
      chomp $value;
    }
    print SeeDumper([$field,$value]);
    if (defined $value) {
      my $res = $self->MyView->MyMetadata->SetMetadata
	(
	 Predicate => $predmap->{$field},
	 Item => $self->Rel,
	 Value => $value,
	);
      $render = 1;
    }
  }
  if ($render) {
    # $self->MyView->Redraw();
    $self->MyView->RenderGraph();
  }
}

sub ActionDefaults {
  my ($self,%args) = @_;

}

sub Execute {
  my ($self,%args) = @_;
  foreach my $delayedaction (@{$self->DelayedActions}) {
    $delayedaction->();
  }
}

sub ExecuteCommand {
  my ($self,%args) = @_;
  # get all the options, and run them
  # print join(" ",@args)."\n";
  # iterate over all the frames contained here
  foreach my $child ($self->Top1->children) {
    print SeeDumper($child);
  }
}

sub FindOrCreateNode {
  my ($self,%args) = @_;
  # now we should have all the information in the fields, go ahead and
  # first create the node, then just do a "save changes" as you would
  # any other node.

  my $description = $self->Fields->{Description}->{Widget}->Contents;
  $description =~ s/\s+$//s;
  my $node = $self->MyView->DefaultDomain->Model->FindOrCreateNodeHelper
    (
     Description => $description,
     Type => $self->GetValueForField(Field => "Type"),
     Render => 1,
    );
  $self->ActionSaveConfiguration
    (
     Node => $node,
    );
  my $nodes = $self->MyView->MyNodeManager->GetNode
    (
     Description => $description,
    );
  $self->MyView->CenterCanvasWindowOnNode
    (
     Node => $nodes->[0],
    );
  $self->Top1->destroy;
}

sub ActionCancel {
  my ($self,%args) = @_;
  # check for changes

  # if there are changes, prompt to determine whether to really cancel
  # or not

  $self->Top1->destroy;
}

sub SetStatus {
  my ($self,%args) = @_;
}

sub SetSeverity {
  my ($self,%args) = @_;
}

sub GetValueForField {
  my ($self,%args) = @_;
  my $field = $args{Field};
  # we have to carefully figure out now which one it is, I guess we
  # can no longer use the heuristic that if it has a widget, then it
  # has a Contents.  how do you check for whether a given item has a
  # contents, let's just check the widget's class and if it is in a
  # class that uses it, like Tk::Entry, then just use that

  if (exists $self->Fields->{$field}->{Widget}) {
    my $class = ref $self->Fields->{$field}->{Widget};
    if ($class =~ /^Tk::(Text)$/) {
      return $self->Fields->{$field}->{Widget}->Contents;
    }
  }
  if (exists $self->Fields->{$field}->{TextVar}) {
    return $self->Fields->{$field}->{TextVar};
  }
}

1;
