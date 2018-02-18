#!/usr/bin/perl -w

# get out all of the assertions about NL, and then do
# intercomparisions

use KBS2::Client;
use PerlLib::SwissArmyKnife;

sub RetrieveAllGoals {
  my %args = @_;
  my $context = "Org::FRDCSA::Verber::PSEx2::Do";

  my $client = KBS2::Client->new
    (
     Database => "freekbs2-test",
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

my $res = RetrieveAllGoals();
# print Dumper($res);

my $all = $res->{Result};


my $edits = Capability::RTE->new
  (
   Engine => "Edits",
  );

$edits->StartServer;

my $parser = System::LinkParser->new();

NewGoalLoop();

# now go ahead and compute similarity using every way we know how
# how about clustering as well?

# how about RTE?

# how about DocumentSimilarity


sub NewGoalLoop {
  my %args = @_;
  while (1) {
    my $description = QueryUser("Goal?");
    FindOrCreateGoal
      (
       Description => $description,
      );
  }
}

# # (string similarity)
# (bag of words/baysesian similarity)
# (could be tedious to convert implement) # (system-finder similarity)
# # (meteor similarity)
# (RTE)
# (text clustering)
# (anything that incorporates more information - try knext comparison)
# (advanced text classification)

sub FindOrCreateGoal {
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
