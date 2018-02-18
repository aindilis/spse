package SPSE2::GUI::Tab::View2::EditNode::DateTime::Recurrence;

use PerlLib::SwissArmyKnife;

use DateTime;
use DateTime::Event::ICal;
use DateTime::Format::ICal;
use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Top1 Verbose Data Fields MyView Rel CurrentOrder Layout Time /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyView($args{View});
  $self->Time($args{Time});
  $self->Verbose($args{Verbose} || 0);
  $self->Layout
    ({
      "_all" => ["Repeats","Repeat Every","Starts On","Ends On","Summary","Repeat On","Repeat By"],
      "Daily" => ["Repeats","Repeat Every","Starts On","Ends On","Summary"],
      "Every Weekday" => ["Repeats","Starts On","Ends On","Summary"],
      "Every Mon Wed & Fri" => ["Repeats","Starts On","Ends On","Summary"],
      "Every Tue & Thu" => ["Repeats","Starts On","Ends On","Summary"],
      "Weekly" => ["Repeats","Repeat Every","Repeat On","Starts On","Ends On","Summary"],
      "Montly" => ["Repeats","Repeat Every","Repeat By","Starts On","Ends On","Summary"],
      "Yearly" => ["Repeats","Repeat Every","Starts On","Ends On","Summary"],
     });
  $self->Data({});
  $self->Data->{Repeats} = "";
  # $self->Rel(["entry-fn","pse",$self->Data->{EntryID}]);
  $self->Data->{"Repeat Every"} = "";
  $self->Data->{"Starts On"} = $args{StartsOn};
  $self->Data->{"Ends On"} = $args{EndsOn};
  $self->Data->{Summary} = "";

  $self->Top1
    ($args{MainWindow}->Toplevel
     (
      -title => "Recurrence",
      -height => 600,
      -width => 800,
     ));

  # might make more sense just to sql or iterate over the KB here
  # rather than query all of these?  then again, hrm, editable versus
  # consequential?

  # when you do what you need to do when it needs to be done, then you can do what you want to do when you want to"

  $self->CurrentOrder("_all");
  my @order = @{$self->Layout->{$self->CurrentOrder}};

  my $fields =
    {
     "Repeats" => {
		   Description => "Set the type of recurrence",
		   Args => ["dropdown"],
		   TextVar => $self->Data->{Repeats},
		   Function => sub { $self->SetRepeats() },
		   Options => ["Daily","Every Weekday","Every Mon Wed & Fri","Every Tue & Thu","Weekly","Montly","Yearly"],
		  },
     "Repeat Every" => {
			Description => "Repeat every certain number",
			Args => ["dropdown"],
			TextVar => $self->Data->{"Repeat Every"},
			Function => sub {  },
			Options => [1..30],
		       },
     "Starts On" => {
		     Description => "Set the day that the repeat starts on",
		     Args => ["date"],
		     TextVar => $self->Data->{"Starts On"},
		    },
     "Ends On" => {
		   Description => "Set the day that the repeat ends on",
		   Args => ["date"],
		   TextVar => $self->Data->{"Ends On"},
		  },
     "Summary" => {
		   Description => "Summary of the recurrence",
		   Args => ["tinytext"],
		   TextVar => $self->Data->{Summary},
		   Normal => 0,
		  },
     "Repeat On" => {
		     Description => "Have a set of radio buttons for each weekday",
		     Args => ["powerset"],
		     Options => ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],
		    },
     "Repeat By" => {
		     Description => "Repeat by a certain time",
		     Args => ["dropdown"],
		     TextVar => $self->Data->{"Repeat By"},
		     Function => sub {  },
		     Options => ["day of the month","day of the week"],
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
      $self->Fields->{$field}->{Frame} = $frame;
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
	  } elsif ($arg2 eq "date") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );
	    my $name = $frame2->ChooseDate
	      (
	       -textvariable => \$fields->{$field}->{TextVar},
	       -state => 'disabled',
	       -command => sub {},
	      )->pack(-fill=>'x', -expand=>1);
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
	  } elsif ($arg2 eq "powerset") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );

	    foreach my $option (reverse @{$self->Fields->{$field}->{Options}}) {
	      $self->Fields->{$field}->{Powerset}->{$option} = $frame2->Checkbutton
		(
		 -text => $option,
		 -command => sub { },
		)->pack(-side => "right");
	    }

	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    # $name->pack(-side => 'right');
	    # $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    # if ($self->Fields->{$field}->{TakeFocus}) {
	    #  $name->focus;
	    # }
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
  $self->SetRepeats(Repeats => "Daily");

  $buttons = $self->Top1->Frame();

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
     -command => sub {$self->ActionSave},
    )->pack(-side => "left");
  $buttons->Button
    (
     -text => "Cancel",
     -command => sub { $self->ActionCancel(); },
    )->pack(-side => "right");

  $buttons->pack;
  $self->Top1->bind
    (
     "all",
     "<Escape>",
     sub {
       $self->Cancel();
     },
    );
}

