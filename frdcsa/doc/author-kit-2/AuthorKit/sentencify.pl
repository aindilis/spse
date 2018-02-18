#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use Lingua::EN::Sentence qw(get_sentences);

my $c = read_file($ARGV[0]);

my $sentences = get_sentences($c);

foreach my $sentence (@$sentences) {
  $sentence =~ s/[\n\r]+/ /sg;
  $sentence =~ s/\s+/ /sg;
  print $sentence."\n";
}
