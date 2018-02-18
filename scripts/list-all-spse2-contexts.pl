#!/usr/bin/perl -w

use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

my $mysql = PerlLib::MySQL->new
  (DBName => "freekbs2");

my $res = $mysql->Do
  (
   Statement => "select distinct c.Context from arguments a, arguments b, metadata m, contexts c where a.Value='frdcsa-context-type' and a.ParentFormulaID = b.ParentFormulaID and b.Value = 'SPSE' and m.FormulaID = a.ParentFormulaID and c.ID = m.ContextID order by c.Context",
   Array => 1,
  );

print Dumper($res);
