package SPSE2::GUI::Tab::View2::Info2;

use KBS2::Util::Metadata;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMetadata Context /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Context($args{Context} || "Org::PICForm::PIC::Vis::Metadata");
  $self->MyMetadata
    (KBS2::Util::Metadata->new
     (Context => $self->Context));
  $self->MyMetadata->LoadMetadata();
}

sub UnaryPredicates {
  my ($self,%args) = @_;
  my $res = $self->MyMetadata->GetMetadata
      (
       Predicate => "unary-predicate",
       Multivalued => 1,
      );
  if ($res->{Success}) {
    return [sort @{$res->{Result}}];
  } else {
    return [];
  }
}

sub InversibleBinaryPredicates {
  my ($self,%args) = @_;
  my $res = $self->MyMetadata->GetMetadata
      (
       Predicate => "inversible-binary-predicate",
       Multivalued => 1,
      );
  if ($res->{Success}) {
    return [sort @{$res->{Result}}];
  } else {
    return [];
  }
}

sub Fields {
  my ($self,%args) = @_;
  my $res = $self->MyMetadata->GetMetadata
      (
       Predicate => "field",
       Multivalued => 1,
      );
  if ($res->{Success}) {
    return [sort @{$res->{Result}}];
  } else {
    return [];
  }
}

sub BinaryRelationMap {
  my ($self,%args) = @_;
  my $binaryrelationmap = {};
  foreach my $inversiblebinarypredicate (@{$self->InversibleBinaryPredicates}) {
    my $englishgloss = $self->GetEnglishGlossForPredicate
      (
       Predicate => $inversiblebinarypredicate,
      );
    my $englishglossinverse = $self->GetEnglishGlossForPredicateInverse
      (
       Predicate => $inversiblebinarypredicate,
      );

    $binaryrelationmap->{$englishgloss} =
      {
       Predicate => $inversiblebinarypredicate,
      };
    $binaryrelationmap->{$englishglossinverse} =
      {
       Predicate => $inversiblebinarypredicate,
       Order => "inverse",
      };
  }
  return $binaryrelationmap;
}

sub Attributes {
  my ($self,%args) = @_;
  my $attributes = {};
  foreach my $inversiblebinarypredicate (@{$self->InversibleBinaryPredicates}) {
    my $res1 = $self->MyMetadata->GetMetadata
      (
       Predicate => "graph-color-for-predicate",
       Item => $inversiblebinarypredicate,
      );
    if ($res1->{Success}) {
      my $color = $res1->{Result};
      my $res2 = $self->MyMetadata->GetMetadata
	(
	 Predicate => "graph-label-for-predicate",
	 Item => $inversiblebinarypredicate,
	);
      if ($res2->{Success}) {
	my $label = $res2->{Result};
	my $res3 = $self->MyMetadata->GetMetadata
	  (
	   Predicate => "graph-label-for-negated-predicate",
	   Item => $inversiblebinarypredicate,
	  );
	if ($res3->{Success}) {
	  $labelnegated = $res3->{Result};
	  $attributes->{$label} = {
				   Color => $color,
				  };
	  $attributes->{$labelnegated} = {
					  Color => $color,
					  Style => "dashed",
					 };
	}
      }
    }
  }
  return $attributes;
}

sub FieldMap {
  my ($self,%args) = @_;
  my $fieldmap = {};
  foreach my $field (@{$self->Fields}) {
    my $res = $self->MyMetadata->GetMetadata
      (
       Predicate => "english-gloss-for-predicate",
       Item => $field,
      );
    if ($res->{Success}) {
      $fieldmap->{$res->{Result}} = $field;
    }
  }
  return $fieldmap;
}

sub GetEnglishGlossForPredicate {
  my ($self,%args) = @_;
  my $res = $self->MyMetadata->GetMetadata
    (
     Predicate => "english-gloss-for-predicate",
     Item => $args{Predicate},
    );
  if ($res->{Success}) {
    return $res->{Result};
  } else {
    return "ERROR";
  }
}

sub GetEnglishGlossForPredicateInverse {
  my ($self,%args) = @_;
  my $res = $self->MyMetadata->GetMetadata
    (
     Predicate => "english-gloss-for-predicate-inverse",
     Item => $args{Predicate},
    );
  if ($res->{Success}) {
    return $res->{Result};
  } else {
    return "ERROR";
  }
}

sub GetColorForUnaryPredicate {
  my ($self,%args) = @_;
  my $res1 = $self->MyMetadata->GetMetadata
    (
     Predicate => "graph-color-for-unary-predicate",
     Item => $args{Predicate},
    );
  if ($res1->{Success}) {
    my $color = $res1->{Result};
    if ($args{Selected}) {
      my $res2 = $self->MyMetadata->GetMetadata
	(
	 Predicate => "selected-color",
	 Item => $color,
	);
      if ($res2->{Success}) {
	return $res2->{Result};
      }
    } else {
      return $color;
    }
  }
  return "black";
}

sub GetPriorityForUnaryPredicate {
  my ($self,%args) = @_;
  my $res1 = $self->MyMetadata->GetMetadata
    (
     Predicate => "priority-for-unary-predicate",
     Item => $args{Predicate},
    );
  if ($res1->{Success}) {
    return $res1->{Result};
  }
  return 900;
}

1;
