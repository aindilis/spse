package SPSE2::Util;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (ProcessName);

sub ProcessName {
  my %args = @_;
  my $item = uc($args{Item});
  $item =~ s/\W/_/g;

  # NOTE: the max length with the planner LPG-td is 255, once it gets
  # longer it has sometimes corruptted strings.

  my $MAX_LENGTH = 255;
  if (length($item) > $MAX_LENGTH) {
    $item = substr($item,0,$MAX_LENGTH);
  }
  print "wtf<$item>\n";
  return $item;
}

1;
