#!/usr/bin/perl -w

use KBS2::Client;
use PerlLib::SwissArmyKnife;

my $client = KBS2::Client->new
  (
  );

my $res = $client->Send
  (
   QueryAgent => 1,
   InputType => "Interlingua",
   Query => [["end-date",\*{'::?X'},\*{'::?Y'}]],
   Context => "Personal",
   ResultType => "object",
  );

print Dumper($res);
