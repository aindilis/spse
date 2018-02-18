package SPSE2::GUI::TabManager;

use PerlLib::SwissArmyKnife;

use Tk::NoteBook;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow MyNoteBook MainMenu MyMenu Tabs TabInfo /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Tabs({});
}

sub Execute {
  my ($self,%args) = @_;
  $self->TabInfo
    ({
      "View2" => {
		  Module => "View2",
		  Default => 1,
		 },
     });
  $self->StartGUI(%args);
}

sub StartGUI {
  my ($self,%args) = @_;
  $self->MyMainWindow($args{MyMainWindow});
  # $self->MainMenu($args{MainMenu});
  my $frame = $self->MyMainWindow->Frame();
  $frame->pack
    (
     -expand => 1,
     -fill => 'both',
    );
  $self->MyNoteBook($frame->NoteBook());
  # $self->MyMenu($self->MainMenu->Menubutton(-text => "Tabs"));

  #   foreach my $tabname ("View2") {
  #     my $open = 0;
  #     if ($self->TabInfo->{$tabname}->{Default}) {
  #       $self->StartTab
  # 	(
  # 	 Tabname => $tabname,
  # 	 # Flags => $args{Flags},
  # 	);
  #       $open = 1;
  #     }
  #     $self->AddTabToTabMenu
  #       (
  #        Tabname => $tabname,
  #        Open => $open,
  #       );
  #   }
  my $contexts = $UNIVERSAL::spse2->Conf->{'-c'} || ["Org::FRDCSA::SPSE2::Default"];
  my @tabs;
  foreach my $context (@$contexts) {
    $self->CreateNewTab
      (
       Module => "View2",
       Flags => {
		 Context => $context,
		},
      );
    $self->MyNoteBook->pack(-expand => 1, -fill => "both");
  }
}

sub StartTab {
  my ($self,%args) = @_;
  my $myframe = $self->MyNoteBook->add($args{Tabname}, -label => $args{Tabname});
  my $modulename = "SPSE2::GUI::Tab::".$self->TabInfo->{$args{Tabname}}->{Module};
  # print SeeDumper({Modulename => $modulename});
  my $require = $modulename;
  $require =~ s/::/\//g;
  $require .= ".pm";
  my $fullrequire = "/var/lib/myfrdcsa/codebases/minor/spse/$require";
  if (! -f $fullrequire) {
    print "ERROR, no <<<$fullrequire>>>\n";
    return;
  }
  require $fullrequire;
  my $newtab = eval "$modulename->new(Frame => \$myframe, Tabname => \$args{Tabname})";
  my $errorstring = $@;
  if (defined $newtab) {
    $self->Tabs->{$args{Tabname}} = $newtab;
    $newtab->Execute
      (
       Flags => $args{Flags},
      );
    return $newtab;
  } else {
    print SeeDumper($args{Tabname});
    print $errorstring."\n";
  }
}

sub StopTab {
  my ($self,%args) = @_;
  $self->MyNoteBook->delete($args{Tabname});
  delete $self->Tabs->{$args{Tabname}};
}

sub AddTabToTabMenu {
  my ($self,%args) = @_;
  my $open = $args{Open};
  # $self->MyMenu->checkbutton(-label => $args{Tabname}, -variable => \$open);
}

sub CreateNewTab {
  my ($self,%args) = @_;
  # FIXME
  # make sure the context isn't already open in another tab
  if (exists $args{Flags}) {
    if (exists $args{Flags}->{Context}) {
      $args{Tabname} = $args{Flags}->{Context};
    }
  }
  if (! defined $args{Tabname}) {
    # create a new tab name, skip for now
    $args{Tabname} = $self->CreateUniqueNameForModule(Module => $args{Module});
  }
  if (! exists $self->TabInfo->{$args{Tabname}}) {
    $self->TabInfo->{$args{Tabname}}->{Module} = $args{Module};
  } else {
    print "ERROR: tabname exists";
  }
  $self->StartTab
    (
     Tabname => $args{Tabname},
     Flags => $args{Flags},
    );
}

sub CreateUniqueNameForModule {
  my ($self,%args) = @_;
  if (! defined $self->TabInfo->{$args{Module}}) {
    return $args{Module};
  }
  my $i = 1;
  do {
    $retval = $args{Module}."-".$i;
    ++$i;
  } while (defined $self->TabInfo->{$retval});
  return $retval;
}

1;
