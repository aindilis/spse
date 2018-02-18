package SPSE2::GUI;

use KMax::Util::KeyBindings;
use KMax::Util::Minibuffer;
use Manager::Dialog qw(Approve ApproveCommands Choose2 Message QueryUser2);
use PerlLib::SwissArmyKnife;
use SPSE2::GUI::TabManager;
use SPSE2::GUI::Util::TextWindow;

use Tk::Menu;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow MyTabManager DomainMenus UseView2 MyMinibuffer
	MyKeyBindings UnmaximizedGeometry /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMainWindow
    ($args{MyMainWindow});
  $UNIVERSAL::managerdialogtkwindow = $self->MyMainWindow;
  $self->UseView2
    ($args{SPSE2}->Conf->{'--view2'});
  $self->LoadMenus();
  $self->MyTabManager
    (SPSE2::GUI::TabManager->new
     ());
  $self->MyMinibuffer
    (KMax::Util::Minibuffer->new
     (Frame => $self->MyMainWindow));
  $self->MyKeyBindings
    (KMax::Util::KeyBindings->new
     (
      KeyBindingsFile => "/var/lib/myfrdcsa/codebases/minor/spse/systems/keybindings/keybindings-spse-official.txt",
      MyGUI => $self,
     ));
  $self->MyKeyBindings->GenerateGUI
    (
     MyMainWindow => $self->MyMainWindow,
     Minibuffer => $self->MyMinibuffer,
    );
}

sub Execute {
  my ($self,%args) = @_;
  $self->MyTabManager->Execute
    (MyMainWindow => $self->MyMainWindow);
}

