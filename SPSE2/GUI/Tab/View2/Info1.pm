package SPSE2::GUI::Tab::View2::Info1;

use KBS2::Util::Metadata;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / UnaryPredicates InversibleBinaryPredicates Fields
   BinaryRelationMap Attributes FieldMap MyMetadata
   EnglishGlossForPredicate EnglishGlossForPredicateInverse /

  ];

sub init {
  my ($self,%args) = @_;
  if (0) {
    $self->MyMetadata
      (KBS2::Util::Metadata->new
       (Context => "Org::PICForm::PIC::Vis"));
  }
  $self->UnaryPredicates(["showstopper","completed","deleted","cancelled","ridiculous","obsoleted","rejected","skipped","shoppinglist"]);
  $self->InversibleBinaryPredicates(["depends","eases","provides","prefer"]);
  $self->Fields(["costs", "disputed", "comment", "solution", "assigned-by", "has-feeling", "assigned-to", "belongs-to-system"]);

  $self->BinaryRelationMap
    ({
      "Depends on" => {
		       Predicate => "depends",
		      },
      "Precondition for" => {
			     Predicate => "depends",
			     Order => "inverse",
			    },
      "Eases" => {
		  Predicate => "eases",
		 },
      "Eased by" => {
		     Predicate => "eases",
		     Order => "inverse",
		    },
      "Provides" => {
		     Predicate => "provides",
		    },
      "Provided by" => {
			Predicate => "provides",
			Order => "inverse",
		       },
      "Prefer" => {
		   Predicate => "prefer",
		  },
      "Deferred to" => {
			Predicate => "prefer",
			Order => "inverse",
		       },
     });

  $self->Attributes
    ({
      "depends" => {
		    Color => "red",
		   },
      "eases" => {
		  Color => "gold",
		 },
      "provides" => {
		     Color => "green",
		    },
      "prefer" => {
		   Color => "purple",
		  },
      "not depends" => {
			Color => "red",
			Style => "dashed",
		       },
      "not eases" => {
		      Color => "gold",
		      Style => "dashed",
		     },
      "not provides" => {
			 Color => "green",
			 Style => "dashed",
			},
      "not prefer" => {
		       Color => "purple",
		       Style => "dashed",
		      },
     });

  $self->FieldMap
    ({
      "Costs" => "costs",
      "Dispute" => "disputed",
      "Comment" => "comment",
      "Describe Solution" => "solution",
      "Assigned By" => "assigned-by",
      "Has Feeling" => "has-feeling",
      "Assigned To" => "assigned-to",
      "Belongs to System" => "belongs-to-system",
     });

  $self->EnglishGlossForPredicate
    ({
      "showstopper" => "Showstopper",
      "completed" => "Completed",
      "deleted" => "Deleted",
      "cancelled" => "Cancelled",
      "ridiculous" => "Ridiculous",
      "obsoleted" => "Obsoleted",
      "rejected" => "Rejected",
      "skipped" => "Skipped",
      "shoppinglist" => "ShoppingList",

      "depends" => "Depends on",
      "eases" => "Eases",
      "provides" => "Provides",
      "prefer" => "Prefer",

      "costs" => "Costs",
      "disputed" => "Dispute",
      "comment" => "Comment",
      "solution" => "Describe Solution",
      "assigned-by" => "Assigned By",
      "has-feeling" => "Has Feeling",
      "assigned-to" => "Assigned To",
      "belongs-to-system"=> "Belongs to System",
     });

  $self->EnglishGlossForPredicateInverse
    ({
      "depends" => "Precondition for",
      "eases" => "Eased by",
      "provides" => "Provided by",
      "prefer" => "Deferred to",
     });
}

sub GetEnglishGlossForPredicate {
  my ($self,%args) = @_;
  return $self->EnglishGlossForPredicate->{$args{Predicate}};
}

sub GetEnglishGlossForPredicateInverse {
  my ($self,%args) = @_;
  return $self->EnglishGlossForPredicateInverse->{$args{Predicate}};
}

1;
