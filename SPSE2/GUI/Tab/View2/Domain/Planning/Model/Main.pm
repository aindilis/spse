package SPSE2::GUI::Tab::View2::Domain::Planning::Model::Main;

use Do::ListProcessor3;
use PerlLib::EasyPersist;
use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View2::Domain::Planning::Model::Overdue;
use SPSE2::Util;
use Verber::Ext::PDDL::Problem;
use Verber::Util::DateManip;

use Graph::Directed;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyDomain MyView2 Context Data MyDateManip MyListProcessor
    DependencyGraph EntryData Entries MyEasyPersist Preferences
    TypeHash MyOverdue /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyDomain($args{Domain});
  $self->MyView2($args{View2});
  $self->MyDateManip
    (Verber::Util::DateManip->new);
  $self->MyEasyPersist
    (PerlLib::EasyPersist->new);
  $self->TypeHash
    ({
      goal => "box",
      condition => "diamond",
     });
}

sub SetContext {
  my ($self,%args) = @_;
  $self->Context($args{Context});
  # set the ListProcessor context
  if (! defined $self->MyListProcessor) {
    print "SETTING CONTEXT TO ".$args{Context}."\n";
    $self->MyListProcessor
      (Do::ListProcessor3->new
       (
	PerformManualClassification => 1,
	Context => $args{Context},
	# SkipComputingPSEEntryIDCounter => 1,
       ));
  } else {
    $self->MyListProcessor->SetContext(Context => $args{Context});
  }
}

sub Generate {
  my ($self,%args) = @_;
  $self->Preferences({});
  $self->Data({});
  $self->EntryData({});
  $self->Entries({});
  $self->DependencyGraph
    (Graph::Directed->new);
}

sub PreProcessAssertion {
  my ($self,%args) = @_;
  my $assertion = $args{Assertion};
  my $regextmp = join("|",@{$self->MyView2->MyInfo->UnaryPredicates});
  my $pred = $assertion->[0];
  if ($assertion->[0] eq "has-NL") {
    $self->Data->{NL}->{$assertion->[1]->[2]} = $assertion->[2];
    $self->Data->{iNL}->{$assertion->[2]} = $assertion->[1]->[2];
  } elsif ($pred =~ /^($regextmp)$/) {
    $self->MyView2->AddUnaryRelation
      (
       Term => $assertion->[1],
       Predicate => $pred,
      );
  } else {
    # print SeeDumper({Predicate => $pred});
  }
}

sub ProcessAssertion {
  my ($self,%args) = @_;

  my $assertion = $args{Assertion};
  my $pred = $assertion->[0];
  if ($pred eq "goal") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
       Render => $args{Render},
      );
  } elsif ($pred eq "condition") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "condition",
       Render => $args{Render},
      );
  } elsif ($pred eq "depends") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $entryname2 = $self->AddEntry
      (
       Term => $assertion->[2],
       Type => "goal",
      );
    print SeeDumper([$entryname1,$entryname2]);
    $self->MyView2->AddEdge
      (
       Self => $self,
       EN1 => $entryname1,
       EN2 => $entryname2,
       Pred => "depends",
      );
    $self->DependencyGraph->add_edge
      ($entryname1,$entryname2);
  } elsif ($pred eq "provides") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $entryname2 = $self->AddEntry
      (
       Term => $assertion->[2],
       Type => "goal",
      );
    $self->MyView2->AddEdge
      (
       Self => $self,
       EN1 => $entryname1,
       EN2 => $entryname2,
       Pred => "provides",
      );
  } elsif ($pred eq "eases") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $entryname2 = $self->AddEntry
      (
       Term => $assertion->[2],
       Type => "goal",
      );
    my $preferencename = "eases-$entryname1-$entryname2";
    $self->AddPreference($preferencename);
    $self->MyView2->AddEdge
      (
       Self => $self,
       EN1 => $entryname1,
       EN2 => $entryname2,
       Pred => "eases",
      );
  } elsif ($pred eq "prefer") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $entryname2 = $self->AddEntry
      (
       Term => $assertion->[2],
       Type => "goal",
      );
    my $preferencename = "prefer-$entryname1-$entryname2";
    $self->AddPreference($preferencename);
    $self->MyView2->AddEdge
      (
       Self => $self,
       EN1 => $entryname1,
       EN2 => $entryname2,
       Pred => "prefer",
      );
  } elsif ($pred eq "costs") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $costs = $assertion->[2];
    my $finalcosts;
    if ($costs =~ /\$(\d+)/) {
      $finalcosts = $1;
    }
  } elsif ($pred eq "earns") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $tmp = $assertion->[2];
    my $finalcosts;
    if ($tmp =~ /\$(\d+)/) {
      $earnings = $1;
    }
  } elsif ($pred eq "pse-has-property") {
    if ($assertion->[2] eq "very important" or $assertion->[2] eq "important") {
      my $entryname1 = $self->AddEntry
	(
	 Term => $assertion->[1],
	 Type => "goal",
	);
    }
  } elsif ($pred eq "node") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "node",
      );
    if (0) {
      $self->Preferences->{"p-".$entryname1} = 1;
    }
  } elsif ($pred eq "due-date-for-entry") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $dateinformation = $assertion->[2];
  } elsif ($pred eq "start-date") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $dateinformation = $assertion->[2];
    $self->EntryData->{$entryname1}->{"begin-opportunity"} = $dateinformation;
  } elsif ($pred eq "event-duration") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $durationinformation = $assertion->[2];
    $self->EntryData->{$entryname1}->{"opportunity-duration"} = $durationinformation;
  } elsif ($pred eq "end-date") {
    my $entryname1 = $self->AddEntry
      (
       Term => $assertion->[1],
       Type => "goal",
      );
    my $dateinformation = $assertion->[2];
    $self->EntryData->{$entryname1}->{"end-opportunity"} = $dateinformation;
  } else {
    print "Unknown Predicate: $pred\n";
  }
}

