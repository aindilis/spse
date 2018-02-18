package SPSE2::GUI::Tab::View;

use Corpus::Util::UniLang;
use Do::ListProcessor3;
use KBS2::Client;
use KBS2::Util;
use Manager::Dialog qw(Approve ApproveCommands Message QueryUser QueryUser2);
use PerlLib::EasyPersist;
use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View::EditGoal;
use SPSE2::GUI::Tab::View::Goal;
use SPSE2::GUI::Tab::View::GoalManager;
use SPSE2::GUI::Tab::View::Info1;
use SPSE2::GUI::Tab::View::Info2;
use SPSE2::GUI::Tab::View::Menus;
use SPSE2::GUI::Tab::View::VerberGUI;
use Verber::Ext::PDDL::Problem;
use Verber::Util::DateManip;

use Class::ISA;
use Graph::Directed;
use GraphViz;
use IO::File;
use Text::Wrap;
use Tk;
use Tk::Animation;
use Tk::GraphViz;

use base qw(SPSE2::GUI::Tab);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Attributes Context Count DependencyGraph Edges Entries
	EntryData H L LastEvent LastTags Marks MyClient MyDateManip
	MyFrame MyGraph MyGraphViz MyMainWindow MyMenus MyTkGraphViz
	MyUniLang Preferences SkipCanvasBind Text Data MyGoalManager
	MyEasyPersist MyListProcessor AlreadyZoomed Debug Database
	MyInfo /

  ];

sub init {
  my ($self,%args) = @_;
  # separate into logic and graphical components (probably should read
  # up about Model View Controller architectures)
  # Controller
  $self->MyEasyPersist
    (PerlLib::EasyPersist->new);
  $self->MyUniLang
    (Corpus::Util::UniLang->new);
  $self->Database($args{Database} || "freekbs2");
  $self->MyClient
    (KBS2::Client->new
     (Database => $self->Database));
  $self->MyListProcessor
    (Do::ListProcessor3->new
     (
      PerformManualClassification => 1,
      SkipComputingPSEEntryIDCounter => 1,
     ));

  # View
  $self->MyFrame($args{Frame});
  $self->MyGoalManager
    (SPSE2::GUI::Tab::View::GoalManager->new);
  $self->Preferences({});
  $self->MyDateManip
    (Verber::Util::DateManip->new);
  $self->DependencyGraph
    (Graph::Directed->new);
  $UNIVERSAL::managerdialogtkwindow = $UNIVERSAL::spse2->MyGUI->MyMainWindow;
  $self->MyFrame->pack(-expand => 1, -fill => 'both');
  $self->MyTkGraphViz({});
  $self->MyTkGraphViz->{MainWindow} = $self->MyFrame;
  $self->MyInfo(SPSE2::GUI::Tab::View::Info2->new);
  print Dumper([
		$self->MyInfo->FieldMap,
		$self->MyInfo->Attributes,
		$self->MyInfo->BinaryRelationMap,
	       ]) if 0;
  $self->MyMenus
    (SPSE2::GUI::Tab::View::Menus->new
     (
      MainWindow => $self->MyTkGraphViz->{MainWindow},
      View => $self,
      Info => $self->MyInfo,
     ));
  $self->MyMenus->LoadMenus;
  $self->Attributes
    ($self->MyInfo->Attributes);
  $self->SkipCanvasBind(0);
}

sub Execute {
  my ($self,%args) = @_;
  my $context = $UNIVERSAL::spse2->Conf->{'-c'} || "Org::FRDCSA::Verber::PSEx2::Do";
  $self->SetContext
    (
     Context => $context,
    );
  $self->Generate();
}

sub Display {
  my ($self,%args) = @_;
  $self->Show();
}

sub MakeGraphViz {
  my ($self,%args) = @_;
  if (defined $self->MyTkGraphViz->{Scrolled}) {
    $self->MyTkGraphViz->{Scrolled}->destroy;
  }
  $self->MyTkGraphViz->{Scrolled} = $self->MyTkGraphViz->{MainWindow}->Scrolled
    (
     'GraphViz',
     -background => 'white',
     -scrollbars => 'sw',
    )->pack(-expand => '1', -fill => 'both' );
  $self->MyTkGraphViz->{Scrolled}->repeat(1, sub {$self->Check()});
  $Text::Wrap::columns = 40;
  $self->MyGraphViz
    (GraphViz->new
     (
      directed => 1,
      rankdir => 'LR',
      node => {
	       shape => 'box',
	      },
     ));
  $self->MyTkGraphViz->{Scrolled}->createBindings();
  $self->MyTkGraphViz->{Scrolled}->bind
    (
     'all',
     '<3>',
     sub {
       $self->SkipCanvasBind(1);
       $self->SetLastTags;
       $self->ShowMenu
	 (
	  Items => \@_,
	  Type => "Node",
	 );
     },
    );

  $self->MyTkGraphViz->{Scrolled}->CanvasBind
    (
     '<Button-3>',
     sub {
       if ($self->SkipCanvasBind) {
	 $self->SkipCanvasBind(0);
	 return;
       }
       $self->SetLastTags;
       $self->ShowMenu
	 (
	  Items => \@_,
	  Type => "Blank",
	 );
     },
    );
  $self->MyTkGraphViz->{Scrolled}->CanvasBind
    (
     '<Shift-Button-1>',
     sub {
       if ($self->SkipCanvasBind) {
	 $self->SkipCanvasBind(0);
	 return;
       }
       $self->SetLastTags;
       my $goal = $self->GetGoalFromLastTags();
       $self->MyGoalManager->Select
	 (
	  Selection => "Toggle-Union",
	  Goal => $goal,
	 );
       $self->Redraw();
     },
    );
  $self->MyTkGraphViz->{Scrolled}->CanvasBind
    (
     '<Button-1>',
     sub {
       if ($self->SkipCanvasBind) {
	 $self->SkipCanvasBind(0);
	 return;
       }
       $self->SetLastTags;
       my $goal = $self->GetGoalFromLastTags();
       $self->MyGoalManager->Select
	 (
	  Selection => "Toggle-Single",
	  Goal => $goal,
	 );
       $self->Redraw();
     },
    );
  $self->MyTkGraphViz->{Scrolled}->CanvasBind
    (
     '<Control-Button-4>',
     sub {
       $self->ZoomIn();
     },
    );
  $self->MyTkGraphViz->{Scrolled}->CanvasBind
    (
     '<Control-Button-5>',
     sub {
       $self->ZoomOut();
     },
    );
  $self->MyTkGraphViz->{Scrolled}->CanvasBind
    (
     '<Control-a>',
     sub {
       $self->Select
	 (
	  Selection => "All",
	 );
     },
    );
  $self->MyTkGraphViz->{Scrolled}->CanvasBind
    (
     '<Control-s>',
     sub {
       $self->Select
	 (
	  Selection => "By Search",
	 );
     },
    );
}


