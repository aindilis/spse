#!/usr/bin/perl -w

use Tk;
use Tk::DateEntry;

use Time::Local;

%idx_for_mon = ( JAN=>1, FEB=>2, MAR=>3, APR=> 4, MAY=> 5, JUN=> 6,
		  JUL=>7, AUG=>8, SEP=>9, OCT=>10, NOV=>11, DEC=>12 );

$input = '01-APR-2004'; # Initial value for display

$mw = MainWindow->new();
$mw->geometry( '200x80' );
$mw->resizable( 0, 0 );

$label = $mw->Label( -text=>'' )->pack;
$entry = $mw->DateEntry( -textvariable=>\$input, -width=>11,
			  -parsecmd=>\&parse, -formatcmd=>\&format )->pack;

$mw->Button( -text=>'Quit', -command=>sub{ exit } )->pack( -side=>'right' );
$mw->Button( -text=>'Convert',
	          -command=>sub{ convert( $input, $label ) } )->pack( -side=>'left' );

MainLoop;

# called on dropdown with content of \$textvariable, must return ( $yr, $mon, $day )
sub parse {
  my ( $day, $mon, $yr ) = split '-', $_[0];
  return ( $yr, $idx_for_mon{$mon}, $day );
}

# called on user selection with ($yr, $mon, $day), must return formatted string
sub format {
  my ( $yr, $mon, $day ) = @_;
  my %mon_for_idx = reverse %idx_for_mon;
  return sprintf( "%02d-%s-%2d", $day, $mon_for_idx{ $mon }, $yr );
}

# perform the conversion to epoch seconds when the corresponding button is pressed
sub convert {
  my ( $input, $label ) = @_;
  my ( $yr, $mon, $day ) = parse( $input );
  my $output = "Epoch seconds: " . timelocal( 0, 0, 0, $day, $mon-1, $yr-1900 );
  $label->configure( -text => $output );
}