sub LoadMenus {
  my ($self,%args) = @_;
  $menu = $self->MyMainWindow->Frame(-relief => 'raised', -borderwidth => '1');
  $menu->pack(-side => 'top', -fill => 'x');
  $menu_file = $menu->Menubutton
    (
     -text => 'File',
     -tearoff => 0,
     -underline => 0,
    );

  $self->DomainMenus({});

  $self->DomainMenus->{menu_file_domainmenu} = $menu_file->cascade
    (
     -label => 'Domain',
     -tearoff => 0,
    );

  my $loadmenu = $menu_file->cascade
    (
     -label => 'Load Context',
     -tearoff => 0,
    );

  my $currenttabmenu = $loadmenu->cascade
    (
     -label => 'In Current Tab',
     -tearoff => 0,
    );

  my $newtabmenu = $loadmenu->cascade
    (
     -label => 'In New Tab',
     -tearoff => 0,
    );

  $currenttabmenu->command
    (
     -label => "*** Create New Context ***",
     -command => sub {
       my $res = QueryUser2
	 (
	  Title => "Create New Context",
	  Message => "What is the new context's name?",
	 );
       if (! $res->{Cancel}) {
	 if ($res->{Value} =~ /./) {
	   my $match = 0;
	   foreach my $context (@set) {
	     if ($res->{Value} eq $context) {
	       $match = 1;
	       last;
	     }
	   }
	   if (! $match) {
	     # we can go ahead and open a new context in the current window
	     $self->GetCurrentTab->LoadContext
	       (Context => $res->{Value});
	   }
	 }
       }
     }
    );
  $newtabmenu->command
    (
     -label => "*** Create New Context ***",
     -command => sub {
       my $res = QueryUser2
	 (
	  Title => "Create New Context",
	  Message => "What is the new context's name?",
	 );
       if (! $res->{Cancel}) {
	 if ($res->{Value} =~ /./) {
	   my $match = 0;
	   foreach my $context (@set) {
	     if ($res->{Value} eq $context) {
	       $match = 1;
	       last;
	     }
	   }
	   if (! $match) {
	     # we can go ahead and create
	     $self->MyTabManager->CreateNewTab
	       (
		Module => "View2",
		Flags => {
			  Context => $res->{Value},
			 },
	       );
	   }
	 }
       }
     },
    );


  my $c = `kbs2 -l`;
  my @set = split /\n/, $c;
  # create a hierarchy of these, based on namespace breakdown

  my $menus = {};
  my $contexts = {};
  foreach my $context (sort @set) {
    $contexts->{$context} = 1;
    my @items = split /::/,$context;
    my @tree = ();
    my @last = ();
    while (@items) {
      my $item = shift @items;
      push @tree, $item;
      my $current = join("::",@tree);
      if (@items) {
	# means it's a node, not a leaf
	my $label;
	if (exists $contexts->{$current}) {
	  $label = "$current (n)";
	} else {
	  $label = $current;
	}
	if (! exists $menus->{$current}) {
	  if (! @last) {
	    # add a menu node under the root menu node
	    $menus->{$current} = $newtabmenu->cascade
	      (
	       -label => $label,
	       -tearoff => 0,
	      );
	    $menus2->{$current} = $currenttabmenu->cascade
	      (
	       -label => $label,
	       -tearoff => 0,
	      );
	  } else {
	    # add a menu node under the last menu node
	    $menus->{$current} = $menus->{$last[-1]}->cascade
	      (
	       -label => $label,
	       -tearoff => 0,
	      );
	    $menus2->{$current} = $menus2->{$last[-1]}->cascade
	      (
	       -label => $label,
	       -tearoff => 0,
	      );
	  }
	}
      } else {
	# means it's a leaf
	# add a leaf node under the root menu node
	if (! exists $menus->{$current}) {
	  # add a leaf node under the last menu node
	  if (! @last) {
	    $newtabmenu->command
	      (
	       -label => $context,
	       -command => sub {
		 $self->MyTabManager->CreateNewTab
		   (
		    Module => "View2",
		    Flags => {
			      Context => $context,
			     },
		   );
	       },
	      );
	    $currenttabmenu->command
	      (
	       -label => $context,
	       -command => sub {
		 $self->GetCurrentTab->LoadContext
		   (Context => $context);
	       },
	      );
	  } else {
	    $menus->{$last[-1]}->command
	      (
	       -label => "$context",
	       -command => sub {
		 $self->MyTabManager->CreateNewTab
		   (
		    Module => "View2",
		    Flags => {
			      Context => $context,
			     },
		   );
	       },
	      );
	    $menus2->{$last[-1]}->command
	      (
	       -label => "$context",
	       -command => sub {
		 $self->GetCurrentTab->LoadContext
		   (Context => $context);
	       },
	      );
	  }
	}
      }
      push @last, $current;
    }
  }



  $menu_file->command
    (
     -label => 'Import .do File',
     -command => sub {
       $self->GetCurrentTab->LoadDotDoFile();
     },
    );

  $menu_file->command
    (
     -label => 'Export KBS',
     -command => sub {
       $self->GetCurrentTab->ExportKBS();
     },
    );
  $menu_file->command
    (
     -label => 'Import KBS',
     -command => sub {
       $self->GetCurrentTab->ImportKBS();
     },
    );
  $menu_file->command
    (
     -label => 'Backup and Restore',
     -command => sub {
       $self->GetCurrentTab->BackupAndRestore();
     },
    );
  $menu_file->command
    (
     -label => 'Exit',
     -command => sub {
       $self->Exit();
     },
    );
  $menu_file->pack
    (
     -side => 'left',
    );

  ############################################################

  $menu_select = $menu->Menubutton
    (
     -text => 'Select',
     -tearoff => 0,
     -underline => 0,
    );


  $self->DomainMenus->{menu_select_domainmenu} = $menu_select->cascade
    (
     -label => 'Domain',
     -tearoff => 0,
    );

  foreach my $action ("All","None","Invert","By Search","By Regex","By Similarity","By Entailment") {
    $menu_select->command
      (
       -label => $action,
       -command => sub {
	 $self->GetCurrentTab->Select
	   (Selection => $action);
       },
      );
  }
  $menu_select->pack
    (
     -side => 'left',
    );

  ############################################################

  $menu_view = $menu->Menubutton
    (
     -text => 'View',
     -tearoff => 0,
     -underline => 0,
    );
  $menu_view->command
    (
     -label => 'Display Options',
     -command => sub {
       $self->GetCurrentTab->DisplayOptions();
     },
    );
  $menu_view->command
    (
     -label => 'Fit Graph',
     -command => sub {
       $self->GetCurrentTab->FitGraph();
     },
    );
  $menu_view->command
    (
     -label => 'Redraw',
     -command => sub {
       $self->GetCurrentTab->Redraw();
     },
    );
  $menu_view->pack
    (
     -side => 'left',
    );

  ############################################################

  $menu_action = $menu->Menubutton
    (
     -text => 'Action',
     -tearoff => 0,
     -underline => 0,
    );

  $self->DomainMenus->{menu_action_domainmenu} = $menu_action->cascade
    (
     -label => 'Domain',
     -tearoff => 0,
    );

  $menu_action->command
    (
     -label => 'Screenshot',
     -command => sub {
       $self->GetCurrentTab->ActionScreenshot();
     },
     -underline => 0,
    );

  $menu_action->command
    (
     -label => "Edit Source",
     -command => sub {
       $self->GetCurrentTab->EditSource();
     },
     -underline => 0,
    );
  $menu_action->pack
    (
     -side => 'left',
    );

  ############################################################

  $menu_analysis = $menu->Menubutton
    (
     -text => 'Analysis',
     -tearoff => 0,
     -underline => 0,
    );


  $self->DomainMenus->{menu_analysis_domainmenu} = $menu_analysis->cascade
    (
     -label => 'Domain',
     -tearoff => 0,
    );

  $menu_analysis->pack
    (
     -side => 'left',
    );

  ############################################################

  $menu_help = $menu->Menubutton
    (
     -text => 'Help',
     -tearoff => 0,
     -underline => 0,
    );
  $menu_help->command
    (
     -label => 'Contents',
     -command => sub {

     },
     -underline => 0,
    );
  $menu_help->command
    (
     -label => 'About',
     -command => sub {

     },
     -underline => 0,
    );
  $menu_help->command
    (
     -label => 'Dump GraphViz Object',
     -command => sub {
       print SeeDumper
	 ($self->GetCurrentTab->MyTkGraphViz->{Scrolled});
     },
     -underline => 0,
    );

  $menu_help->pack
    (
     -side => 'left',
    );

  ############################################################

}