# GRAPH BUILDING

sub AddNode {
  my ($self,%args) = @_;
  my $size = 25;
  my $label = substr($args{Goal}->Description,0,$size);
  $self->Text->{$label} = myformat($args{Goal}->Description);
  $self->Count($self->Count + 1);
  $self->H->{$label} = $self->Count;

  my $nodename = $self->MyGraphViz->add_node
    (
     $self->H->{$label},
     label => $self->Text->{$label},
     style => 'filled',
     color => $self->GetColorForMarks(Term => $args{Term}),
     fillcolor => $self->GetFillColorForMarks(Term => $args{Term}),
    );
  $args{Goal}->GraphVizNode($nodename);
}

sub AddEdge {
  my ($self,%args) = @_;
  # print Dumper(\%args);
  my $entryname1 = $args{EN1};
  my $entryname2 = $args{EN2};
  my $size = 25;
  my $label1 = substr($entryname1,0,$size);
  my $label2 = substr($entryname2,0,$size);
  print Dumper
    (
     labe11 => $label1,
     labe12 => $label2,
     $self->H,
    ) if 0;
  $self->MyGraphViz->add_edge
    (
     $self->H->{$label1} => $self->H->{$label2},
     label => $args{Pred},
     color => $self->Attributes->{$args{Pred}}->{Color},
     style => exists $self->Attributes->{$args{Pred}}->{Style} ? $self->Attributes->{$args{Pred}}->{Style} : undef,
    );
}

sub RemoveEdge {
  my ($self,%args) = @_;
  my $entryname1 = $args{EN1};
  my $entryname2 = $args{EN2};
  my $size = 25;
  my $label1 = substr($entryname1,0,$size);
  my $label2 = substr($entryname2,0,$size);

  print Dumper
    ([
      $args{Relations},
      ["entry-fn", "pse", $self->Data->{iNL}->{$entryname1}],
      ["entry-fn", "pse", $self->Data->{iNL}->{$entryname2}],
     ]) if 0;

  #   # need to find the depends item, etc
  #   print Dumper
  #     (
  #      labe11 => $label1,
  #      labe12 => $label2,
  #      $self->H,
  #     );

  #   $self->MyGraphViz->add_edge
  #     (
  #      $self->H->{$label1} => $self->H->{$label2},
  #      label => $args{Pred},
  #      color => $self->Attributes->{$args{Pred}}->{Color},
  #      style => exists $self->Attributes->{$args{Pred}}->{Style} ? $self->Attributes->{$args{Pred}}->{Style} : undef,
  #     );
}

sub AddUnaryRelation {
  my ($self,%args) = @_;
  my $dumperterm = Dumper($args{Term});
  if (! exists $self->Marks->{$dumperterm}) {
    $self->Marks->{$dumperterm} = {};
  }
  $self->Marks->{$dumperterm}->{$args{Predicate}} = 1;
}

sub RemoveUnaryRelation {
  my ($self,%args) = @_;
  my $dumperterm = Dumper($args{Term});
  if (exists $self->Marks->{$dumperterm}) {
    if (exists $self->Marks->{$dumperterm}->{$args{Predicate}}) {
      delete $self->Marks->{$dumperterm}->{$args{Predicate}};
    }
  }
}

sub Generate {
  my ($self,%args) = @_;
  # Model
  $self->AlreadyZoomed(0);
  $self->Entries({});
  $self->EntryData({});
  $self->Marks({});
  $self->Text({});
  $self->H({});
  $self->L({});
  $self->Count(0);

  $self->MakeGraphViz;

  my $context = $self->Context;
  my $assertions;
  do {
    my $message = $self->MyClient->Send
      (
       QueryAgent => 1,
       Command => "all-asserted-knowledge",
       Context => $context,
      );
    if (defined $message) {
      $assertions = $message->{Data}->{Result};
      if (! scalar @$assertions) {
	# go ahead and assert a goal to remove this goal
	$self->FindOrCreateGoalHelper
	  (
	   Description => "Remove this goal",
	   SkipRedraw => 1,
	  );
      }
    } else {
      die "ERROR: Cannot query KB correctly\n";
    }
  } while (! scalar @$assertions);

  $self->Data({});
  $self->ProcessAssertions
    (
     Assertions => $assertions,
    );

  # compute entryid
  my $max = 0;
  foreach my $entryid (keys %{$self->Data->{NL}}) {
    if ($entryid > $max) {
      $max = $entryid;
    }
  }
  $self->MyListProcessor->PSEEntryIDCounter($max + 1);

  $self->Display();
}

