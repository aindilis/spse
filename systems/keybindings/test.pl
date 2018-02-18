#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use Tk;

my $c = read_file("keybindings.txt");

my @lines = split /\n/, $c;
my $seen = {};
my $keybindings = {};
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

    my $ref = $keybindings;
    # C-c r l m   thing1
    # C-c r l s   thing2

    my @keys = split /\s+/, $keyseq;
    while (@keys) {
      my $key = shift @keys;
      if (! $seen->{$key}) {
	$seen->{$key} = ProcessKey(Key => $key);
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

print Dumper($keybindings);

sub ProcessKey {
  my (%args) = @_;
  return $args{Key};
}

my $state = [];
my $name;

sub GenerateGUI {
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
	   IssueKey(Key => GetEmacsKeyFromTkKey(Operator => $operator, Symbol => $symbol));
	 },
	);
    }
    $mw->bind
      (
       'all',
       "$symbol",
       sub {
	 IssueKey(Key => GetEmacsKeyFromTkKey(Symbol => $symbol));
       },
      );
  }

  my $frame2 = $mw->Frame();
  my $nameLabel = $frame2->Label
    (
     -text => "Display",
    );
  my $width = 80;
  my $height = 5;
  $name = $frame2->Text
    (
     -relief       => 'sunken',
     -borderwidth  => 2,
     -width        =>  $width,
     -height        => $height,
    );

  $name->Contents("");
  $nameLabel->pack(-side => 'left');
  $name->pack(-side => 'right');
  $name->focus;
  $frame2->pack();
  MainLoop();
}

sub SetStateToGround {
  $state = [];
}

my $hasht2e = 
  {
   "Control" => "C",
   "Alt" => "M",
  };

sub GetEmacsKeyFromTkKey {
  my (%args) = @_;
  my $response;
  if ($args{Operator}) {
    $response = $hasht2e->{$args{Operator}}."-";
  }
  if ($args{Symbol}) {
    $response .= $args{Symbol};
  }
  return $response;
}

sub IssueKey {
  my (%args) = @_;
  my $ref = $keybindings;
  my @keys = @$state;

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
      $state = [];
    } elsif ($args{Key} eq "C-h") {
      # print all the keys available here
      Display(Dumper($ref));
      $state = [];
    } else {
      Display("Unbound key sequence: ".join(" ", @$state,$args{Key}));
      $state = [];
    }
  } else {
    # check if it is a leaf node or not
    my $ref2 = ref $ref->{$args{Key}};
    if ($ref2 eq "HASH") {
      # not a leaf node
      # simply advance the state
      push @$state, $args{Key};
      Display(join(" ", @$state)." -");
    } else {
      # it is a leaf, execute the action
      Display($ref->{$args{Key}});
      $state = [];
    }
  }
  print "\tState: ".join(" ",@$state)."\n";
}

sub Display {
  my $item = shift;
  $name->Contents($item);
}

GenerateGUI();
