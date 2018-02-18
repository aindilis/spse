package KeyBindings;

use PerlLib::SwissArmyKnife;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / KeyBindings State Minibuffer HashT2E /

  ];

sub init {
  my ($self,%args) = @_;
  $self->State([]);
  $self->HashT2E
    ({
      "Control" => "C",
      "Alt" => "M",
     });
  $self->LoadKeyBindings();
}

sub LoadKeyBindings {
  my ($self,%args) = @_;
  my $c = read_file("keybindings.txt");

  my @lines = split /\n/, $c;
  my $seen = {};
  $self->KeyBindings({});
  while (@lines) {
    my $line = shift @lines;
    if ($line =~ /^/) {
      shift @lines;
      shift @lines;
      shift @lines;
      shift @lines;
    } elsif ($line =~ /^$/) {

    } elsif ($line =~ /^(.+?)\t+(.+)$/) {
      my $keyseq = $1;
      my $command = $2;
      # print "<$keyseq><$command>\n";

      my $ref = $self->KeyBindings;
      # C-c r l m   thing1
      # C-c r l s   thing2

      my @keys = split /\s+/, $keyseq;
      while (@keys) {
	my $key = shift @keys;
	if (! $seen->{$key}) {
	  $seen->{$key} = $self->ProcessKey(Key => $key);
	}
	if (! exists $ref->{$key}) {
	  if ($command eq "Prefix Command" or $command eq "Control-X-prefix") {
	    $ref->{$key} = {};
	    $ref = $ref->{$key};
	  } else {
	    # if there are additional items, 
	    if (scalar @keys) {
	      $ref->{$key} = {};
	      $ref = $ref->{$key};
	    } else {
	      $ref->{$key} = $command;
	    }
	  }
	} else {
	  if ($command eq "Prefix Command" or $command eq "Control-X-prefix") {
	    $ref = $ref->{$key};
	  } else {
	    # if there are additional items, 
	    if (scalar @keys) {
	      $ref = $ref->{$key};
	    } else {
	      $ref->{$key} = $command;
	    }
	  }
	}
      }
    }
  }
}

sub ProcessKey {
  my ($self,%args) = @_;
  return $args{Key};
}

sub GenerateGUI {
  my ($self,%args) = @_;
  # now use this to develop an application which 

  my $mw = MainWindow->new
    (
     -title => "Shared Priority System Editor 2",
     -width => 1024,
     -height => 768,
    );

  foreach my $symbol ("a".."z") {
    foreach my $operator (qw(Control Alt)) {
      $mw->bind
	(
	 'all',
	 "<$operator-$symbol>",
	 sub {
	   $self->IssueKey(Key => $self->GetEmacsKeyFromTkKey(Operator => $operator, Symbol => $symbol));
	 },
	);
    }
    $mw->bind
      (
       'all',
       "$symbol",
       sub {
	 $self->IssueKey(Key => $self->GetEmacsKeyFromTkKey(Symbol => $symbol));
       },
      );
  }
  MainLoop();
}

sub GetEmacsKeyFromTkKey {
  my ($self,%args) = @_;
  my $response;
  if ($args{Operator}) {
    $response = $self->HashT2E->{$args{Operator}}."-";
  }
  if ($args{Symbol}) {
    $response .= $args{Symbol};
  }
  return $response;
}

sub IssueKey {
  my ($self,%args) = @_;
  my $ref = $self->KeyBindings;
  my @keys = @{$self->State};

  # determine if the key press is legal, if it is legal, determine if
  # it is a leaf or not, if it is a leaf, display the command in the
  # text window, otherwise, shift the state

  # we assume that the current state is already legal, test the move
  # for legality

  # first load the hash corresponding to the current state
  while (@keys) {
    my $key = shift @keys;
    if (! exists $ref->{$key}) {
      # error, state is invalid, this shouldn't happen
      print "ERROR: wrong state\n";
    } else {
      my $ref2 = ref $ref->{$key};
      if ($ref2 eq "HASH") {
	# go ahead and set the current hash to this item
	$ref = $ref->{$key};
      } else {
	print "ERROR: should not see a non-hash, state corrupt\n";
      }
    }
  }
  # ref should be loaded

  # now test for legality
  if (! exists $ref->{$args{Key}}) {

    # it is possible that we are issuing a C-g, C-h, etc, handle those here
    if ($args{Key} eq "C-g") {
      $self->State([]);
    } elsif ($args{Key} eq "C-h") {
      # print all the keys available here
      $self->Display(Item => Dumper($ref));
      $self->State([]);
    } else {
      $self->Display(Item => "Unbound key sequence: ".join(" ", @{$self->State},$args{Key}));
      $self->State([]);
    }
  } else {
    # check if it is a leaf node or not
    my $ref2 = ref $ref->{$args{Key}};
    if ($ref2 eq "HASH") {
      # not a leaf node
      # simply advance the state
      push @{$self->State}, $args{Key};
      $self->Display(Item => join(" ", @{$self->State})." -");
    } else {
      # it is a leaf, execute the action
      $self->Display(Item => $ref->{$args{Key}});
      $self->State([]);
    }
  }
  print "\tState: ".join(" ",@{$self->State})."\n";
}

sub Display {
  my ($self,%args) = @_;
  $self->Minibuffer->Contents($args{Item});
}

1;