sub ProcessAssertions {
  my ($self,%args) = @_;
  my $assertions = $args{Assertions};
  my $regextmp = join("|",@{$self->MyInfo->UnaryPredicates});
  foreach my $assertion (@$assertions) {
    my $pred = $assertion->[0];
    if ($assertion->[0] eq "has-NL") {
      $self->Data->{NL}->{$assertion->[1]->[2]} = $assertion->[2];
      $self->Data->{iNL}->{$assertion->[2]} = $assertion->[1]->[2];
    } elsif ($pred =~ /^($regextmp)$/) {
      $self->AddUnaryRelation
	(
	 Term => $assertion->[1],
	 Predicate => $pred,
	);
    } else {
      # print Dumper({Predicate => $pred});
    }
  }
  # print Dumper($self->Marks);
  foreach my $assertion (@$assertions) {
    my $pred = $assertion->[0];
    if ($pred eq "depends") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $entryname2 = $self->AddEntry(Term => $assertion->[2]);
      print Dumper([$entryname1,$entryname2]);
      $self->AddEdge
	(
	 Self => $self,
	 EN1 => $entryname1,
	 EN2 => $entryname2,
	 Pred => "depends",
	);
      $self->DependencyGraph->add_edge
	($entryname1,$entryname2);
    } elsif ($pred eq "provides") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $entryname2 = $self->AddEntry(Term => $assertion->[2]);
      $self->AddEdge
	(
	 Self => $self,
	 EN1 => $entryname1,
	 EN2 => $entryname2,
	 Pred => "provides",
	);
    } elsif ($pred eq "eases") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $entryname2 = $self->AddEntry(Term => $assertion->[2]);
      my $preferencename = "eases-$entryname1-$entryname2";
      $self->AddPreference($preferencename);
      $self->AddEdge
	(
	 Self => $self,
	 EN1 => $entryname1,
	 EN2 => $entryname2,
	 Pred => "eases",
	);
    } elsif ($pred eq "prefer") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $entryname2 = $self->AddEntry(Term => $assertion->[2]);
      my $preferencename = "prefer-$entryname1-$entryname2";
      $self->AddPreference($preferencename);
      $self->AddEdge
	(
	 Self => $self,
	 EN1 => $entryname1,
	 EN2 => $entryname2,
	 Pred => "prefer",
	);
    } elsif ($pred eq "costs") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $costs = $assertion->[2];
      my $finalcosts;
      if ($costs =~ /\$(\d+)/) {
	$finalcosts = $1;
      }
    } elsif ($pred eq "earns") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $tmp = $assertion->[2];
      my $finalcosts;
      if ($tmp =~ /\$(\d+)/) {
	$earnings = $1;
      }
    } elsif ($pred eq "pse-has-property") {
      if ($assertion->[2] eq "very important" or $assertion->[2] eq "important") {
	my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      }
    } elsif ($pred eq "goal") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      if (0) {
	$self->Preferences->{"p-".$entryname1} = 1;
      }
    } elsif ($pred eq "due-date-for-entry") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $dateinformation = $assertion->[2];
    } elsif ($pred eq "start-date") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $dateinformation = $assertion->[2];
      $self->EntryData->{$entryname1}->{"begin-opportunity"} = $dateinformation;
    } elsif ($pred eq "event-duration") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $durationinformation = $assertion->[2];
      $self->EntryData->{$entryname1}->{"opportunity-duration"} = $durationinformation;
    } elsif ($pred eq "end-date") {
      my $entryname1 = $self->AddEntry(Term => $assertion->[1]);
      my $dateinformation = $assertion->[2];
      $self->EntryData->{$entryname1}->{"end-opportunity"} = $dateinformation;
    } else {
      print "Unknown Predicate: $pred\n";
    }
  }

  my @metric;
  # push @metric, ["*","10",["is-violated","b1"]];
  foreach my $pref (keys %{$self->Preferences}) {
    push @metric, ["*","10",["is-violated", $pref]];
  }

  # now update all opportunity windows
  foreach my $entry (keys %{$self->EntryData}) {
    my @missing;
    foreach my $item (qw(begin-opportunity end-opportunity opportunity-duration)) {
      if (! exists $self->EntryData->{$entry}->{$item}) {
	push @missing, $item;
      }
    }
    if (scalar @missing <= 1) {
      my ($sdt,$edt,$dur);
      if (exists $self->EntryData->{$entry}->{"begin-opportunity"}) {
	# print Dumper($self->EntryData->{$entry}->{"begin-opportunity"});
	# my $startepoch = str2time($self->EntryData->{$entry}->{"begin-opportunity"});
	my $startepoch = Date::ICal->new( ical => $self->EntryData->{$entry}->{"begin-opportunity"})->epoch;
	$sdt = DateTime->from_epoch(epoch => $startepoch);
      }
      if (exists $self->EntryData->{$entry}->{"end-opportunity"}) {
	# print Dumper($self->EntryData->{$entry}->{"end-opportunity"});
	# my $endepoch = str2time($self->EntryData->{$entry}->{"end-opportunity"});
	my $endepoch = Date::ICal->new( ical => $self->EntryData->{$entry}->{"end-opportunity"})->epoch;
	$edt = DateTime->from_epoch(epoch => $endepoch);
      }
      if (exists $self->EntryData->{$entry}->{"opportunity-duration"}) {
	my %hash = ();
	foreach my $timespec (split /,\s*/, $self->EntryData->{$entry}->{"opportunity-duration"}) {
	  my ($qty,$unit) = split /\s+/, $timespec;
	  $hash{$unit} = $qty;
	}
	if (keys %hash) {
	  $dur = DateTime::Duration->new
	    (%hash);
	} else {
	  print "ERROR parsing opportunity-duration\n";
	}
      }
      if (scalar @missing == 1) {
	# there will be no conflict, generate the begin and end
	my $missingitem = shift @missing;
	if ($missingitem eq "begin-opportunity") {
	  $sdt = $edt - $dur;
	} elsif ($missingitem eq "end-opportunity") {
	  $edt = $sdt + $dur;
	} elsif ($missingitem eq "opportunity-duration") {
	  $dur = $edt - $sdt;
	}
      } elsif (scalar @missing == 0) {
	print "Sanity Check needed here, not yet implemented!\n";
	if (abs(DateTime::Duration->compare($sdt + $dur,$edt))) {
	  print "Dates do not align!\n";
	}
      }
      # now that we have sdt and edt, generate statements
    } else {
      print "Underspecified event (not enough date information): <$entry>\n";
    }
  }

  # now print the problem file for now
  my @cycle = $self->DependencyGraph->find_a_cycle;
  if (scalar @cycle) {
    print "Dependency cycle detected\n";
    print Dumper(\@cycle);
  } else {
    print "No dependency cycle found\n";
  }
}

