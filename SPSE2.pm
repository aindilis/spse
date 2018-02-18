package SPSE2;

use BOSS::Config;
use MyFRDCSA;
use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;
use SPSE2::GUI;
use SPSE2::GUI::Configuration;
use SPSE2::Resources;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config Conf MyMainWindow MyGUI MyConfiguration MyResources /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-l			List available contexts

	-f <spsefile>		Use the file to store instead of a context
	-c <contexts>...	Set the context for the current session

	-d			Run in debug mode

	--view1			Use version one of View
	--view2			Use version two of View (default)

	-u [<host> <port>]	Run as a UniLang agent

	-w			Require user input before exiting
	-W [<delay>]		Exit as soon as possible (with optional delay)
";
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"spse");
  $UNIVERSAL::agent->DoNotDaemonize(1);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification,
      ConfFile => ""));
  $self->Conf($self->Config->CLIConfig);
  my $conf = $self->Conf;
  $UNIVERSAL::agent->DoNotDaemonize(1);
  if ($conf->{'-d'}) {
    $UNIVERSAL::debug = 1;
  }
  $UNIVERSAL::agent->Register
    (Host => defined $conf->{-u}->{'<host>'} ?
     $conf->{-u}->{'<host>'} : "localhost",
     Port => defined $conf->{-u}->{'<port>'} ?
     $conf->{-u}->{'<port>'} : "9000");

  if (! (exists $conf->{'--view1'} or exists $conf->{'--view2'})) {
    $conf->{'--view2'} = 1;
  }
  if (exists $conf->{'-l'}) {

    my $mysql = PerlLib::MySQL->new
      (DBName => "freekbs2");

    my $res1 = $mysql->Do
      (
       Statement => "select distinct c.Context from arguments a, arguments b, metadata m, contexts c where a.Value='frdcsa-context-type' and a.ParentFormulaID = b.ParentFormulaID and b.Value = 'SPSE' and m.FormulaID = a.ParentFormulaID and c.ID = m.ContextID order by c.Context",
       Array => 1,
      );

    my @res;
    foreach my $entry (@$res1) {
      push @res, $entry->[0];
    }
    print join("\n",@res)."\n";
    exit;
  }
  $self->MyMainWindow
    (MainWindow->new
     (
      -title => "Shared Priority System Editor 2",
      -width => 1024,
      -height => 768,
     ));
  $self->MyGUI
    (SPSE2::GUI->new
     (
      MyMainWindow => $self->MyMainWindow,
      SPSE2 => $self,
     ));
  $self->MyConfiguration
    (SPSE2::GUI::Configuration->new
     (MainWindow => $self->MyMainWindow));
  $self->MyConfiguration->SelectProfile();
  # my $hash = $self->MyConfiguration->CurrentProfile->{database};
  # $dbname = $hash->{'dbname'};
  # $host = $hash->{'hostname'};
  # $username = $hash->{'username'};
  # $password = $hash->{'password'};
  $self->MyResources
    (SPSE2::Resources->new);
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  #   if (exists $conf->{'-u'}) {
  #     # enter in to a listening loop
  #     while (1) {
  #       $UNIVERSAL::agent->Listen(TimeOut => 10);
  #     }
  #   }
  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
  $self->MyGUI->Execute();
  # $self->MyMainWindow->geometry(($self->MyMainWindow->maxsize())[0] .'x'.($self->MyMainWindow->maxsize())[1]);
  $self->MyMainWindow->geometry('1024x768');
  $self->MyMainLoop();
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^echo\s*(.*)/) {
      $UNIVERSAL::agent->SendContents
	(Contents => $1,
	 Receiver => $m->{Sender});
    } elsif ($it =~ /^add-goal (.+)$/i) {
      my $goal = $1;
      See(Goal => $goal);
      my $res = $self->MyGUI->GetCurrentTab->DefaultDomain->Model->FindOrCreateNodeHelper
	(
	 Description => $goal,
	 Type => "goal",
	 # want to put constraining date information here as well if possible
	 # SkipRedraw => 1,
	);
      $UNIVERSAL::agent->SendContents
	(Contents => "Added Goal With Result $res: $goal",
	 Receiver => $m->{Sender});
      $UNIVERSAL::agent->UnListen;
    } elsif ($it eq "modify-unary-relation") {
      my $d = $m->{Data};
      if (exists $self->MyGUI->MyTabManager->Tabs->{$d->{Context}}) {
	$self->MyGUI->MyTabManager->Tabs->{$d->{Context}}->ModifyUnaryRelation
	  (
	   Term => $d->{Term},
	   Predicate => $d->{Predicate},
	   Value => $d->{Value},
	  );
	$UNIVERSAL::agent->SendContents
	  (
	   Data => {
		    Result => 1,
		   },
	   Receiver => $m->{Sender},
	  );
      } else {
	$UNIVERSAL::agent->SendContents
	  (
	   Data => {
		    Result => 0,
		   },
	   Receiver => $m->{Sender},
	  );
      }
      $UNIVERSAL::agent->UnListen;
    } elsif ($it eq "center-canvas-window-on-node") {
      my $d = $m->{Data};
      if (exists $self->MyGUI->MyTabManager->Tabs->{$d->{Context}}) {
	my $view = $self->MyGUI->MyTabManager->Tabs->{$d->{Context}};
	my $node = $view->MyNodeManager->GetNode(NodeInterlingua => $d->{Term});
	$view->CenterCanvasWindowOnNode
	  (
	   Node => $node->[0],
	  );
      }
    } elsif ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    }
  }
}

sub MyMainLoop {
  my ($self,%args) = @_;
  if (exists $self->Conf->{'-W'}) {
    $self->MyMainWindow->repeat
      (
       $self->Conf->{'-W'} || 1000,
       sub {
	 $UNIVERSAL::agent->Deregister;
	 exit(0);
       },
      );
  }
  $self->MyMainWindow->repeat
    (
     50,
     sub {
       $self->AgentListen(),
     },
    );
  MainLoop();
}

sub AgentListen {
  my ($self,%args) = @_;
  # UniLang::Agent::Agent
  # print ".\n";
  $UNIVERSAL::agent->Listen
    (
     TimeOut => 0.05,
    );
}

1;
