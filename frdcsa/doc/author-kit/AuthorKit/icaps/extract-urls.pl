#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use PerlLib::URIExtractor;

my $uris = {};
foreach my $file (split /\n/, `ls *.txt`) {
  # print "$file\n";
  my $c = read_file($file);
  my $res = ExtractURIs($c);
  foreach my $uri (@$res) {
    $uris->{$uri}++;
  }
}

foreach my $uri (sort {$uris->{$b} <=> $uris->{$a}} keys %$uris) {
  print $uris->{$uri}."\t".$uri."\n";
  my $command = "mozilla -remote ".shell_quote("openURL($uri,new-tab)");
  print $command."\n";
  system $command;
  # GetSignalFromUserToProceed();
}