sub AddEntry {
  my ($self,%args) = @_;
  my $term = $args{Term};
  my $context = $self->Context;
  if (! defined $term or ! defined $term->[0]) {
    warn "Term is not defined\n";
    return;
  }
  if ($term->[0] ne "entry-fn") {
    die "ERROR <".$term->[0].">\n";
  }
  my $entrytype = $term->[1];
  my $entryid = $term->[2];
  my $entry;
  if ($entrytype eq "unilang") {
    if (0) {
      $entry = $self->MyUniLang->GetUniLangMessageContents
	(EntryID => $entryid);
    } else {
      $entry = $entryid;
    }
  } elsif ($entrytype eq "pse") {
    if (! defined $self->Data->{NL}->{$entryid}) {
      my $object = $self->MyClient->Send
	(
	 QueryAgent => 1,
	 InputType => "Interlingua",
	 Query => [["has-NL",$term,\*{'::?NatLang'}]],
	 Context => $context,
	 ResultType => "object",
	);
      my @res = $object->MatchBindings(VariableName => "?NatLang");
      if (scalar @res) {
	$entry = $res[0]->[0];
      } else {
	$entry = "unknown: $entryid";
      }
    } else {
      $entry = $self->Data->{NL}->{$entryid}
    }
  } elsif ($entrytype eq "sayer-index") {
    warn "Not yet implemented\n";
    # $entry = $self->MyUniLang->GetUniLangMessageContents
    # (EntryID => $entryid);
  }
  my $res = $self->AddEntryPart2
    (
     Source => $entrytype,
     EntryID => $entryid,
     Description => $entry,
     Term => $term,
    );
  return $res->{Name};
}

sub AddEntryPart2 {
  my ($self,%args) = @_;
  my $name = $args{Description};
  $name =~ s/\W/_/g;
  # my $name = "entry-".$entryid;
  if (! exists $self->Entries->{$name}) {
    $self->Entries->{$name} = 1;
    my $goal = SPSE2::GUI::Tab::View::Goal->new
      (
       Source => $args{Source},
       EntryID => $args{EntryID},
       Description => $args{Description},
      );
    $self->MyGoalManager->AddGoal
      (
       Goal => $goal,
      );
    $self->AddNode
      (
       Goal => $goal,
       Term => $args{Term},
      );
  }
  return {
	  Success => 1,
	  Name => $args{Description},
	  # Goal => $goal,
	 };
}

sub AddPreference {
  my ($self,$preference) = @_;
  print "Don't know what to do just yet here\n";
}



# MISC

sub Check {
  my ($self,%args) = @_;

}

sub SetLastTags {
  my ($self,%args) = @_;
  my @lasttags = $self->MyTkGraphViz->{Scrolled}->gettags('current');
  pop @lasttags;
  $self->LastTags({@lasttags});
}

sub GetGoalFromLastTags {
  my ($self,%args) = @_;
  my $node = $self->LastTags->{node};
  $node =~ s/^node//;
  my $res = $self->MyGoalManager->GetGoal
    (GraphVizNode => $node);
  return $res->[0];
}

sub ShowMenu {
  my ($self,%args) = @_;
  my $w = shift @{$args{Items}};
  my $Ev = $w->XEvent;
  $self->LastEvent($Ev);
  # unpost any other menus
  foreach my $menutype (keys %{$self->MyMenus->MyMenu}) {
    $self->MyMenus->MyMenu->{$menutype}->unpost();
  }
  $self->MyMenus->MyMenu->{$args{Type}}->post($Ev->X, $Ev->Y);
  # and set the menu information to contain this
}

sub myformat {
  my $text = shift;
  $text =~ s/-/ /g;
  $text = wrap('', '', $text);
  $text =~ s/\n/\\n/g;
  return $text;
}

sub ChooseContext {
  my ($self,%args) = @_;
  my $c = `kbs2 -l`;
  my @set = split /\n/, $c;
  my $context = Choose(@set);
  $self->SetContext
    (
     Context => $context,
    );
}

sub SetContext {
  my ($self,%args) = @_;
  $self->Context($args{Context});
  # set the name of this tab
  $UNIVERSAL::spse2->MyGUI->MyTabManager->MyNoteBook->{_pages_}->{View}->configure
    (
     -label => "View: ".$args{Context},
    );
  # set the ListProcessor context
  $self->MyListProcessor->SetContext
    (
     Context => $args{Context},
    );
}


# DATA LOADING AND SAVING

sub LoadContext {
  my ($self,%args) = @_;
  if (Approve("Replace Existing Context?")) {
    if ($args{Context}) {
      $self->SetContext
	(
	 Context => $args{Context},
	);
    } else {
      $self->ChooseContext;
    }
    # now we have to process and load this context
    print Dumper($self->Context);
    $self->Generate();
  }
}

sub ExportKBS {
  my ($self,%args) = @_;
  if (Approve("Export KBS file for context <".$self->Context.">?")) {
    # say overwrite this context?
    # export the data
    my $filename = $args{Filename} || $self->Context.".kbs";
    my $command = "kbs2 --output-type \"Emacs String\" --db ".shell_quote($self->Database)." -c ".shell_quote($self->Context)." show | sort > ".shell_quote($filename);
    ApproveCommands
      (
       Commands => [$command],
       Method => "parallel",
      );
  }
}

