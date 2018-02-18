#!/usr/bin/perl -w

use KBS2::Client;
use PerlLib::SwissArmyKnife;

my $kbs2 = KBS2::Client->new();
my $res = $kbs2->Send
  (
   QueryAgent => 1,
   Command => "list-contexts",
   # Database => $database,
  );

my $skip =
  {
   "extended-wordnet" => 1,
  };

my $items =
  {
   'asserter' => 1,
   'cancelled' => 1,
   'completed' => 1,
   'costs' => 1,
   'depends' => 1,
   'earns' => 1,
   'eases' => 1,
   'end-date' => 1,
   'ethicality-concern' => 1,
   'event-duration' => 1,
   'goal' => 1,
   'has-formalization' => 1,
   'has-NL' => 1,
   'has-parent' => 1,
   'has-parent-file' => 1,
   'has-source' => 1,
   'interested-in' => 1,
   'involves' => 1,
   'obsoleted' => 1,
   'prefer same' => 1,
   'provides' => 1,
   'rejected' => 1,
   'ridiculous' => 1,
   'severity' => 1,
   'showstopper' => 1,
   'start-date' => 1,
  };

my $score = {};
foreach my $context (@{$res->{Data}->{Result}}) {
  next if exists $skip->{$context};
  # print $context."\n";
  my $res2 = $kbs2->Send
    (
     QueryAgent => 1,
     Command => "all-asserted-knowledge",
     # Database => $database,
     Context => $context,
    );
  my $count = scalar @{$res2->{Data}->{Result}};
  # print "COUNT: $count\n";
  my $predicates = {};
  foreach my $formula (@{$res2->{Data}->{Result}}) {
    if (! exists $predicates->{$formula->[0]}) {
      $predicates->{$formula->[0]} = 1;
    } else {
      $predicates->{$formula->[0]}++;
    }
  }
  $score->{$context} = ComputeSimilarity(A => $items, B => $predicates);
  if ($score->{$context}) {
    print $score->{$context}."\t"."A: ".$context."\n";
  } else {
    print "\tR: ".$context."\n";
  }
}



sub ComputeSimilarity {
  my (%args) = @_;
  my $score = 0;
  foreach my $x (keys %{$args{B}}) {
    if (! exists $args{A}->{$x}) {
      return 0;
    } else {
      $score++;
    }
  }
  return $score;
}