sub GetCurrentTab {
  my ($self,%args) = @_;
  return $self->MyTabManager->Tabs->{$self->MyTabManager->MyNoteBook->raised()};
}

sub Exit {
  my ($self,%args) = @_;
  if (1) {
    my $dialog = $UNIVERSAL::managerdialogtkwindow->Dialog
      (
       -text => "Please Choose",
       -buttons => ["Exit", "Restart", "Reinvoke", "Cancel"],
      );
    my $res = $dialog->Show;
    if ($res eq "Exit") {
      exit(0);
    } elsif ($res eq "Restart") {
      # kill it and start a new one
      system "(sleep 1; /var/lib/myfrdcsa/codebases/minor/spse/spse2) &";
      exit(0);
    } elsif ($res eq "Reinvoke") {
      # kill it and start a new one
      my $cli = GetCommandLineForCurrentProcess();
      system "(sleep 1; cd /var/lib/myfrdcsa/codebases/minor/spse && $cli) &";
      exit(0);
    } elsif ($res eq "Cancel") {
      # do nothing
    }
  } else {
    if (Approve("Exit SPSE2?")) {
      exit(0);
    }
  }
}

sub DescribeBindings {
  my ($self,%args) = @_;
  # open instead a window with a scroll bar
  SPSE2::GUI::Util::TextWindow->new
      (
       MainWindow => $self->MyMainWindow,
       Title => "Describe Bindings",
       Contents => SeeDumper($self->MyKeyBindings->KeyBindings),
      );

  #   Message
  #     (
  #      Message => SeeDumper($self->MyKeyBindings->KeyBindings),
  #      GetSignalFromUserToProceed => 1,
  #     );
}