sub ImportKBS {
  my ($self,%args) = @_;
  # upgrade this to include file selection stuff
  if (Approve("Import KBS file for context <".$self->Context.">?")) {
    # verify the file exists
    my $filename = $args{Filename} || $self->Context.".kbs";
    if (! -f $filename) {
      print "$filename not found\n";
    } else {
      # now we have to process and load this context
      my @commands;
      push @commands, "kbs2 --db ".shell_quote($self->Database)." -c ".shell_quote($self->Context)." clear";
      push @commands, "kbs2 --no-checking --db ".shell_quote($self->Database)." -c ".shell_quote($self->Context)." --input-type \"Emacs String\" import ".shell_quote($filename);
      ApproveCommands
	(
	 Commands => \@commands,
	 Method => "parallel",
	);
    }
  }
}
sub ExportPDDLFiles {
  my ($self,%args) = @_;
  # print out to the problem file in the world section
  # print out to the problem file in the world section
  #   my $fh = IO::File->new;
  #   $fh->open(">/var/lib/myfrdcsa/codebases/internal/verber/data/worldmodel/templates/psex2.p.pddl")
  #     or die "can't open\n";
}

sub LoadDotDoFile {
  my ($self,%args) = @_;
  my $command = q{`locate -r '\\\\.do\$'`};
  my $res = $self->MyEasyPersist->Get(Command => $command);
  if ($res->{Success}) {
    my @files = split /\n/, $res->{Result};
    my $file = Choose(@files);
    $self->ProcessDotDoFile(File => $file);
  }
}

sub ProcessDotDoFile {
  my ($self,%args) = @_;
  $self->MyListProcessor->Execute
    (
     Files => [$args{File}]
    );
}



sub FindOrCreateGoalHelper {
  my ($self,%args) = @_;
  my $description = $args{Description};
  my $res = $self->MyListProcessor->GenerateStatementsAbout
    (
     Self => $self,
     Domain => $description,
     ReturnEntries => 1,
    );
  print Dumper($res);
  if ($res->{Success}) {
    my $res2 = $self->ModifyAxiomsCautiously
      (
       Entries => $res->{Entries},
      );
    my @res3;
    foreach my $entry (@{$res->{Entries}}) {
      push @res3, $self->ProcessAssertions
	(
	 Assertions => $entry->{Assertions},
	);
    }
    print Dumper
      ({
	Res2 => $res2,
	Res3 => \@res3,
       });

    if (0 and exists $args{Relation}) {
      # now select the new goal, so that the selection returns it
      $self->ModifyBinaryRelation
	(
	 Relation => $args{Relation},
	 Value => "True",
	);
    }
    if ($res2->{Changes} and ! $args{SkipRedraw}) {
      $self->Redraw();
    }
  }
}

sub AddNewGoalDefinitionToCurrentContext {
  my ($self,%args) = @_;
  return {
	  Success => 1,
	  Result => $result,
	 };
}

sub RemoveGoal {
  my ($self,@tmp) = @_;
  my $goal = $self->GetGoalFromLastTags;
  # find all the relations it is part of, remove those first
  # then remove the goal
  my $interlingua = $goal->Interlingua;
  if (1) {
    my $i = 1;
    foreach my $predicate (@{$self->MyInfo->BinaryPredicates}) {
      push @or, [$predicate,$interlingua,Var("?X$i")];
      ++$i;
      push @or, [$predicate,Var("?X$i"),$interlingua];
      ++$i;
    }
    if (0) {
      foreach my $predicate (@{$self->MyInfo->UnaryPredicates}) {
	push @or, [$predicate,$interlingua];
      }
    }
  } else {
    push @or, ["depends",$i,Var("?X1")];
    push @or, ["depends",Var("?X2"),$i];
  }
  my $removalformula = ["or",@or,];
  my $object = $self->MyClient->Send
    (
     QueryAgent => 1,
     InputType => "Interlingua",
     Query => [$removalformula],
     Context => $self->Context,
     ResultType => "object",
    );
  print Dumper($object->Bindings);
}

sub ModifyUnaryRelation {
  my ($self,%args) = @_;
  my $predicate = lc($args{Predicate});
  my $res = $self->MyGoalManager->GetGoal
    (
     Selected => 1,
    );
  my @entries;
  foreach my $goal (@$res) {
    my $relation = [$predicate, $goal->Interlingua];
    my $relation2;
    my $label;
    if ($args{Value} eq "True" or $args{Value} eq "False") {
      my $sub;
      if ($args{Value} eq "True") {
	$relation2 = $relation;
	$label = $item->{Predicate};
	$sub = sub {
	  $self->AddUnaryRelation
	    (
	     Term => $goal->Interlingua,
	     Predicate => $predicate,
	    );
	};
      } elsif ($args{Value} eq "False") {
	$relation2 = ["not", $relation];
	$label = "not ".$item->{Predicate};
	$sub = sub {};
      }
      push @entries, {
		      Assertions => [$relation2],
		      Functions => [
				    $sub,
				   ],
		     };
    }
    if ($args{Value} eq "Independent") {
      push @entries, {
		      Unassertions => [
				       $relation,
				       ["not", $relation],
				      ],
		      Functions => [
				    sub {
				      $self->RemoveUnaryRelation
					(
					 Term => $goal->Interlingua,
					 Predicate => $predicate,
					);
				    },
				   ],
		     };
    }
  }
  my $res = $self->ModifyAxiomsCautiously
    (
     Entries => \@entries,
    );
  if ($res->{Changes}) {
    $self->Redraw();
  }
}

