package SPSE2::GUI::Tab::View2;

use KBS2::Client;
use KBS2::Util;
use KBS2::Util::Metadata;
use Manager::Dialog qw(Approve ApproveCommands Message QueryUser QueryUser2);
use PerlLib::SwissArmyKnife;
use SPSE2::GUI::Tab::View2::DomainManager;
use SPSE2::GUI::Tab::View2::EditNode;
use SPSE2::GUI::Tab::View2::Edge;
use SPSE2::GUI::Tab::View2::EdgeManager;
use SPSE2::GUI::Tab::View2::Node;
use SPSE2::GUI::Tab::View2::NodeManager;
use SPSE2::GUI::Tab::View2::Info1;
use SPSE2::GUI::Tab::View2::Info2;
use SPSE2::GUI::Tab::View2::Menus;

use Class::ISA;
use GraphViz;
use IO::File;
use Math::Big;
use Text::Wrap;
use Tk;
use Tk::Animation;
use Tk::GraphViz;

use base qw(SPSE2::GUI::Tab);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Attributes Context Count Domains Edges H L LastEvent LastTags
	Marks MyClient MyFrame MyGraph MyGraphViz MyMainWindow MyMenus
	MyTkGraphViz SkipCanvasBind Text Data MyNodeManager
	AlreadyZoomed Debug Database MyInfo MyDomainManager MyMetadata
	Tabname CutoffSize MyEdgeManager DisplayPositions /

  ];

sub init {
  my ($self,%args) = @_;
  # V3

  # Model
  $self->Tabname($args{Tabname});
  $self->Database($args{Database} || "freekbs2");
  $self->MyClient
    (KBS2::Client->new
     (Database => $self->Database));

  $self->CutoffSize(1000);

  # View
  $self->MyFrame($args{Frame});
  $UNIVERSAL::managerdialogtkwindow = $UNIVERSAL::spse2->MyGUI->MyMainWindow;
  $self->MyFrame->pack(-expand => 1, -fill => 'both');
  $self->MyTkGraphViz({});
  $self->MyTkGraphViz->{MainWindow} = $self->MyFrame;
  $self->MyInfo
    (SPSE2::GUI::Tab::View2::Info2->new);
  print SeeDumper([
		$self->MyInfo->FieldMap,
		$self->MyInfo->Attributes,
		$self->MyInfo->BinaryRelationMap,
	       ]) if 0;
  $self->MyDomainManager
    (SPSE2::GUI::Tab::View2::DomainManager->new
     (View2 => $self));
  $self->MyMenus
    (SPSE2::GUI::Tab::View2::Menus->new
     (
      DomainManager => $self->MyDomainManager,
      MainWindow => $self->MyTkGraphViz->{MainWindow},
      View => $self,
      Info => $self->MyInfo,
     ));
  $self->MyMenus->LoadMenus;
  $self->Attributes
    ($self->MyInfo->Attributes);
  $self->SkipCanvasBind(0);
  $self->Domains({});
}

sub Execute {
  my ($self,%args) = @_;
  # V3
  my $context;
  if (exists $args{Flags}) {
    if (exists $args{Flags}->{Context}) {
      $context = $args{Flags}->{Context};
    }
  }
  if (! defined $context) {
    $context = $UNIVERSAL::spse2->Conf->{'-c'} || "Org::FRDCSA::SPSE2::Default";
  }
  $self->SetContext
    (
     Context => $context,
    );
  $self->Generate();
  # $self->FitGraph();
}

