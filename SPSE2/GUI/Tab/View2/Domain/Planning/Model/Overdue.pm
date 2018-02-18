package SPSE2::GUI::Tab::View2::Domain::Planning::Model::Overdue;

use Manager::Dialog qw(Approve);
use Verber::Util::DateManip;

use PerlLib::SwissArmyKnife;

# this is a system to identify what to do with due dates that are
# expired, whether to mark them as cancelled, skipped, postponed, etc.

use Tk;
use Tk::TableMatrix;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyView2 MyMainWindow TopLevel TableFrame Selectors /

  ];

sub init {
  my ($self,%args) = @_;
  # first we have to compute which ones are expired
  $self->MyView2($args{View2});
  $self->MyMainWindow($args{MainWindow});
  # first create a top1 side window here
}

sub Execute {
  my ($self,%args) = @_;
  $self->TopLevel
    ($self->MyMainWindow->Toplevel
     (
      -title => "Overdue: ".$self->MyView2->Context,
      -height => 600,
      -width => 1400,
     ));
  $self->TableFrame
    ($self->TopLevel->Frame());
  $self->TableFrame->pack
    (-fill => "both", -expand => 1);
}

sub RefreshDisplay {
  my ($self,%args) = @_;
  if (scalar $self->TableFrame->children) {
    $self->TableFrame->children->[0]->destroy;
  }
  my $res = $self->GetOverdueGoals;
  if ($res->{Success}) {
    # add a row
    # add a radio button for:
    my @keys = qw(Description Postpone RemoveTimeConstraints Completed Deleted Cancelled Ridiculous Obsoleted Rejected Skipped DoNothing );

    # create a button for postpone, with a drop down menu for the
    # number of minutes to postpone
    my $numberofrows = scalar @{$res->{Result}};

    my $table = $self->TableFrame->Scrolled
      (
       "TableMatrix",
       # -resizeborders => 'none',
       -titlerows => 1,
       -rows => ($numberofrows + 1),
       -colstretchmode => 'all',
       -cols => (scalar @keys),
       -cache => 1,
       -scrollbars => "osoe",
      );

    my $col2 = 0;
    foreach my $fieldname (@keys) {
      # $table->insertCols("$col2.0", 1);
      $table->set("0,$col2", $fieldname);
      ++$col2;
    }
    $table->colWidth(0, 60);
    my $row = 1;
    # sort by date first of all, not by number as if we use a limited format...  ID cannot be important
    my $selectors = {};
    $self->Selectors($selectors);
    foreach my $entry (@{$res->{Result}}) {
      my $goal = $entry->{Goal};

      my $goaldumper = $goal->NodeInterlinguaDumper;
      my $edt = $entry->{EDT};
      my $entry = {
		   Description => $goal->Description,
		   Postpone => "",
		   RemoveTimeConstraints => "radiobutton",
		   Completed => "radiobutton",
		   Deleted => "radiobutton",
		   Cancelled => "radiobutton",
		   Ridiculous => "radiobutton",
		   Obsoleted => "radiobutton",
		   Rejected => "radiobutton",
		   Skipped => "radiobutton",
		   DoNothing => "radiobutton",
		  };
      my $col3 = 0;
      my $selector1;
      my $selector2;
      $selectors->{$goaldumper}->{1} = \$selector1;
      $selectors->{$goaldumper}->{2} = \$selector2;
      foreach my $fieldname (@keys) {
	if ($fieldname eq "Postpone") {
	  my $browseentry = $table->BrowseEntry
	    (
	     -variable => $selectors->{$goaldumper}->{2},
	     -width => 25,
	     -browsecmd => sub {
	       ${$selectors->{$goaldumper}->{1}} = "";
	     },
	    )->pack(-side => 'right');
	  foreach my $option ("1 hour","3 hours","12 hours","1 day","3 days","1 week","1 month","3 months","1 year") {
	    $browseentry->insert('end',$option);
	  }
	  $table->windowConfigure
	    (
	     "$row,$col3",
	     -window => $browseentry,
	     -sticky => 'nsew',
	    );
	} elsif ($entry->{$fieldname} eq "radiobutton") {
	  my $radiobutton = $table->Radiobutton
	    (
	     -text => "",
	     -value => $fieldname,
	     -variable =>  $selectors->{$goaldumper}->{1},
	     -command => sub {
	       ${$selectors->{$goaldumper}->{2}} = "";
	     },
	    )->pack(-side => 'left');
	  $table->windowConfigure
	    (
	     "$row,$col3",
	     -window => $radiobutton,
	     -sticky => 'nsew',
	    );
	} else {
	  $table->set("$row,$col3", $entry->{$fieldname});
	}
	++$col3;
      }
      ++$row;
    }
    $table->pack
      (
       -expand => 1,
       -fill => 'both',
      );
  }
  my $buttonframe = $self->TopLevel->Frame();
  $buttonframe->Button
    (
     -text => "Close",
     -command => sub {
       if (Approve("Close Overdue Without Applying Changes?")) {
	 $self->TopLevel->destroy;
       }
     },
    )->pack(-side => "left");
  $buttonframe->Button
    (
     -text => "Apply",
     -command => sub {
       # go through and take all of the updates and mark them
       $self->ActionApply();

     },
    )->pack(-side => "left");
  $buttonframe->pack
    (-side => "bottom");
  $self->TopLevel->geometry("1400x600");
}