sub ModifyBinaryRelation {
  my ($self,%args) = @_;
  my $relationmap = $self->MyInfo->BinaryRelationMap();
  my $res = $self->MyGoalManager->GetGoal
    (
     Selected => 1,
    );
  my $last = pop @$res;
  my $item = $relationmap->{$args{Relation}};
  my @entries;
  foreach my $goal (@$res) {
    my $relation = [$item->{Predicate}];
    my $edge =
      {
       Self => $self,
      };
    if (exists $item->{Order} and $item->{Order} eq "inverse") {
      push @$relation, $last->Interlingua, $goal->Interlingua;
      $edge->{EN1} = $last->Description;
      $edge->{EN2} = $goal->Description;
    } else {
      push @$relation, $goal->Interlingua, $last->Interlingua;
      $edge->{EN1} = $goal->Description;
      $edge->{EN2} = $last->Description;
    }
    my $relation2;
    my $label;
    if ($args{Value} eq "True" or $args{Value} eq "False") {
      if ($args{Value} eq "True") {
	$relation2 = $relation;
	$label = $item->{Predicate};
      } elsif ($args{Value} eq "False") {
	$relation2 = ["not", $relation];
	$label = "not ".$item->{Predicate};
      }
      $edge->{Pred} = $label;
      push @entries, {
		      Assertions => [$relation2],
		      Functions => [sub {$self->AddEdge(%$edge)}],
		     };
    } elsif ($args{Value} eq "Independent") {
      my $edge2 = {%$edge};
      my $relations = [
		       $relation,
		       ["not",$relation],
		      ];
      $edge->{Pred} = $item->{Predicate};
      $edge->{Relations} = $relations;
      $edge2->{Pred} = "not ".$item->{Predicate};
      $edge2->{Relations} = $relations;
      push @entries, {
		      Unassertions => $relations,
		      Functions => [
				    sub {$self->RemoveEdge(%$edge)},
				    sub {$self->RemoveEdge(%$edge2)},
				    sub {$self->Generate},
				   ],
		     };
    }
  }
  my $res = $self->ModifyAxiomsCautiously
    (
     Entries => \@entries,
    );
  if ($res->{Changes}) {
    $self->Redraw();
  }
  $self->Redraw();
  $self->CenterCanvasWindowOnGoal
    (
     Goal => $last,
    );
}

sub ModifyField {
  my ($self,%args) = @_;
  # load the current value into the edit box
  my $fieldmap = $self->MyInfo->FieldMap();

  # okay, we have to choose between one and all selected (do we
  # synchronize the value to a new one or do we just edit one) - could
  # do a subset select or a choose with one All Value
  my @unassert;
  my @assert;
  my $field = $fieldmap->{$args{Field}};
  # grab all the goals from the selection
  my $goals = $self->MyGoalManager->GetGoal
    (
     Selected => 1,
    );
  my $size = scalar @$goals;
  if ($size == 1) {
    # obtain the original value for that field for that goal
    my $goal = $goals->[0];
    my $entry;
    my $match;
    my $object = $self->MyClient->Send
      (
       QueryAgent => 1,
       InputType => "Interlingua",
       Query => [[$field,$goal->Interlingua,\*{'::?NatLang'}]],
       Context => $context,
       ResultType => "object",
      );
    my @res = $object->MatchBindings(VariableName => "?NatLang");
    if (scalar @res) {
      $entry = $res[0]->[0];
      $match = 1;
    } else {
      $entry = "";
      $match = 0;
    }
    # now go ahead and open the editor with it
    my $res = QueryUser2
      (
       Message => "Edit the field <$field> for <".Dumper($goal->Interlingua).">",
       DefaultValue => $entry,
      );
    # now unassert any existing value
    if (! $res->{Cancel}) {
      if ($match) {
	# unassert it
      }
      # now assert it
      push @unassert, [$field, $goal->Interlingua, \*{'::?NatLang'}];
      push @assert, [$field, $goal->Interlingua, $res->{Value}];
    }
  } elsif ($size > 1) {
    my $res = QueryUser2
      (
       Message => "Edit the field <$field> for $size selected goal(s)",
       DefaultValue => $entry,
      );
    # just get the new value for the field
    if (! $res->{Cancel}) {
      foreach my $goal (@$goals) {
	push @unassert, [$field, $goal->Interlingua,\*{'::?NatLang'}];
	push @assert, [$field, $goal->Interlingua, $res->{Value}];
      }
      # iterate over all goals and set the value of that field to that
    }
  }
  # execute all the changes
  my $res = $self->ModifyAxiomsCautiously
    (
     Entries => [{
		  Unassertions => \@unassert,
		  Assertions => \@assert,
		 }],
    );
  if ($res->{Changes}) {
    $self->Redraw();
  }
}

sub ModifyAxiomsCautiously {
  my ($self,%args) = @_;
  # I guess this whole thing has to be done at once
  # try to assert all the goals
  #  if a given goal cannot be asserted, see if we should unasserted
  #  either it, or any of it's negation-invariants
  #  prompt the user for any non-monotonic changes to the KB
  # finish asserting all goals

  #  perhaps this could be accomplished by asserting in a parallel
  #  context, testing, and then deleting the original and renaming the
  #  parallel, or perhaps it could be accomplished with genls
  #  contexts, i.e. assert it in a context inheriting from the changed
  #  context and the original context

  my $entries = $args{Entries};
  my $changes = 0;
  foreach my $entry (@{$args{Entries}}) {
    foreach my $unassertion (@{$entry->{Unassertions}}) {
      my %sendargs =
	(
	 Unassert => [$unassertion],
	 Context => $self->Context,
	 QueryAgent => 1,
	 InputType => "Interlingua",
	 Flags => {
		   AssertWithoutCheckingConsistency => 1,
		  },
	);
      print Dumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print Dumper($res);
      $changes = 1;
    }
    foreach my $assertion (@{$entry->{Assertions}}) {
      my %sendargs =
	(
	 Assert => [$assertion],
	 Context => $self->Context,
	 QueryAgent => 1,
	 InputType => "Interlingua",
	 Flags => {
		   AssertWithoutCheckingConsistency => 1,
		  },
	);
      print Dumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print Dumper($res);
      $changes = 1;
    }
    foreach my $function (@{$entry->{Functions}}) {
      print Dumper($function->());
      $changes = 1;
    }
  }
  return {
	  Success => 1,
	  Changes => $changes,
	 };
}

