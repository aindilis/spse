#!/usr/bin/perl -w

use KBS2::Client;
use PerlLib::SwissArmyKnife;

my $client = KBS2::Client->new
  (
  );

if (0) {
  my $res = $client->Send
    (
     QueryAgent => 1,
     InputType => "Interlingua",
     Query => [["and",
		["end-date",\*{'::?X'},\*{'::?Y'}],
		["not",
		 ["or",
		  ["completed",\*{'::?X'}],
		  #		["deleted",\*{'::?X'}],
		  # 		["cancelled",\*{'::?X'}],
		  # 		["ridiculous",\*{'::?X'}],
		  # 		["obsoleted",\*{'::?X'}],
		  # 		["rejected",\*{'::?X'}],
		  # 		["skipped",\*{'::?X'}],
		 ]
		]
	       ]],
     Context => "Personal",
     ResultType => "object",
    );
} else {
  my $res = $client->Send
    (
     QueryAgent => 1,
     InputType => "Interlingua",
     Query => [["and",
		["end-date",\*{'::?X'},\*{'::?Y'}],
	       ]],
     Context => "Personal",
     ResultType => "object",
    );
  my $matches = scalar @{$res->Bindings};
  print Dumper($matches);
}