sub GetOverdueGoals {
  my ($self,%args) = @_;
  # IDK how to do this yet

  # use the KBS2::Client to query the end date of all goals, finding
  # those goals that have end-dates in the past, and return their
  # nodemanager refs

  print SeeDumper({Context => $self->MyView2->Context});

  # FIXME eventually instead use a microtheory genls to specify rules
  # for planning contexts including a rule something like
  # "taken-care-of" ?X
  my $object = $self->MyView2->MyClient->Send
    (
     QueryAgent => 1,
     InputType => "Interlingua",
     Query => [["end-date",\*{'::?X'},\*{'::?Y'}]],
     Context => $self->MyView2->Context,
     ResultType => "object",
    );
  my $object2 = $self->MyView2->MyClient->Send
    (
     QueryAgent => 1,
     InputType => "Interlingua",
     Query => [["and",
		["end-date",\*{'::?X'},\*{'::?Y'}],
		["or",
		 ["completed",\*{'::?X'}],
		 ["deleted",\*{'::?X'}],
		 ["cancelled",\*{'::?X'}],
		 ["ridiculous",\*{'::?X'}],
		 ["obsoleted",\*{'::?X'}],
		 ["rejected",\*{'::?X'}],
		 ["skipped",\*{'::?X'}],
		]]],
     Context => $self->MyView2->Context,
     ResultType => "object",
    );
  my @results;
  my $skip = {};
  foreach my $binding (@{$object2->Bindings}) {
    my $nodeinterlingua = $binding->[0]->[1];
    $skip->{Dumper($nodeinterlingua)} = 1;
  }
  foreach my $binding (@{$object->Bindings}) {
    my $nodeinterlingua = $binding->[0]->[1];
    next unless ! exists $skip->{Dumper($nodeinterlingua)};
    my $datetimestring = $binding->[1]->[1];
    # convert the datetime into a datetime object and compare to see
    # if it is in the past or not
    # TZID=America/Chicago:20101208T000000
    my $edt = $UNIVERSAL::spse2->MyResources->MyDateManip->ICalDateStringToDateTime(String => $datetimestring);
    my $now = DateTime->now();
    if ($now > $edt) {
      # this is overdue, retrieve the goal from the node manager and
      # add to the list
      my $res = $self->MyView2->MyNodeManager->GetNode(NodeInterlingua => $nodeinterlingua);
      my $goal = $res->[0];
      my $ref = ref $goal;
      if ($ref eq "SPSE2::GUI::Tab::View2::Node") {
	push @results, {
			Goal => $goal,
			EDT => $edt,
		       };
      }
    }
  }
  return {
	  Success => 1,
	  Result => \@results,
	 };
}

sub ActionApply {
  my ($self,%args) = @_;
  my $changes = 0;
  print Dumper($self->Selectors);
  my $items =
    {
     Completed => "completed",
     Deleted => "deleted",
     Cancelled => "cancelled",
     Ridiculous => "ridiculous",
     Obsoleted => "obsoleted",
     Rejected => "rejected",
     Skipped => "skipped",
    };
  foreach my $goaldumper (keys %{$self->Selectors}) {
    my $goal = DeDumper($goaldumper);
    # we want to take each item that is selected
    if (${$self->Selectors->{$goaldumper}->{1}} ne "") {
      my $choice = ${$self->Selectors->{$goaldumper}->{1}};
      if ($choice eq "DoNothing") {
	# skip
      } elsif ($choice eq "RemoveTimeConstraints") {
	# do an unsetmetadata or whatever, skip for now
	# unset the time constraints for this goal
	my $res = $self->MyView2->MyMetadata->DeleteMetadata
	  (
	   Item => $goal,
	   Predicates => ["start-date","end-date","event-duration"],
	  );
      } elsif (exists $items->{$choice}) {
	# # set the metadata to this
	# foreach my $predicate (values %$items) {
	#   my $res = $self->MyView2->MyMetadata->UnsetUnaryPredicate
	#     (
	#      Predicate => $predicate,
	#      Item => $goal,
	#     );
	# }
	my $res = $self->MyView2->MyMetadata->SetUnaryPredicate
	  (
	   Predicate => $items->{$choice},
	   Item => $goal,
	  );
	$changes = 1;
      } else {
	# skip for now
	See("ERROR: $choice");
      }
    } elsif (${$self->Selectors->{$goaldumper}->{2}} ne "") {
      # it is a postpone action
      # skip this for now

    }
  }
  if ($changes) {
    $self->MyView2->Generate();
  }
  # now do a self destroy
  $self->TopLevel->destroy;
}

1;