sub ListContexts {
  my ($self,%args) = @_;
  
}

sub SwitchContext {
  my ($self,%args) = @_;
  
}

sub OpenContext {
  my ($self,%args) = @_;
  # take a list of all of the contexts, do a completing read on them
  my $c = `kbs2 -l`;
  my @set = split /\n/, $c;
  my $res = $self->MyMinibuffer->CompletingRead
    (
     Collection => ["Create New Context", sort @set],
    );
  if ($res->{Success}) {
    my $context = $res->{Result};
    if ($context eq "Create New Context") {
      my $res = QueryUser2
	(
	 Title => "Create New Context",
	 Message => "What is the new context's name?",
	);
      if (! $res->{Cancel}) {
	if ($res->{Value} =~ /./) {
	  my $match = 0;
	  foreach my $context (@set) {
	    if ($res->{Value} eq $context) {
	      $match = 1;
	      last;
	    }
	  }
	  if (! $match) {
	    if ($args{CurrentTab}) {
	      # we can go ahead and open a new context in the current window
	      $self->GetCurrentTab->LoadContext
		(Context => $res->{Value});
	    } elsif ($args{NewTab}) {
	      $self->MyTabManager->CreateNewTab
		(
		 Module => "View2",
		 Flags => {
			   Context => $res->{Value},
			  },
		);
	    }
	  }
	}
      }
    } else {
      if ($args{CurrentTab}) {
	$self->GetCurrentTab->LoadContext
	  (Context => $context);
      } elsif ($args{NewTab}) {
	$self->MyTabManager->CreateNewTab
	  (
	   Module => "View2",
	   Flags => {
		     Context => $context,
		    },
	  );
      }
    }
  }
}

sub NextContext {
  my ($self,%args) = @_;
  my $nb = $self->MyTabManager->MyNoteBook;
  my $raised = $nb->raised();
  my @pages = $nb->pages();
  my $i = 0;
  foreach my $page (@pages) {
    if ($page eq $raised) {
      last;
    }
    ++$i;
  }
  if (($i + 1) > $#pages) {
    $nb->raise($pages[0]);
  } else {
    $nb->raise($pages[$i + 1]);
  }
}

sub PreviousContext {
  my ($self,%args) = @_;
  my $nb = $self->MyTabManager->MyNoteBook;
  my $raised = $nb->raised();
  my @pages = $nb->pages();
  my $i = 0;
  foreach my $page (@pages) {
    if ($page eq $raised) {
      last;
    }
    ++$i;
  }
  $nb->raise($pages[$i - 1]);
}

sub ExportContext {
  my ($self,%args) = @_;

}

sub MaximizeWindow {
  my ($self,%args) = @_;
  $self->UnmaximizedGeometry($self->MyMainWindow->geometry);
  $self->MyMainWindow->geometry($self->MyMainWindow->screenwidth . "x" . $self->MyMainWindow->screenheight . "+0+0")
}

sub UnmaximizeWindow {
  my ($self,%args) = @_;
  if (defined $self->UnmaximizedGeometry) {
    $self->MyMainWindow->geometry($self->UnmaximizedGeometry);
    $self->UnmaximizedGeometry(undef);
  }
}

sub KillContext {
  my ($self,%args) = @_;
  $self->MyTabManager->StopTab(Tabname => $self->MyTabManager->MyNoteBook->raised());
}

# MISC

sub ViewLossage {
  my ($self,%args) = @_;
  # show the keys that have been pressed recently

}

sub Tutorial {
  my ($self,%args) = @_;
  # display a usage tutorial
  # just xdg-open some tutorial pdf
}

sub WhereIs {
  my ($self,%args) = @_;
  # do a search for a given command and then display the key that
  # corresponds to it

}

sub DescribeKey {
  my ($self,%args) = @_;
  # Given the user entering a key sequence, tell them what the key does
}

1;
