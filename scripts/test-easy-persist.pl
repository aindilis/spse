#!/usr/bin/perl -w

use PerlLib::EasyPersist;

use Data::Dumper;

my $persist = PerlLib::EasyPersist->new
  (
   Namespace => "SPSE2",
  );

my $command = q{`locate -r '\\\\.do\$'`};
$persist->Get(Command => $command);
print Dumper($persist->Get(Command => $command));