sub Display {
  my ($self,%args) = @_;
  # V3
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
  $self->MyGraphViz		# interesting
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
       my $node = $self->GetNodeFromLastTags();
       $self->MyNodeManager->Select
	 (
	  Selection => "Toggle-Union",
	  Node => $node,
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
       my $node = $self->GetNodeFromLastTags();
       $self->MyNodeManager->Select
	 (
	  Selection => "Toggle-Single",
	  Node => $node,
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
  $args{Node}->DisplayData->{Term} = $args{Term};
  $args{Node}->DisplayData->{Shape} = $args{Shape};
  if ($args{Render}) {
    $self->RenderNode(Node => $args{Node});
  }
}

sub RenderNode {
  my ($self,%args) = @_;
  my $label = $args{Node}->NodeInterlinguaDumper; # substr($args{Node}->Description,0,$self->CutoffSize);
  if (! exists $self->Text->{$label}) {
    my $text = $args{Node}->Description;
    my $attributes = {};
    if (1) {
      my $cost = $args{Node}->Costs || '?';
      # if ($args{Node}->Recurring) {
      # 	$cost .= '+';
      # }
      $attributes->{C} = $cost;
    }
    if (scalar %$attributes) {
      $text .= ' '.join(' : ',map {$_.': '.$attributes->{$_}} sort keys %$attributes);
    }
    $self->Text->{$label} = myformat($text);
    $self->Count($self->Count + 1);
    $self->H->{$label} = $self->Count;
    my $nodename = $self->MyGraphViz->add_node
      (
       $self->H->{$label},
       label => $self->Text->{$label},
       shape => $args{Node}->DisplayData->{Shape} || "octagon",
       style => 'filled',
       color => $self->GetColorForMarks(Term => $args{Node}->DisplayData->{Term}),
       fillcolor => $self->GetFillColorForMarks(Term => $args{Node}->DisplayData->{Term}),
      );
    $args{Node}->GraphVizNode($nodename);
  }
}

sub AddEdge {
  my ($self,%args) = @_;
  # print SeeDumper(\%args);
  my $entryname1 = $args{EN1};
  my $entryname2 = $args{EN2};

  # my $label1 = substr($entryname1,0,$self->CutoffSize);
  # my $label2 = substr($entryname2,0,$self->CutoffSize);

  my $node1 = $self->MyNodeManager->GetNode(Description => $entryname1);
  my $node2 = $self->MyNodeManager->GetNode(Description => $entryname2);
  my $edge = SPSE2::GUI::Tab::View2::Edge->new
    (
     Node1 => $node1->[0],
     Node2 => $node2->[0],
    );
  $self->MyEdgeManager->AddEdge(Edge => $edge);

  my $label1 = $node1->[0]->NodeInterlinguaDumper;
  my $label2 = $node2->[0]->NodeInterlinguaDumper;

  print SeeDumper
    (
     labe11 => $label1,
     labe12 => $label2,
     $self->H,
    ) if 0;
  $edge->DisplayData->{Label1} = $label1;
  $edge->DisplayData->{Label2} = $label2;
  $edge->DisplayData->{Label} = $args{Pred};
  $edge->DisplayData->{Color} = $self->Attributes->{$args{Pred}}->{Color};
  if (exists $self->Attributes->{$args{Pred}}->{Style}) {
    $edge->DisplayData->{Style} = $self->Attributes->{$args{Pred}}->{Style};
  }
  if ($args{Render}) {
    $self->RenderEdge(Edge => $edge);
  }
}

sub RenderEdge {
  my ($self,%args) = @_;
  # FIXME: add a check for an edge already here

  my %addedgeargs =
    (
     label => $args{Edge}->DisplayData->{Label},
     color => $args{Edge}->DisplayData->{Color},
    );
  if (exists $args{Edge}->DisplayData->{Style}) {
    $addedgeargs{style} = $args{Edge}->DisplayData->{Style};
  }
  $self->MyGraphViz->add_edge
    (
     $self->H->{$args{Edge}->DisplayData->{Label1}} => $self->H->{$args{Edge}->DisplayData->{Label2}},
     %addedgeargs,
    );
}

sub RemoveEdge {
  my ($self,%args) = @_;
  my $entryname1 = $args{EN1};
  my $entryname2 = $args{EN2};
  my $label1 = substr($entryname1,0,$self->CutoffSize);
  my $label2 = substr($entryname2,0,$self->CutoffSize);

  print SeeDumper
    ([
      $args{Relations},
      ["entry-fn", "pse", $self->Data->{iNL}->{$entryname1}],
      ["entry-fn", "pse", $self->Data->{iNL}->{$entryname2}],
     ]) if 0;

  #   # need to find the depends item, etc
  #   print SeeDumper
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
  $self->MyNodeManager
    (SPSE2::GUI::Tab::View2::NodeManager->new);
  $self->MyEdgeManager
    (SPSE2::GUI::Tab::View2::EdgeManager->new);
  $self->Marks({});

  my $context = $self->Context;
  $self->MyMetadata
    (KBS2::Util::Metadata->new
     (
      Context => $self->Context,
      Assertions => [],
      # Debug => 1,
     ));
  $self->MyMetadata->LoadMetadata();
  my $assertions = $self->GetAllAssertions();
  $self->MyMetadata->ProcessAssertions
    (
     Assertions => $assertions,
    );

  $self->MyDomainManager->Generate
    (
     Assertions => $assertions,
    );

  $self->RenderGraph();
}

# MISC

sub GetAllAssertions {
  my ($self,%args) = @_;
  my $assertions = [];
  do {
    my $message = $self->MyClient->Send
      (
       QueryAgent => 1,
       Command => "all-asserted-knowledge",
       Context => $self->Context,
      );
    if (defined $message) {
      $assertions = $message->{Data}->{Result};
      if (! scalar @$assertions) {
	# go ahead and assert a node to remove this node
	if (1) {
	  my $res = $self->ModifyAxiomsCautiously
	    (
	     Entries => [{
			  Assertions => [
					 ["frdcsa-context-type","SPSE"],
					 ["has-NL", ["entry-fn","pse","1"], "Remove this node"],
					 ["goal", ["entry-fn","pse","1"]],
					 ["asserter", ["entry-fn", "pse", "1"], "unknown"],
					 # 					 ["has-NL", ["entry-fn","pse","2"], "Remove this node 2"],
					 # 					 ["goal", ["entry-fn","pse","2"]],
					 # 					 ["asserter", ["entry-fn", "pse", "2"], "unknown"],
					 # 					 ["depends", ["entry-fn", "pse", "1"], ["entry-fn", "pse", "2"]],
					],
			  Functions => [
					sub {
					  $self->DefaultDomain->Model->MyListProcessor->GetPSEEntryIDCounter;
					},
				       ],
			 }],
	    );
	} else {
	  # FIXME
	  $self->DefaultDomain->Model->FindOrCreateNodeHelper
	    (
	     Description => "Remove this node",
	     SkipRedraw => 1,
	     SkipUsual => 1,
	    );
	}
      }
    } else {
      die "ERROR: Cannot query KB correctly\n";
    }
  } while (! scalar @$assertions);
  return $assertions;
}

sub Check {
  my ($self,%args) = @_;

}

sub SetLastTags {
  my ($self,%args) = @_;
  my @lasttags = $self->MyTkGraphViz->{Scrolled}->gettags('current');
  pop @lasttags;
  $self->LastTags({@lasttags});
}

sub GetNodeFromLastTags {
  my ($self,%args) = @_;
  my $node = $self->LastTags->{node};
  $node =~ s/^node//;
  my $res = $self->MyNodeManager->GetNode
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
  $UNIVERSAL::spse2->MyGUI->MyTabManager->MyNoteBook->{_pages_}->{$self->Tabname}->configure
    (
     -label => "View: ".$args{Context},
    );
  $self->MyDomainManager->SetContext
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
    print SeeDumper($self->Context);
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

sub RemoveSelectedNodes {
  my ($self,@tmp) = @_;
  if (Approve("Remove Selected Nodes?")) {
    my $res = $self->MyNodeManager->GetNode
      (
       Selected => 1,
      );
    my @unassertions;
    my $allassertions = $self->GetAllAssertions;
    foreach my $node (@$res) {
      my $unassert = $self->GetAllReferringAssertions
	(
	 Node => $node->NodeInterlingua,
	 Assertions => $allassertions,
	);
      push @unassertions, @$unassert;
    }
    my $res = $self->ModifyAxiomsCautiously
      (
       Entries => [{
		    Unassertions => \@unassertions,
		   }],
      );
    if ($res->{Changes}) {
      $self->Generate();
    }
  }
}

sub RemoveNode {
  my ($self,@tmp) = @_;
  if (Approve("Remove Node?")) {
    my $node = $self->GetNodeFromLastTags;
    # find all the relations it is part of, remove those first
    # then remove the node
    my $interlingua = $node->NodeInterlingua;

    # find all entries that make reference to this node
    my $unassert = $self->GetAllReferringAssertions(Node => $interlingua);

    # prompt the user for the removal of these
    my $res = $self->ModifyAxiomsCautiously
      (
       Entries => [{
		    Unassertions => $unassert,
		   }],
      );
    if ($res->{Changes}) {
      $self->Generate();
    }
  }
}

sub GetAllReferringAssertions {
  my ($self,%args) = @_;
  return GetAllReferringFormulae
    (
     Formulae => ($args{Assertions} || $self->GetAllAssertions()),
     Subformula => $args{Node},
    );
}

sub ModifyUnaryRelation {
  my ($self,%args) = @_;
  print Dumper(\%args);
  my $predicate = lc($args{Predicate});
  my $res;
  if (exists $args{Term}) {
    $res = $self->MyNodeManager->GetNode
      (
       NodeInterlingua => $args{Term},
      );
  } else {
    $res = $self->MyNodeManager->GetNode
      (
       Selected => 1,
      );
  }
  my @entries;
  foreach my $node (@$res) {
    my $relation = [$predicate, $node->NodeInterlingua];
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
	     Term => $node->NodeInterlingua,
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
					 Term => $node->NodeInterlingua,
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
  my $res = $self->MyNodeManager->GetNode
    (
     Selected => 1,
    );
  my $last = pop @$res;
  my $item = $relationmap->{$args{Relation}};
  my @entries;
  foreach my $node (@$res) {
    my $relation = [$item->{Predicate}];
    my $edge =
      {
       Self => $self,
      };
    if (exists $item->{Order} and $item->{Order} eq "inverse") {
      push @$relation, $last->NodeInterlingua, $node->NodeInterlingua;
      $edge->{EN1} = $last->Description;
      $edge->{EN2} = $node->Description;
    } else {
      push @$relation, $node->NodeInterlingua, $last->NodeInterlingua;
      $edge->{EN1} = $node->Description;
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
		      Functions => [sub {$self->AddEdge
					   (
					    Render => 1,
					    %$edge,
					   )}],
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
				    sub {$self->Generate()},
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
  $self->CenterCanvasWindowOnNode
    (
     Node => $last,
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
  # grab all the nodes from the selection
  my $nodes = $self->MyNodeManager->GetNode
    (
     Selected => 1,
    );
  my $size = scalar @$nodes;
  if ($size == 1) {
    # obtain the original value for that field for that node
    my $node = $nodes->[0];
    my $entry;
    my $match;
    my $object = $self->MyClient->Send
      (
       QueryAgent => 1,
       InputType => "Interlingua",
       Query => [[$field,$node->NodeInterlingua,\*{'::?NatLang'}]],
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
       Message => "Edit the field <$field> for <".Dumper($node->NodeInterlingua).">",
       DefaultValue => $entry,
      );
    # now unassert any existing value
    if (! $res->{Cancel}) {
      if ($match) {
	# unassert it
      }
      # now assert it
      push @unassert, [$field, $node->NodeInterlingua, \*{'::?NatLang'}];
      push @assert, [$field, $node->NodeInterlingua, $res->{Value}];
    }
  } elsif ($size > 1) {
    my $res = QueryUser2
      (
       Message => "Edit the field <$field> for $size selected node(s)",
       DefaultValue => $entry,
      );
    # just get the new value for the field
    if (! $res->{Cancel}) {
      foreach my $node (@$nodes) {
	push @unassert, [$field, $node->NodeInterlingua,\*{'::?NatLang'}];
	push @assert, [$field, $node->NodeInterlingua, $res->{Value}];
      }
      # iterate over all nodes and set the value of that field to that
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
  # try to assert all the nodes
  #  if a given node cannot be asserted, see if we should unasserted
  #  either it, or any of it's negation-invariants
  #  prompt the user for any non-monotonic changes to the KB
  # finish asserting all nodes

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
      print SeeDumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print SeeDumper($res);
      $changes = 1;

      # go ahead and update the metadata with this unassertion
      $self->MyMetadata->ProcessUnassertions
	(
	 Unassertions => [$unassertion],
	);
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
      print SeeDumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print SeeDumper($res);
      $changes = 1;

      # go ahead and update the metadata with this new assertion
      $self->MyMetadata->ProcessAssertions
	(
	 Assertions => [$assertion],
	);
    }
    foreach my $function (@{$entry->{Functions}}) {
      print SeeDumper($function->());
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
  $self->MyNodeManager->Select(%args);
  $self->Redraw();
}

# DISPLAY OPERATIONS

sub GetColorForMarks {
  my ($self,%args) = @_;
  my $dumperterm = Dumper($args{Term});
  if (exists $self->Marks->{$dumperterm}) {
    # print "HOW 1\n";
    # print Dumper($self->Marks->{$dumperterm});
    if (exists $self->Marks->{$dumperterm}->{completed}) {
      # print "HOW 2\n";
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
    if (exists $self->Marks->{$dumperterm}->{shoppinglist}) {
      if ($args{Selected}) {
	return "seagreen";		# dark green
      } else {
	return "mediumseagreen";	# light green
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
    foreach my $predicate
      (sort {$self->MyInfo->GetPriorityForUnaryPredicate(Predicate => $a) <=>
	       $self->MyInfo->GetPriorityForUnaryPredicate(Predicate => $b)}
       keys %{$self->Marks->{$dumperterm}}) {
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

sub RenderGraph {
  my ($self,%args) = @_;
  $self->AlreadyZoomed(0);
  $self->Text({});
  $self->H({});
  $self->L({});
  $self->Count(0);
  $self->MakeGraphViz;

  # iterate over all the nodes in the node manager
  # reset everything up here
  my $res1 = $self->MyNodeManager->GetNode
    (
     All => 1,
    );
  foreach my $node (@$res1) {
    if (! $node->IsHidden) {
      $self->RenderNode(Node => $node);
    }
  }
  my $res2 = $self->MyEdgeManager->GetEdge
    (
     All => 1,
    );
  foreach my $edge (@$res2) {
    if (! $edge->IsHidden) {
      $self->RenderEdge(Edge => $edge);
    }
  }
  $self->Display();
}

sub Show {
  my ($self,%args) = @_;
  my $graphviz = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{scrolled};
  my $scaledbefore = $graphviz->{_scaled};
  my @x = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->get();
  my @y = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->show( $self->MyGraphViz ) if ! $args{SkipReshow};
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
  foreach my $node ($self->MyNodeManager->Nodes->Values) {
    $self->MyGraphViz->{NODES}->{$node->GraphVizNode}->{fillcolor} = $self->GetFillColorForMarks
      (
       Selected => $node->Selected,
       Term => $node->NodeInterlingua,
      );
  }
  $self->Show();
}

sub Recenter {
  my ($self,%args) = @_;
  $self->MyTkGraphViz->{Scrolled}->fit();
}

sub FitGraph {
  my ($self,%args) = @_;
  $self->MyTkGraphViz->{Scrolled}->fit();
}

sub DisplayOptions {
  my ($self,%args) = @_;
  # for now just hard code it
}

sub CenterCanvasWindowOnNode {
  my ($self,%args) = @_;
  # find the coordinates of this and set the canvas to it
  print "<should find node: $description>\n" if $self->Debug;
  my $res = $args{Node}->DisplayPosition
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
  print SeeDumper(\%args) if $self->Debug;
  my $canvas = $self->MyTkGraphViz->{Scrolled};
  my ($x1,$x2) = $canvas->xview;
  my $xrange = abs($x2 - $x1);
  my ($y1,$y2) = $canvas->yview;
  my $yrange = abs($y2 - $y1);
  print SeeDumper($xrange,$yrange) if $self->Debug;
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
  my @matchingnodes;
  if ($regex) {
    foreach my $node ($self->MyNodeManager->Nodes->Values) {
      if ($node->Description =~ /$regex/i) {
	if (! $self->MyNodeManager->Skip
	    (
	     Skip => $args{Skip},
	     Node => $node,
	    )) {
	  # also, add this 
	  push @matchingnodes, $node;
	}
      }
    }
  }
  if (scalar @matchingnodes) {
    if (0) {
      SubsetSelect
	(
	 Set => \@matchingnodes,
	 Selection => {},
	);
    } else {
      my $description = Choose2
	(
	 List => [sort map {$_->Description} @matchingnodes],
	 Wrap => 1,
	 Cancel => 1,
	);
      if ($description) {
	# select this node and move the screen to center on it
	my $res = $self->MyNodeManager->GetNode
	  (
	   Description => $description,
	  );
	my $lastnode;
	foreach my $node (@$res) {
	  $self->MyNodeManager->AddNodeToSelection(Node => $node);
	  $lastnode = $node;
	}
	# now redraw
	$self->Redraw();
	$self->CenterCanvasWindowOnNode
	  (
	   Node => $lastnode,
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
  system "emacsclient.emacs22 /var/lib/myfrdcsa/codebases/minor/spse/SPSE2/GUI/Tab/View2.pm &";
}

sub ActionScreenshot {
  my ($self,%args) = @_;
  # show all the completed nodes

  # get the dot file and dump it, then render it to an image file with
  # graphviz

  my $dotfile = "spse2.dot";
  my $jpgfile = "spse2.jpg";
  my $fh = IO::File->new();
  $fh->open(">$dotfile") or warn "cannot open out file: $dotfile\n";
  print $fh join("\n", @{$self->MyTkGraphViz->{Scrolled}->{SubWidget}->{scrolled}->{layout}});
  $fh->close();
  system "dot ".shell_quote($dotfile)." -Tjpeg > ".shell_quote($jpgfile);
  # system "rm ".shell_quote($dotfile);
}


# WINDOWS THAT ARE LAUNCHED

sub FindOrCreateNode {
  my ($self,%args) = @_;
  my $editnode = SPSE2::GUI::Tab::View2::EditNode->new
    (
     MainWindow => $UNIVERSAL::spse2->MyGUI->MyMainWindow,
     View => $self,
    );
}

sub EditNode {
  my ($self,%args) = @_;
  my $node = $args{Node} || $self->GetNodeFromLastTags;
  my $editnode = SPSE2::GUI::Tab::View2::EditNode->new
    (
     View => $self,
     MainWindow => $UNIVERSAL::spse2->MyGUI->MyMainWindow,
     Node => $node,
     Attribute => $args{Attribute},
    );
  $editnode->Execute();
}

sub BackupAndRestore {
  my ($self,%args) = @_;
  print "Not yet implemented\n";
  # should add this to many applications.
}

sub DefaultDomain {
  my ($self,%args) = @_;
  return $self->MyDomainManager->MyDomains->Contents->{$self->MyDomainManager->DefaultDomainName};
}

sub EditPointNode {
  my ($self,%args) = @_;
  my $res = $self->MyNodeManager->GetNode
    (
     Point => 1,
    );
  if (scalar @$res) {
    $self->EditNode
      (
       Node => $res->[0],
       Attribute => $args{Attribute},
      );
  } else {
    # complain about it here
  }
}

sub ScrollDown {
  my ($self,%args) = @_;
  my @y = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->set($y[1], $y[1] + ($y[1]-$y[0]));
  $self->Show(SkipReshow => 1);
}

sub ScrollUp {
  my ($self,%args) = @_;
  my @y = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->set($y[0] - ($y[1]-$y[0]), $y[0]);
  $self->Show(SkipReshow => 1);
}

sub ScrollRight {
  my ($self,%args) = @_;
  my @x = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->set($x[1], $x[1] + ($x[1]-$x[0]));
  $self->Show(SkipReshow => 1);
}

sub ScrollLeft {
  my ($self,%args) = @_;
  my @x = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->set($x[0] - ($x[1]-$x[0]), $x[0]);
  $self->Show(SkipReshow => 1);
}

sub BeginningOfContextVertical {
  my ($self,%args) = @_;
  my @y = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->set(0, ($y[1]-$y[0]));
  $self->Show(SkipReshow => 1);
}

sub EndOfContextVertical {
  my ($self,%args) = @_;
  my @y = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{yscrollbar}->set(1 - ($y[1]-$y[0]), 1);
  $self->Show(SkipReshow => 1);
}

sub BeginningOfContextHorizontal {
  my ($self,%args) = @_;
  my @x = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->set(0, ($x[1]-$x[0]));
  $self->Show(SkipReshow => 1);
}

sub EndOfContextHorizontal {
  my ($self,%args) = @_;
  my @x = $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->get();
  $self->MyTkGraphViz->{Scrolled}->{SubWidget}->{xscrollbar}->set(1 - ($x[1]-$x[0]), 1);
  $self->Show(SkipReshow => 1);
}

sub RunCommandOnRegion {
  my ($self,%args) = @_;
  # what command are we going to run?
  my $res = $self->MyNodeManager->GetNode
    (
     Selected => 1,
    );
  foreach my $node (@$res) {
    # run the command on it
  }
}

sub NarrowToRegion {
  my ($self,%args) = @_;
  # remove from display all nodes that are not selected
  my $res = $self->MyNodeManager->GetNode
    (
     Unselected => 1,
    );
  foreach my $node (@$res) {
    # print "Hiding: ".$node->NodeInterlinguaDumper."\n";
    $node->Hidden(1);
  }
  $self->RenderGraph();
}

sub Widen {
  my ($self,%args) = @_;
  # remove from display all nodes that are not selected
  my $res = $self->MyNodeManager->GetNode
    (
     All => 1,
    );
  foreach my $node (@$res) {
    $node->Hidden(0);
  }
  $self->RenderGraph();
}

sub BuildDisplayPositionTable {
  my ($self,%args) = @_;
  my $res = $self->MyNodeManager->GetNode
    (
     All => 1,			# change to visible when that is implemented
    );
  $self->DisplayPositions({});
  foreach my $node (@$res) {
    my $res2 = $node->DisplayPosition
      (
       TkGraphViz => $self->MyTkGraphViz->{Scrolled},
      );
    if ($res2->{Success}) {
      $self->DisplayPositions->{$node} = [$res2->{X},$res2->{Y}];
    }
  }
}

sub GetDir {
  my ($self,%args) = @_;
  my $dx = $args{Dx};
  my $dy = $args{Dy};
  if ($dx == 0 and $dy == 0) {
    return "center";
  }
  if ($dx > 0) {
    if (abs($dx) >= abs($dy)) {
      return "right";
    }
  }
  if ($dx < 0) {
    if (abs($dx) >= abs($dy)) {
      return "left";
    }
  }
  if ($dy > 0) {
    if (abs($dy) >= abs($dx)) {
      return "up";
    }
  }
  if ($dy < 0) {
    if (abs($dy) >= abs($dx)) {
      return "down";
    }
  }
  print "Error with dirs!\n";
  print SeeDumper(%args);
}

sub OldGetDir {
  my $angle;
  my $pi = pi(8);
  if ($distance > 0) {
    if ($dx == 0) {
      if ($dy > 0) {
	$angle = 0;
      } elsif ($dy < 0) {
	$angle = $pi;
      }
    } else {
      if ($dx < 0) {
	$angle = arctan($dy/$dx,8) + $pi;
      } else {
	$angle = arctan($dy/$dx,8);
      }
    }
  }
  my $dir;
  if ($angle < 0.25 * $pi or $angle > 1.75 * $pi) {
    $dir = "up";
  }
  if ($angle >= 0.25 * $pi and $angle < 0.75 * $pi) {
    $dir = "right";
  }
  if ($angle >= 0.75 * $pi and $angle < 1.25 * $pi) {
    $dir = "down";
  }
  if ($angle >= 1.25 * $pi and $angle < 1.75 * $pi) {
    $dir = "left";
  }
}

sub GetDirectionsAndDistances {
  my ($self,%args) = @_;
  my @res;
  my $node1 = $args{Node};
  my $n1p = $self->DisplayPositions->{$node1};
  foreach my $node2 (@{$args{Nodes}}) {
    my $n2p = $self->DisplayPositions->{$node2};
    my $dx = $n2p->[0] - $n1p->[0];
    my $dy = $n2p->[1] - $n1p->[1];
    my $distance = sqrt($dx * $dx + $dy * $dy);
    my $dir = $self->GetDir(Dx => $dx, Dy => $dy);
    push @res, {
		Dir => $dir,
		Distance => $distance,
		Dx => $dx,
		Dy => $dy,
		Node => $node2,
	       };
  }
  return \@res;
}

sub GetNearestInParticularDirection {
  my ($self,%args) = @_;
  my $distances = {};
  foreach my $data (@{$args{Data}}) {
    if ($data->{Dir} eq $args{Direction}) {
      $distances->{$data->{Node}} = $data->{Distance};
    }
  }

  return [sort {$distances->{$a} <=> $distances->{$b}} keys %$distances]->[0];
}

sub GetNearest {
  my ($self,%args) = @_;
  # for now use the selection because I don't feel like implementing
  # the mark and point just yet
  $self->BuildDisplayPositionTable();
  my $res1 = $self->MyNodeManager->GetNode
    (
     Selected => 1,
    );
  my $res2 = $self->MyNodeManager->GetNode
    (
     All => 1,
    );
  my $res3 = $self->GetDirectionsAndDistances
    (
     Node => $res1->[0],
     Nodes => $res2,
    );
  my $node = $self->GetNearestInParticularDirection
    (
     Data => $res3,
     Direction => $args{Direction},
    );
  return
    {
     CurrentNode => $res1->[0],
     ClosestNode => $node,
    };
}

sub MovePoint {
  my ($self,%args) = @_;
  my $res = $self->GetNearest(Direction => $args{Direction});
  # print SeeDumper($res);
  # SPSE2::GUI::Tab::View2::Node=HASH(0x81127d0)
  my $currentnode = $self->MyNodeManager->GetNode(Reference => $res->{CurrentNode});
  my $closestnode = $self->MyNodeManager->GetNode(Reference => $res->{ClosestNode});
  $self->MyNodeManager->RemoveNodeFromSelection
    (
     Node => $currentnode,
    );
  $self->MyNodeManager->AddNodeToSelection
    (
     Node => $closestnode,
    );
  $self->Redraw();
}

sub MoveToNextNodeVertical {
  my ($self,%args) = @_;
  $self->MovePoint(Direction => "down");
}

sub MoveToPreviousNodeVertical {
  my ($self,%args) = @_;
  $self->MovePoint(Direction => "up");
}

sub MoveToNextNodeHorizontal {
  my ($self,%args) = @_;
  $self->MovePoint(Direction => "right");
}

sub MoveToPreviousNodeHorizontal {
  my ($self,%args) = @_;
  $self->MovePoint(Direction => "left");
}

sub LoadDotDoFile {
  my ($self,%args) = @_;
  $self->DefaultDomain->Model->LoadDotDoFile();
}

1;

# if (1) {
#   my $i = 1;
#   foreach my $predicate (@{$self->MyInfo->BinaryPredicates}) {
#     push @or, [$predicate,$interlingua,Var("?X$i")];
#     ++$i;
#     push @or, [$predicate,Var("?X$i"),$interlingua];
#     ++$i;
#   }
#   if (0) {
#     foreach my $predicate (@{$self->MyInfo->UnaryPredicates}) {
# 	push @or, [$predicate,$interlingua];
#     }
#   }
# } else {
#   push @or, ["depends",$i,Var("?X1")];
#   push @or, ["depends",Var("?X2"),$i];
# }
# my $removalformula = ["or",@or,];
# my $object = $self->MyClient->Send
#   (
#    QueryAgent => 1,
#    InputType => "Interlingua",
#    Query => [$removalformula],
#    Context => $self->Context,
#    ResultType => "object",
#   );
# print SeeDumper($object->Bindings);