sub Select {
  my ($self,%args) = @_;
  $self->MyGoalManager->Select(%args);
  $self->Redraw();
}


# DISPLAY OPERATIONS

sub GetColorForMarks {
  my ($self,%args) = @_;
  my $dumperterm = Dumper($args{Term});
  if (exists $self->Marks->{$dumperterm}) {
    print "HOW 1\n";
    print Dumper($self->Marks->{$dumperterm});
    if (exists $self->Marks->{$dumperterm}->{completed}) {
      print "HOW 2\n";
      return "black";
    }
  }
  return "black";
}

sub GetFillColorForMarks {
  my ($self,%args) = @_;
  return $self->GetFillColorForMarksInfo2(%args);
}

sub GetFillColorForMarksInfo1 {
  my ($self,%args) = @_;
  # http://www.rtapo.com/notes/named_colors.html
  my $dumperterm = Dumper($args{Term});
  if (exists $self->Marks->{$dumperterm}) {
    if (exists $self->Marks->{$dumperterm}->{completed}) {
      if ($args{Selected}) {
	return "DodgerBlue";	# dark blue
      } else {
	return "DeepSkyBlue";	# light blue
      }
    }
    if (exists $self->Marks->{$dumperterm}->{deleted} or
	exists $self->Marks->{$dumperterm}->{cancelled} or
	exists $self->Marks->{$dumperterm}->{ridiculous} or
	exists $self->Marks->{$dumperterm}->{obseleted} or
	exists $self->Marks->{$dumperterm}->{rejected} or
	exists $self->Marks->{$dumperterm}->{skipped}) {
      if ($args{Selected}) {
	return "saddle brown";	# dark brown
      } else {
	return "peru";		# light brown
      }
    }
    if (exists $self->Marks->{$dumperterm}->{showstopper}) {
      if ($args{Selected}) {
	return "maroon";	# dark red
      } else {
	return "indian red";	# light red
      }
    }
  }
  if ($args{Selected}) {
    return "dark gray";
  } else {
    return "lightgray";
  }
}

sub GetFillColorForMarksInfo2 {
  my ($self,%args) = @_;
  # http://www.rtapo.com/notes/named_colors.html
  my $dumperterm = Dumper($args{Term});
  if (exists $self->Marks->{$dumperterm}) {
    foreach my $predicate (keys %{$self->Marks->{$dumperterm}}) {
      if ($args{Selected}) {
	return $self->MyInfo->GetColorForUnaryPredicate
	  (
	   Predicate => $predicate,
	   Selected => 1,
	  );
      } else {
	return $self->MyInfo->GetColorForUnaryPredicate
	  (
	   Predicate => $predicate,
	  );
      }
    }
  }
  if ($args{Selected}) {
    return "dark gray";
  } else {
    return "lightgray";
  }
}

sub ZoomIn {
  my ($self,%args) = @_;
  # $self->StoreCenter();
  $self->MyTkGraphViz->{Scrolled}->zoom(-in => 1.1);
  #   $self->CenterCanvasWindowOnCoordinates
  #     (
  #      XFraction => $res->{XFraction},
  #      YFraction => $res->{YFraction},
  #      Width => $res->{Width},
  #      Height => $res->{Height},
  #     );
}

sub ZoomOut {
  my ($self,%args) = @_;
  $self->MyTkGraphViz->{Scrolled}->zoom(-out => 1.1);
}

sub Show {
  my ($self,%args) = @_;
  my $graphviz = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{scrolled};
  my $scaledbefore = $graphviz->{_scaled};
  my @x = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->get();
  my @y = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->show( $self->MyGraphViz );
  my $scaledafter = $graphviz->{_scaled};
  if (($scaledbefore != 0) and ($scaledafter != 0)) {
    my $zoom = $scaledbefore / $scaledafter;
    $self->MyTkGraphViz->{Scrolled}->zoom(-in => $zoom);
  }
  $self->MyTkGraphViz->{Scrolled}->xviewMoveto($x[0]);
  $self->MyTkGraphViz->{Scrolled}->yviewMoveto($y[0]);
  if (! $self->AlreadyZoomed) {
    $self->MyTkGraphViz->{Scrolled}->zoom(-in => 3000.0);
    $self->AlreadyZoomed(1);
  }
}

sub Redraw {
  my ($self,%args) = @_;
  foreach my $goal ($self->MyGoalManager->Goals->Values) {
    $self->MyGraphViz->{NODES}->{$goal->GraphVizNode}->{fillcolor} = $self->GetFillColorForMarks
      (
       Selected => $goal->Selected,
       Term => $goal->Interlingua,
      );
  }
  $self->Show();
}

sub FitGraph {
  my ($self,%args) = @_;
  $self->MyTkGraphViz->{Scrolled}->fit();
}

sub CenterCanvasWindowOnGoal {
  my ($self,%args) = @_;
  # find the coordinates of this and set the canvas to it
  print "<should find goal: $description>\n" if $self->Debug;
  my $res = $args{Goal}->DisplayPosition
    (
     TkGraphViz => $self->MyTkGraphViz->{Scrolled},
    );
  if ($res->{Success}) {
    $self->CenterCanvasWindowOnCoordinates
      (
       XFraction => $res->{XFraction},
       YFraction => $res->{YFraction},
       Width => $res->{Width},
       Height => $res->{Height},
      );
  }
}

