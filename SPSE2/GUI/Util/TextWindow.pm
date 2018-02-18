package SPSE2::GUI::Util::TextWindow;

use PerlLib::SwissArmyKnife;

use Tk;

use Manager::Dialog;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow MyTopLevel MyText /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMainWindow
    ($args{MainWindow});
  my $height = $args{Height} || 400;
  my $width = $args{Width} || 600;
  $self->MyTopLevel
    ($self->MyMainWindow->Toplevel
     (
      -title => $args{Title},
      -height => $height,
      -width => $width,
     ));
  my $topframe = $self->MyTopLevel->Frame()->pack
    (
     -side => 'top', -expand => "yes", -fill => "both"
    );
  my $bottomframe = $self->MyTopLevel->Frame()->pack(-side => 'bottom');
  my $scroll_text = $topframe->Scrollbar();

  my $main_text = $topframe->Text(-yscrollcommand => ['set', $scroll_text],);

  $scroll_text->configure(-command => ['yview', $main_text]);

  $scroll_text->pack(-side=>"right", -expand => "no", -fill => "y");
  $main_text->pack(-side => "left", -anchor => "w",
		   -expand => "yes", -fill => "both");

  $main_text->Contents($args{Contents});

  $bottomframe->Button
    (
     -text => "Ok",
     -command => sub {$self->MyTopLevel->destroy()},
    )->pack(-side => 'bottom');

  $self->MyTopLevel->geometry($width.'x'.$height);

}

sub Execute {
  my ($self,%args) = @_;
}

1;