sub Execute {
  my ($self,%args) = @_;
}

sub ActionSave {
  my ($self,%args) = @_;
  # just print out the configuration for now
  # print SeeDumper($self->Fields);
}

sub ActionDefaults {
  my ($self,%args) = @_;

}

sub ActionCancel {
  my ($self,%args) = @_;
  # check for changes

  # if there are changes, prompt to determine whether to really cancel
  # or not

  $self->Top1->destroy;
}

sub GetValueForField {
  my ($self,%args) = @_;
  my $field = $args{Field};
  # we have to carefully figure out now which one it is, I guess we
  # can no longer use the heuristic that if it has a widget, then it
  # has a Contents.  how do you check for whether a given item has a
  # contents, let's just check the widget's class and if it is in a
  # class that uses it, like Tk::Entry, then just use that

  if ($self->Fields->{$field}->{Args}->[0] eq "powerset") {
    # iterate over the options, adding to 
    my $retval = {};
    foreach my $option (@{$self->Fields->{$field}->{Options}}) {
      $retval->{$option} = ($self->Fields->{$field}->{Powerset}->{$option}->{Value} || 0) * 1
    }
    return $retval;
  } elsif (exists $self->Fields->{$field}->{Widget}) {
    my $class = ref $self->Fields->{$field}->{Widget};
    if ($class =~ /^Tk::(Text)$/) {
      return $self->Fields->{$field}->{Widget}->Contents;
    }
  }
  if (exists $self->Fields->{$field}->{TextVar}) {
    return $self->Fields->{$field}->{TextVar};
  }
}

sub SetRepeats {
  my ($self,%args) = @_;
  # pack and unpack
  $args{Repeats} ||= $self->GetValueForField(Field => "Repeats");
  foreach my $field (@{$self->Layout->{$self->CurrentOrder}}) {
    # print "Forgetting $field\n";
    $self->Fields->{$field}->{Frame}->packForget();
  }
  $self->CurrentOrder($args{Repeats});
  # print SeeDumper([$args{Repeats}]);
  foreach my $field (@{$self->Layout->{$self->CurrentOrder}}) {
    # print "<$field>\n";
    $self->Fields->{$field}->{Frame}->pack();
  }

  # unpack and repack

  # Weekly on weekdays
  # Weekly on Monday, Wednesday, Friday
  # Weekly on Tuesday, Thursday

  # Weekly on *

  # Monthly on *

  # anuually on $date, every $disp years on $date
}

