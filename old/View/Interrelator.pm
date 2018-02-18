package SPSE2::GUI::Tab::View::Interrelator;

use Capability::RTE;
use Capability::SentenceSimilarity;
use Capability::Similarity::Document::Engine::Custom1;
use KBS2::Client;
use PerlLib::EasyPersist;
use PerlLib::SwissArmyKnife;
use System::LinkParser;

use Text::Levenshtein qw(distance);
use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Top1 Verbose Data Fields MyView MySimilarity /

  ];

sub init {
  my ($self,%args) = @_;
  my $res = RetrieveAllGoals();
  # print Dumper($res);

  my $all = $res->{Result};


  my $edits = Capability::RTE->new
    (
     Engine => "Edits",
    );

  $edits->StartServer;
  my $parser = System::LinkParser->new();





  $self->MyView($args{View});
  $self->Verbose($args{Verbose} || 0);
  my $title;
  if (exists $args{Goal}) {
    my $goal = $args{Goal};
    $self->Data->{Source} = $goal->Source;
    my $tmp;
    $self->Data->{Description} = $goal->Description;
    $title = "Edit Goal";
    $self->Data
      ($args{Data} ||
       {
	Source => "unilang",
	Description => "Sample entry",
       });
  } else {
    $title = "New Goal";
    $self->Data
      ($args{Data} ||
       {
	Source => "pse",
	Description => "",
       });
  }
  $self->Top1
    ($args{MainWindow}->Toplevel
     (
      -title => $title,
      -height => 600,
      -width => 800,
     ));

  # when you do what you need to do when it needs to be done, then you can do what you want to do when you want to"

  my @order = ("Source", "Description");

  my $fields =
    {
     "Source" => {
		  Description => "source from which this goal came",
		  Args => ["tinytext"],
		  TextVar => $self->Data->{Source},
		 },
     "Description" => {
		       Description => "goal description",
		       Args => ["text"],
		       TextVar => $self->Data->{Description},
		       Normal => 1,
		       TakeFocus => 1,
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
	    my $state;
	    if ($fields->{$field}->{Normal}) {
	      $state = "normal";
	    } else {
	      $state = "disabled";
	    }
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => $state,
	      );
	    my $name = $frame2->Text
	      (
	       -relief       => 'sunken',
	       -borderwidth  => 2,
	       -width        => 80,
	       -height        => 5,
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
	  } else {
	    # print Dumper({Huh => $arg2});
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

  # now have the subset selector
  # embed the equivalent of a selector here, but have multiple tabs for different kinds of matches

  # now have an auxilary query interface (if initial matches are fruitless)

  $buttons = $self->Top1->Frame();
  $buttons->Button
    (
     -text => "Select All",
     -command => sub {$self->ActionDefaults},
    )->pack(-side => "left");
  $buttons->Button
    (
     -text => "Select None",
     -command => sub {$self->ActionApply},
    )->pack(-side => "left");
  $buttons->Button
    (
     -text => "Invert Selection",
     -command => sub {$self->ActionSaveConfiguration},
    )->pack(-side => "left");

  foreach my $relation ("Depends on", "Precondition for", "Eases", "Eased by", "Provides", "Provided by", "Prefer", "Deferred to") {
    $buttons->Button
      (
       -text => $relation,
       -command => sub {
	 $self->BinaryRelation
	   (
	    Relation => $relation,
	   );
       },
      )->pack(-side => "right");
  }
}

sub RetrieveAllGoals {
  my %args = @_;

  my $context = "Org::FRDCSA::Verber::PSEx2::Do";

  my $client = KBS2::Client->new
    (
     Database => "freekbs2",
    );

  my $message = $client->Send
    (
     QueryAgent => 1,
     Command => "all-asserted-knowledge",
     Context => $context,
    );
  my $assertions = $message->{Data}->{Result};
  # here is what we do, we go through and extract the NL results
  my $all = {};
  foreach my $assertion (@$assertions) {
    my $pred = $assertion->[0];
    if ($assertion->[0] eq "has-NL") {
      $all->{$assertion->[2]} = 1;
    }
  }
  return
    {
     Success => 1,
     Result => $all,
    };
}

# now go ahead and compute similarity using every way we know how
# how about clustering as well?

# how about RTE?

# how about DocumentSimilarity

sub FindPossiblyRelatedGoals {
  my %args = @_;
  # just do levenshtein for starters
  my $scores = {};
  my @edits;
  foreach my $description (keys %$all) {
    my $res = {};
    # check for identical matches
    $res->{Levenshtein} = distance($args{Description},$description);
    my $res2 = SentenceSimilarity
      (
       A => $args{Description},
       B => $description,
      );
    # print Dumper($res2);
    $res->{SentenceSimilarity} = $res2->{score};
    if ($parser->CheckSentence(Sentence => $description)) {
      push @edits, {
		    T => $args{Description},
		    H => $description,
		   };
      print "<Accepting: $description>\n";
    } else {
      print "<Skipping: $description>\n";
    }
    $res->{Combined} = $res->{SentenceSimilarity};
    # print Dumper($res);
    $scores->{$description} = $res;
  }

  my $res3 = $edits->RTE
    (
     Pairs => \@edits,
    );
  print Dumper($res3);

  foreach my $description (sort {$scores->{$b}->{Combined} <=> $scores->{$a}->{Combined}} keys %$all) {
    print "$description\n\t".$scores->{$description}->{Combined}."\n";
  }
}

# want selection capabilities (all none invert)
# all binary relations

sub ActionSaveConfiguration {
  my ($self,%args) = @_;
  # just print out the configuration for now
  # print Dumper($self->Fields);
}

sub ActionApply {
  my ($self,%args) = @_;

}

sub ActionDefaults {
  my ($self,%args) = @_;

}

1;
