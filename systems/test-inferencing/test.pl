#!/usr/bin/perl -w

# okay take a theory, find out all the goals that are completed,
# cancelled, or unaffected

use KBS2::Client;
use PerlLib::SwissArmyKnife;

my $client = KBS2::Client->new
  (Context => "Org::FRDCSA::Verber::PSEx2::Do");

my $object = $client->Send
  (
   QueryAgent => 1,
   Query => '(and (goal ?X) (completed ?X))',
   InputType => "KIF String",
   ResultType => "object",
  );

print Dumper($object->Bindings);

# (implies (or (ridiculous ?X) (obsoleted ?X) (rejected ?X) (cancelled ?X) (deleted ?X) (skipped ?X)) (no-longer-a-goal ?X))
 $object = $client->Send
  (
   QueryAgent => 1,
   Query => '(and (goal ?X) (not (completed ?X)) (or (ridiculous ?X) (obsoleted ?X) (rejected ?X) (cancelled ?X) (deleted ?X) (skipped ?X)))',
   InputType => "KIF String",
   ResultType => "object",
  );

print Dumper($object->Bindings);

$object = $client->Send
  (
   QueryAgent => 1,
   Query => '(and (goal ?X) (not (or (completed ?X) (ridiculous ?X) (obsoleted ?X) (rejected ?X) (cancelled ?X) (deleted ?X) (skipped ?X))))',
   InputType => "KIF String",
   ResultType => "object",
  );

print Dumper($object->Bindings);