sub CenterCanvasWindowOnCoordinates {
  my ($self,%args) = @_;
  print Dumper(\%args) if $self->Debug;
  my $canvas = $self->MyTkGraphViz->{Scrolled};
  my ($x1,$x2) = $canvas->xview;
  my $xrange = abs($x2 - $x1);
  my ($y1,$y2) = $canvas->yview;
  my $yrange = abs($y2 - $y1);
  print Dumper($xrange,$yrange) if $self->Debug;
  $canvas->xviewMoveto($args{XFraction} - ($xrange / 2));
  $canvas->yviewMoveto(1 - ($args{YFraction} + ($yrange / 2)));
}


# SEARCH OPERATIONS

sub Search {
  my ($self,%args) = @_;
  # go ahead and sprout a top leve window with the search results
  my $selectionmap =
    {
     "Search" => "By Search",
     "Regex" => "By Regex",
     "Entailment" => "By Entailment",
    };
  $self->Select
    (
     Selection => $selectionmap->{$args{Type}},
    );
}

sub Find {
  my ($self,%args) = @_;
  # we want to go ahead and find an item
  # my $regex = QueryUser("Please enter Search:");
  my $res = QueryUser2
    (
     Title => "Find",
     Message => "Please enter Search:",
    );
  return if $res->{Cancel};
  my $regex = $res->{Value};
  my @matchinggoals;
  if ($regex) {
    foreach my $goal ($self->MyGoalManager->Goals->Values) {
      if ($goal->Description =~ /$regex/i) {
	if (! $self->MyGoalManager->Skip
	    (
	     Skip => $args{Skip},
	     Goal => $goal,
	    )) {
	  # also, add this 
	  push @matchinggoals, $goal;
	}
      }
    }
  }
  if (scalar @matchinggoals) {
    if (0) {
      SubsetSelect
	(
	 Set => \@matchinggoals,
	 Selection => {},
	);
    } else {
      my $description = Choose2
	(
	 List => [sort map {$_->Description} @matchinggoals],
	 Wrap => 1,
	 Cancel => 1,
	);
      if ($description) {
	# select this goal and move the screen to center on it
	my $res = $self->MyGoalManager->GetGoal
	  (
	   Description => $description,
	  );
	my $lastgoal;
	foreach my $goal (@$res) {
	  $self->MyGoalManager->AddGoalToSelection(Goal => $goal);
	  $lastgoal = $goal;
	}
	# now redraw
	$self->Redraw();
	$self->CenterCanvasWindowOnGoal
	  (
	   Goal => $lastgoal,
	  );
      }
    }
  }
}


# CONTEXT ACTIONS

sub CleanUpContext {
  my ($self,%args) = @_;
  # go ahead and process each singleton using the Interrelator
  # how to do we determine singletons?

}

sub EditContext {
  my ($self,%args) = @_;
  # export the context to a file
  my $contextfile = "/var/lib/myfrdcsa/codebases/minor/spse/data/spse2-temporary.kbs";
  $self->ExportKBS
    (
     Filename => $contextfile,
    );
  # edit the file
  system "emacsclient.emacs22 ".shell_quote($contextfile)." &";
  # import the context from the file
  $self->ImportKBS
    (
     Filename => $contextfile,
    );
  ApproveCommands
    (
     Commands => ["rm ".shell_quote($contextfile)." ".shell_quote($contextfile."~")],
     Method => "parallel",
    );
}

sub CheckContextConsistency {
  my ($self,%args) = @_;
  # check consistency
  Message(Message => "CheckContextConsistency Not yet implemented.");
}


# OTHER ACTIONS

sub EditSource {
  my ($self,%args) = @_;
  system "emacsclient.emacs22 /var/lib/myfrdcsa/codebases/minor/spse/SPSE2/GUI/Tab/View.pm &";
}

sub AgendaEditor {
  my ($self,%args) = @_;
  # open the agenda domain, and allow us to edit it

}

sub QueryCompleted {
  my ($self,%args) = @_;
  # show all the completed goals

}

sub ActionScreenshot {
  my ($self,%args) = @_;
  # show all the completed goals

  # get the dot file and dump it, then render it to an image file with
  # graphviz

  my $dotfile = "spse2.dot";
  my $jpgfile = "spse2.jpg";
  my $fh = IO::File->new();
  $fh->open(">$dotfile") or warn "cannot open out file: $dotfile\n";
  print $fh join("\n", @{$self->MyTkGraphViz->{Scrolled}->{SubWidget}->{scrolled}->{layout}});
  $fh->close();
  my $command = "dot ".shell_quote($dotfile)." -Tjpeg > ".shell_quote($jpgfile);

  print $command;
  system $command;
  # system "rm ".shell_quote($dotfile);
}


# WINDOWS THAT ARE LAUNCHED

sub FindOrCreateGoal {
  my ($self,%args) = @_;
  my $editgoal = SPSE2::GUI::Tab::View::EditGoal->new
    (
     MainWindow => $UNIVERSAL::spse2->MyGUI->MyMainWindow,
     View => $self,
    );
}

sub EditGoal {
  my ($self,@tmp) = @_;
  my $goal = $self->GetGoalFromLastTags;
  my $editgoal = SPSE2::GUI::Tab::View::EditGoal->new
    (
     View => $self,
     MainWindow => $UNIVERSAL::spse2->MyGUI->MyMainWindow,
     Goal => $goal,
    );
}

sub GeneratePlan {
  my ($self,%args) = @_;
  my $verbergui = SPSE2::GUI::Tab::View::VerberGUI->new
    (
     Database => $self->Database,
     View => $self,
    );
  $verbergui->Execute();
}

sub BackupAndRestore {
  my ($self,%args) = @_;
  print "Not yet implemented\n";
  # should add this to many applications.
}

1;
