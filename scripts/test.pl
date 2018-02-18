#!/usr/bin/perl -w

use GraphViz;
use Tk;

my $mw = new MainWindow ();
my $gv = $mw->Scrolled ( 'GraphViz',
			 -background => 'white',
			 -scrollbars => 'sw' )
  ->pack ( -expand => '1', -fill => 'both' );

$gv->bind ( 'node', '<Button-1>', sub {
	      my @tags = $gv->gettags('current');
	      push @tags, undef unless (@tags % 2) == 0;
	      my %tags = @tags;
	      printf ( "Clicked node: '%s' => %s\n",
		       $tags{node}, $tags{label} );
	    } );

$gv->show ( shift );
MainLoop;