sub ActionApply {
  my ($self,%args) = @_;
  # go ahead and update any changes to anything, currently
  # description, status, etc
  # use metadata to accomplish this, find out where that metadata is
  # for now just dump the new values

  # generate the recurrence using this information

  # my $freq = ["yearly", "monthly", "weekly", "daily", "hourly", "minutely", "secondly"];
  my $mapping =
    {
     "Daily" => {
		 freq => "daily",
		},
     "Every Weekday" => {
			 freq => "weekly",
			 byday => ["mo","tu","we","th","fr"],
			},
     "Every Mon Wed & Fri" => {
			       freq => "weekly",
			       byday => ["mo","we","fr"],
			      },
     "Every Tue & Thu" => {
			   freq => "weekly",
			   byday => ["tu","th"],
			  },
     "Weekly" => {
		  freq => "weekly",
		 },
     "Monthly" => {
		   freq => "monthly",
		  },
     "Yearly" => {
		  freq => "yearly",
		 },
    };

  my $temp =
    {
     "_all" => ["Repeats","Repeat Every","Starts On","Ends On","Summary","Repeat On","Repeat By"],
     "Daily" => ["Repeats","Repeat Every","Starts On","Ends On","Summary"],
     "Every Weekday" => ["Repeats","Starts On","Ends On","Summary"],
     "Every Mon Wed & Fri" => ["Repeats","Starts On","Ends On","Summary"],
     "Every Tue & Thu" => ["Repeats","Starts On","Ends On","Summary"],
     "Weekly" => ["Repeats","Repeat Every","Repeat On","Starts On","Ends On","Summary"],
     "Montly" => ["Repeats","Repeat Every","Repeat By","Starts On","Ends On","Summary"],
     "Yearly" => ["Repeats","Repeat Every","Starts On","Ends On","Summary"],
    };

  my $repeats;
  my $item = {};
  foreach my $field (@{$self->Layout->{$self->CurrentOrder}}) {
    if ($field eq "Repeats") {
      $repeats = $self->GetValueForField(Field => "Repeats");
      foreach my $key (keys %{$mapping->{$repeats}}) {
	$item->{$key} = $mapping->{$repeats}->{$key};
	print SeeDumper({Key => $key});
      }
    }
    if ($field eq "Repeat Every") {
      $item->{interval} = $self->GetValueForField(Field => "Repeat Every");
    }
    if ($field eq "Repeat On") {
      my $hash1 = $self->GetValueForField(Field => "Repeat On");
      my $map =
	{
	       "Mon" => "mo",
	       "Tue" => "tu",
	       "Wed" => "we",
	       "Thu" => "th",
	       "Fri" => "fr",
	       "Sat" => "sa",
	       "Sun" => "sa",
	      };
      my @list;
      foreach my $key (keys %$hash1) {
	if ($hash1->{$key}) {
	  push @list, $map->{$key};
	}
      }
      $item->{byday} = \@list;
    }
    if ($field eq "Starts On") {
      my ($y1,$m1,$d1) = split /\//, $self->GetValueForField(Field => "Starts On");
      $item->{dtstart} = DateTime->new(year => $y1, month => $m1, day => $d1);
    }
    if ($field eq "Ends On") {
      my ($y2,$m2,$d2) = split /\//, $self->GetValueForField(Field => "Ends On");
      $item->{dtend} = DateTime->new(year => $y2, month => $m2, day => $d2);
    }
  }

  # my ($h,$m,$s) = split /:/, $self->Time;
  # $item->{byhour} = [$h];
  # $item->{byminute} = [$m];
  # $item->{bysecond} = [$s];
  # $item->{bymonth} = [10,12];

  if (defined $item) {
    if (exists $item->{dtstart}) {
      $item->{dtstart} = DateTime::Format::ICal->format_datetime($item->{dtstart});
    }
    if (exists $item->{dtend}) {
      $item->{dtend} = DateTime::Format::ICal->format_datetime($item->{dtend});
    }
    # use metadata to assert that this is 
    my $res = $self->MyView->MyMetadata->SetMetadata
     	(
     	 Predicate => "has-recurrence",
     	 Item => $self->Rel,
     	 Value => Dumper($item),
     	);
    # # $self->TestSet(Item => $item);
  }
}

sub TestSet {
  my ($self,%args) = @_;
  my $set;
  my $dt;

  my $item = $args{Item};
  print SeeDumper($item);
  $set = DateTime::Event::ICal ->recur
    (
     %$item
    );
  $dt = DateTime->now();

  #  if (1) {
  #   } else {
  #     $dt = DateTime->new(
  # 			year   => 2000,
  # 			month  => 6,
  # 			day    => 20,
  # 			hour   => 13,
  # 			minute   => 49,
  # 			second   => 41,
  # 		       );
  #     $set = DateTime::Event::ICal ->recur(
  # 					 dtstart => $dt,
  # 					 freq =>    'weekly',
  # 					 byday =>  [ "mo","tu" ],
  # 					 # byhour =>  [ 10,12 ],
  # 					 # byminute =>  [ 30 ],
  # 					 # bysecond =>  [ 30 ],
  # 					 # bymonth => [ 1..12 ],
  # 				       );
  #   }
  if (1) {
    my $dt_next;

    my $iter = $set->iterator;

    while ( my $dt_iter = $iter->next ) {
      print $dt_iter->datetime."\n";
    }

    #     while ($dt_next = $set->next( $dt )) {
    #       print DateTime::Format::ICal->format_datetime($dt_next)."\n";
    #       # print SeeDumper($dt_next);
    #     }
  }


}

1;