sub ProcessAssertionRest {
  my ($self,%args) = @_;
  my @metric;
  # push @metric, ["*","10",["is-violated","b1"]];
  foreach my $pref (keys %{$self->Preferences}) {
    push @metric, ["*","10",["is-violated", $pref]];
  }

  # now update all opportunity windows
  foreach my $entry (keys %{$self->EntryData}) {
    my @missing;
    my @notmissing;
    foreach my $item (qw(begin-opportunity end-opportunity opportunity-duration)) {
      if (! exists $self->EntryData->{$entry}->{$item}) {
	push @missing, $item;
      } else {
	push @notmissing, $item;
      }
    }
    my ($sdt,$edt,$dur);
    if (exists $self->EntryData->{$entry}->{"begin-opportunity"}) {
      # print SeeDumper($self->EntryData->{$entry}->{"begin-opportunity"});
      # my $startepoch = str2time($self->EntryData->{$entry}->{"begin-opportunity"});
      my $startepoch = Date::ICal->new( ical => $self->EntryData->{$entry}->{"begin-opportunity"})->epoch;
      $sdt = DateTime->from_epoch(epoch => $startepoch);
    }
    if (exists $self->EntryData->{$entry}->{"end-opportunity"}) {
      # print SeeDumper($self->EntryData->{$entry}->{"end-opportunity"});
      # my $endepoch = str2time($self->EntryData->{$entry}->{"end-opportunity"});
      my $endepoch = Date::ICal->new( ical => $self->EntryData->{$entry}->{"end-opportunity"})->epoch;
      $edt = DateTime->from_epoch(epoch => $endepoch);
    }
    if (exists $self->EntryData->{$entry}->{"opportunity-duration"}) {
      my %hash = ();
      my $res = $self->MyDateManip->TimeSpecsToDateTimeDuration
	(
	 TimeSpecs => $self->EntryData->{$entry}->{"opportunity-duration"},
	);
      if ($res->{Success}) {
	$dur = $res->{Result};
      } else {
	print "ERROR parsing opportunity-duration\n";
      }
    }
    if (scalar @missing == 2) {
      # chances are this is just an end-opportunity specification
      # set the begin opportunity temporarily to the present time
      my $item = $notmissing[0];
      if ($item eq "end-opportunity") {
	$sdt = $self->MyDateManip->GetCurrentDateTime - DateTime::Duration->new(years => 10);
      } elsif ($item eq "start-opportunity") {
	$edt = $self->MyDateManip->GetCurrentDateTime + DateTime::Duration->new(years => 10);
      } elsif ($item eq "opportunity-duration") {
	
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
      print SeeDumper({Values => [$sdt,$edt,$dur]});
      # if (abs(DateTime::Duration->compare($sdt + $dur,$edt))) {
      # print "Dates do not align!\n";
      # }
    }
    # now that we have sdt and edt, generate statements
  }

  # now print the problem file for now
  my @cycle = $self->DependencyGraph->find_a_cycle;
  if (scalar @cycle) {
    print "Dependency cycle detected (Main)\n";
    print SeeDumper(\@cycle);
  } else {
    print "No dependency cycle found (Main)\n";
  }
}

sub AddEntry {
  my ($self,%args) = @_;
  # print SeeDumper(\%args);
  my $term = $args{Term};
  my $context = $self->Context;
  if (! defined $term or ! defined $term->[0]) {
    warn "Term is not defined\n";
    return;
  }
  if ($term->[0] ne "entry-fn") {
    die "ERROR <".$term->[0].">\n";
  }
  my $entrysource = $term->[1];
  my $entryid = $term->[2];
  my $entry;
  if ($entrysource eq "pse") {
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
  } elsif ($entrysource eq "sayer-index") {
    warn "Not yet implemented\n";
  }
  my $res = $self->AddEntryPart2
    (
     Type => $args{Type},
     Source => $entrysource,
     EntryID => $entryid,
     Description => $entry,
     Term => $term,
     Render => $args{Render},
    );
  return $res->{Name};
}

sub AddEntryPart2 {
  my ($self,%args) = @_;
  my $name = ProcessName(Item => $args{Description});
  # my $name = "entry-".$entryid;
  if (! exists $self->Entries->{$name}) {
    $self->Entries->{$name} = 1;
    my $node = SPSE2::GUI::Tab::View2::Node->new
      (
       Source => $args{Source},
       EntryID => $args{EntryID},
       Description => $args{Description},
       View => $self->MyView2,
      );
    $self->MyView2->MyNodeManager->AddNode
      (
       Node => $node,
      );
    $self->MyView2->AddNode
      (
       Node => $node,
       Term => $args{Term},
       Shape => $self->TypeHash->{$args{Type}},
       Render => $args{Render},
      );
  }
  return {
	  Success => 1,
	  Name => $args{Description},
	  # Node => $node,
	 };
}

sub AddPreference {
  my ($self,$preference) = @_;
  print "Don't know what to do just yet here\n";
}

sub FindOrCreateNodeHelper {
  my ($self,%args) = @_;
  my $description = $args{Description};
  my $res = $self->MyListProcessor->GenerateStatementsAbout
    (
     Render => 1,
     Self => $self,
     Domain => $description,
     ReturnEntries => 1,
     Type => $args{Type},
    );
  print SeeDumper($res);
  if ($res->{Success}) {
    my $res2 = $self->MyView2->ModifyAxiomsCautiously
      (
       Entries => $res->{Entries},
      );
    my @res3;
    foreach my $entry (@{$res->{Entries}}) {
      push @res3, $self->MyView2->MyDomainManager->ProcessAssertions
	(
	 Render => 1,
	 Assertions => $entry->{Assertions},
	);
    }
    print SeeDumper
      ({
	Res2 => $res2,
	Res3 => \@res3,
       });
    if ($res2->{Changes} and ! $args{SkipRedraw}) {
      $self->MyView2->Redraw();
    }
    return $res2->{Changes};
  }
}

sub AgendaEditor {
  my ($self,%args) = @_;
  # open the agenda domain, and allow us to edit it

}

sub QueryCompleted {
  my ($self,%args) = @_;
  # show all the completed goals

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

sub AdjustOverdueGoals {
  my ($self,%args) = @_;
  # FIXME Does this adequately handle class globals?
  $self->MyOverdue(undef);
  $self->MyOverdue
    (SPSE2::GUI::Tab::View2::Domain::Planning::Model::Overdue->new
     (
      MainWindow => $UNIVERSAL::spse2->MyGUI->MyMainWindow,
      View2 => $self->MyView2,
     ));
  $self->MyOverdue->Execute();
  $self->MyOverdue->RefreshDisplay();
}

1;
