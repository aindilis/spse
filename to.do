(We need to fix the problem with graphviz messing up)









(now create new node, and remove edges are not redisplaying correctly)

(perhaps use something like Shapely value to compute the
 importance of a task by how much in enables a group)

(Develop a regression test based system for inputting situations
 and have the AI determine the course of action)
(Add graph theoretic operations and other analyses to spse2)
(Have it recompute the plan after every structural modification)
(Have it show what is invariant)
(Use sayer to cache calls to formalize and other interfaces)
(Have key sequences binding several different binary and unary predicate creation acts)
(Optimize by moving to rendergraph from something like a generate call where possible)
(Put in keys for generating plan, and for other things)
(Make notes of what the mnemonic reason is for a keybinding)
(Have a map of what is going to happen mathematically once and if P=NP is decided)

(create a circuit logic visualizer)

(remove normal View classes, as they might become confused)

(when a new context is created, should rebuild the context menu, eh?)

(doesn't allow selection after creating a new contexzt in current
 window, probably an issue with View2 and Node manager)

(error message when creating new domain
Can't use an undefined value as a HASH reference at /usr/share/perl5/SPSE2/GUI/Tab/View2/Domain/Planning/Model/Main.pm line 314.
sub AddEntryPart2 {
  my ($self,%args) = @_;
  my $name = $args{Description};
  $name =~ s/\W/_/g;
  # my $name = "entry-".$entryid;
  if (! exists $self->Entries->{$name}) {

)

(current bugs: Tue Nov 23 10:06:20 CST 2010
 ;; (doesn't have Create New Context in the New Tab Option)
 ;; (if you open up more than 2 tabs it screws up)
 (the Actions->Domain-> has an empty Planning)

 (when you try to generate a plan, it uses the wrong context,
  needs to use the currently selected context)
 
 )
(should the menus arrange themselves according to the tab?
 probably, because we don't want users
 (so the switch tab hook needs to reload the menus, need to have
  a menus object for each set of menus eh?)  )


(add the plan library stuff, use hygiene for starters, etc)
(add the temporal facts regarding )

(deal with the fact that plan formalisms will need to expressed in multiple languages eventually)
(rearchitect accordingly)


(order squareup.com android)

(here is what we need to do for View2 as of Tue Nov 16 17:42:06
 CST 2010

 (write the interactive execution monitor finally)

 (add a text paste using middle mouse button to all Tk::Entry(s)?)

 (add recurrences)

 (rate the priority of different upgrades to SPSE2)

 (have the value system represent what will happen if certain
  things fail)
 
 (write a speech interface that uses NLU and NLG from the domain
  to point out certain things)

 (write a howto and user manual)

 (create another Domain)

 (add a knowledge editor to the editnode item)

 (have the ability to select which planning domains inherit, have
  a GUI for choosing these things)

 (get context inheritance working on a test basis only, have a
  context context, maybe Org::FRDCSA::FreeKBS2::Contexts, or just
  Contexts, use context inheritance and have that working)

 (have a page for editing knowledge, and have it only correct
  entries which have been changed, make it part of freekbs, a
  reusable tk widget)

 (implement a domain consistency check to detect things like
  multiple mutually-exclusive assertions regarding the same
  pseentryid)
 (update the frdcsa git repos)
 ;; (Get it so that it only calls all-asserted-knowledge once, and reuses that)
 ;; (Get it so the View2 will also initially display goals that have no relation attached to them)
 (Figure out what that awful file system delay is when saving in Emacs)
 (Have the editor reload the time information into the TimePick2
  widget when selecting between start and end dates)
 ;; (Have it handle due-date-for-entry, among others)
 (have timing information for expected, max and min duration of performing a given task)
 (Add a mechanism for classifying the type of action required
  into a database of common actions, and populate timing
  information with defaults from database)
 (parse the generated plan)
 (see if we can't get rid of the redundant goal generation code)
 ;; (add a calendar sync option to Actions->Domain->Planning)
 ;; (remove screenshot from Actions->Domain->Planning and put in Actions)
 (fix all standard operations, such as goal creation and removal)
 (fix the empty menu which isn't appearing)
 (generate a temporal plan for getting important stuff going)
 (add a thing to handle different hours such as working only
  during work hours, splitting tasks up between days, etc) 
 )







(There are at least 2 items which are marked as completed, but
 which are not, vet all of the items)

(just use the pse entry information from add goal to come up with
 the max - that way we don't have to query)



;; don't worry about textual entailment recognition just yet -
;; although we did write that system

(have it start out maximized if possible)
(also have the ability to properly select dependencies, and add them)
(have proper control over zoom level - fix that)
(have code looking better, and more sensically organized
 (extract the silly information out of it about Verber
 generation, as that could be done separately) 
 )
(have inheritance in domains working 
 (that requires work with FreeKBS2, although I kinda see how to
  do it now))
(have textual entailment working properly)
(have several test scenarios lined up - have it know which
 domains are SPSE2 domains)
(have changes be reflected in the knowledge base)
(have a master domain for SPSE2, which stores it's config, etc)









(When we add a new goal, it should see what should depend on it
 naturally)

(come up with a thing like goplay but for the FRDCSA)

(put the garbage bag on)

(organize the folders)

(<REDACTED>)

(setup zone minder on workhorse and setup offsite photo uploading)

(stop by onshore and fix my computer there - update, start using
 it really)

(upload latest build of the FRDCSA docs onto frdcsa.onshore.net)

(incorporate new to.do lists into fweb somehow)

(finish declassification)
(setup up data on workhorse for processing)

(backup justin.frdcsa.org)
(centralize and refactor the media archive - hopefully automatically with software)
(build the SPSE2 system and organize these notes)

(refactor out the MyMainLoop stuff and create a standard way of
 doing it.  Also, create a standard batch processor using the
 default System::StanfordParser)


(
 use the cluster information to cluster particular items together

 $g->add_node('London', cluster => 'Europe')	;
 $g->add_node('Amsterdam', cluster => 'Europe')	;

 Use rank to enforce a certain progression of ideas

 Nodes can be located in the same rank (that is, at the same level in
					the graph) with the "rank" attribute. Nodes with the same rank value
 are ranked together.

 $g->add_node('Paris', rank => 'top')	       ;
 $g->add_node('Boston', rank => 'top')	       ;
 )

(COMPLETED ITEMS
 (completed (Select
	     All
	     None
	     Invert
	     By Search
	     By Entailment
	     ))
 )
