#!/usr/bin/perl -w

use KBS2::Client;

my $context = "Org::PICForm::PIC::Vis::Metadata::Argumentation";
my $client = KBS2::Client->new
  (
   Context => $context,
  );

my $assertions =
  [
   ["multivalued-predicate", "field"],
   ["multivalued-predicate", "inversible-binary-predicate"],
   ["multivalued-predicate", "unary-predicate"],
  ];

# handle colors
my $colors = {
	      "blue" => ["DeepSkyBlue","DodgerBlue"],
	      "red" => ["indian red","maroon"],
	      "brown" => ["peru", "saddle brown"],
	     };

# ["selected-color", "DeepSkyBlue", "DodgerBlue"],

# LOOK AT OPENCYC TO GET IDEAS FOR RELATIONSHIPS
my $logics =
  {
   "picform" => {
		 Unary => {
			  },
		 InvertibleBinary => {
				     },
		 Fields => [],
		 Objects => {
			    },
		},
   "temporal" => {
		  Unary => {
			    "next" => ["unknown"],
			    "future" => ["unknown"],
			    "globally" => ["unknown"],
			    "all" => ["unknown"],
			    "exists" => ["unknown"],
			   },
		  AssymetricBinary => {
				       "until" => {
						   Color => "unknown",
						   ReasonForColor => "",
						   Meaning => "",
						   Arg1Isa => "",
						   Arg2Isa => "",
						  },
				       "release" => {
						     Color => "unknown",
						     ReasonForColor => "",
						     Meaning => "",
						     Arg1Isa => "",
						     Arg2Isa => "",
						    },
				      },
		  InvertibleBinary => {

				      },
		  Fields => [],
		  Objects => {
			     },
		 },
   "alethic" => {
		 Unary => {
			   "possible" => ["yellow"],
			   "necessary" => ["green"],
			  },
		 InvertibleBinary => {
				     },
		 Fields => [],
		 Objects => {
			    },
		},
   "workflow" => {
		  Unary => {
			   },
		  InvertibleBinary => {
				      },
		  Fields => [],
		  Objects => {
			     },
		 },
   "argumentation" => {
		       Unary => {
				 "established" => ["green"],
				 "refuted" => ["red"],
				 "indeterminate" => ["brown"],
				 "unknown" => ["yellow"],
				},
		       InvertibleBinary => {
					    "supports" => ["Supports","Supported by", "black"],
					    "refutes" => ["Refutes", "Refuted by", "red"],
					    "implies" => ["Implies", "Implied by", "green"],
					   },
		       Fields => [],
		       Objects => {
				  },
		      },
   "intelligent tutoring" => {
			      Unary => {
					"mastered" => ["green"],
					"failed" => ["red"],
				       },
			      InvertibleBinary => {
						   "prerequisite" => ["Prequisite of","Prerequisite for","red"],
						   # ReasonForColor => "cannot learn the one without the other, hence stop until this is complete - similar to depends",
						  },
			      Fields => [],
			      Objects => {
					 },
			     },

   "intelligent agent" => {
			   Unary => {
				    },
			   AssymetricBinary => {
						"obligatory" => {
								 Color => "black",
								 ReasonForColor => "seems formal",
								 Arg1Isa => "agent",
								 Arg2Isa => "proposition",
								},
						"permitted" => {
								Color => "green",
								ReasonForColor => "a green light, a go-ahead",
								Meaning => "permissible",
								Arg1Isa => "agent",
								Arg2Isa => "proposition",
							       },
						"forbidden" => {
								Color => "red",
								ReasonForColor => "a red light, a no-go",
								Meaning => "impermissible/forbidden/prohibited",
								Arg1Isa => "agent",
								Arg2Isa => "proposition",
							       },
						"supererogatory" => {
								     Color => "red",
								     ReasonForColor => "a red light, a no-go",
								     Meaning => "beyond the call of duty",
								     Arg1Isa => "agent",
								     Arg2Isa => "proposition",
								    },
						"significant" => {
								  Color => "red",
								  ReasonForColor => "a red light, a no-go",
								  Meaning => "versus indifferent",
								  Arg1Isa => "agent",
								  Arg2Isa => "proposition",
								 },
						"omissible" => {
								Color => "red",
								ReasonForColor => "a red light, a no-go",
								Arg1Isa => "agent",
								Arg2Isa => "proposition",
							       },
						"the-least-one-can-do" => {
									   Color => "red",
									   ReasonForColor => "a red light, a no-go",
									   Arg1Isa => "agent",
									   Arg2Isa => "proposition",
									  },
						"better-than" => {
								  Color => "red",
								  ReasonForColor => "a red light, a no-go",
								  Arg1Isa => "agent",
								  Arg2Isa => "proposition",
								 },
						"best" => {
							   Color => "red",
							   ReasonForColor => "a red light, a no-go",
							   Arg1Isa => "agent",
							   Arg2Isa => "proposition",
							  },
						"good" => {
							   Color => "red",
							   ReasonForColor => "a red light, a no-go",
							   Arg1Isa => "agent",
							   Arg2Isa => "proposition",
							  },
						"bad" => {
							  Color => "red",
							  ReasonForColor => "a red light, a no-go",
							  Arg1Isa => "agent",
							  Arg2Isa => "proposition",
							 },
						"ought" => {
							    Color => "red",
							    ReasonForColor => "a red light, a no-go",
							    Arg1Isa => "agent",
							    Arg2Isa => "proposition",
							   },
						"claim || liberty || power || immunity" => {

											   },
						"knows" => {
							    Color => "blue",
							    ReasonForColor => "?",
							    Arg1Isa => "agent",
							    Arg2Isa => "proposition",
							   },
						"everybody-knows" => {
								      Color => "blue",
								      ReasonForColor => "?",
								      Arg1Isa => "proposition",
								     },
						"distributed-knowledge" => {
									    Color => "blue",
									    ReasonForColor => "?",
									    Arg1Isa => "agent-set",
									    Arg2Isa => "proposition",
									   },
						"common-knowledge" => {
								       Color => "royal blue",
								       ReasonForColor => "?",
								       Arg1Isa => "agent-set",
								       Arg2Isa => "proposition",
								      },
						"believe" => {
							      Color => "light blue",
							      ReasonForColor => "it is a lighter form of know, hence the light color.  the light theme with believe, intend, desire",
							      Arg1Isa => "agent-set",
							      Arg2Isa => "proposition",
							     },
						"intend" => {
							     Color => "light green",
							     ReasonForColor => "green is green-light, a go-ahead, to intend to.  the light theme with believe, intend, desire",
							     Arg1Isa => "agent-set",
							     Arg2Isa => "proposition",
							    },
						"desire" => {
							     Color => "light red",
							     ReasonForColor => "red is often a sexual color, and the theme of desire.  the light theme with believe, intend, desire",
							     Arg1Isa => "agent-set",
							     Arg2Isa => "proposition",
							    },
						"ability" => {
							      Color => "purple",
							      ReasonForColor => "purple is the color of royalty, hence ability.  couldn't think of anything else.",
							      Arg1Isa => "agent-set",
							      Arg2Isa => "proposition",
							     },
						"opportunity" => {
								  Color => "gold",
								  ReasonForColor => "opportunity/money",
								  Arg1Isa => "agent-set",
								  Arg2Isa => "proposition",
								 },
						"enforce" => {
							      Color => "steel",
							      ReasonForColor => "steel is a color of weapons, hence force",
							      Arg1Isa => "agent-set",
							      Arg2Isa => "proposition",
							     },
						"sometime" => {
							       Color => "grey",
							       ReasonForColor => "grey is a lighter color, seems to imply not solid, i.e. not all the time",
							       Arg1Isa => "timestep",
							       Arg2Isa => "proposition",
							      },
						"always" => {
							     Color => "black",
							     ReasonForColor => "a solid color, seems like always",
							     Arg1Isa => "proposition",
							    },
						"eventually" => {
								 Color => "light green",
								 ReasonForColor => "similar to intend, it implies eventuality eventually",
								 Arg1Isa => "timestep",
								 Arg2Isa => "proposition",
								},
						"in-the-next-state" => {
									Color => "green",
									ReasonForColor => "green is for ripened fruit, which will be ripe soon",
									Arg1Isa => "timestep",
									Arg2Isa => "proposition",
								       },
						"has-member" => {
								 Color => "orange",
								 ReasonForColor => "no reason",
								 Arg1Isa => "coalition",
								 Arg2Isa => "agent",
								},
					       },
			   InvertibleBinary => {
					       },
			   Fields => [],
			   Objects => {
				       "proposition" => {},
				       "agent" => {},
				       "agent-set" => {},
				       "coalition" => {},
				      },
			  },
   "metamathematics" => {
			 Unary => {
				  },
			 InvertibleBinary => {
					     },
			 Fields => [],
			 Objects => {
				    },
			},
   "network mapper" => {
			Unary => {

				 },
			InvertibleBinary => {
					     "8021n wireless connection" => ["", "", "unknown"],
					     "cat 5e cable" => ["", "", "unknown"],
					     "crossover cable" => ["", "", "unknown"],
					    },
			Fields => [],
			Objects =>
			{
			 "router" => {},
			 "switch" => {},
			 "computer" => {},
			 "desktop" => {},
			 "laptop" => {},
			},
		       },
   "posi" => {
	      Unary => {
		       },
	      InvertibleBinary => {
				   "has-project" => ["","","unknown"],
				   "has-interest" => ["","","unknown"],
				   "has-goal" => ["","","unknown"],
				   "has-ability" => ["","","unknown"],
				   "requires-ability" => ["","","unknown"],
				  },
	      Fields => [],
	      Objects => {
			  "person" => {},
			  "project" => {},
			  "subject" => {},
			  "interest" => {},
			  "goal" => {},
			  "ability" => {},
			 },
	     },
   "social networking" => {
			   Unary => {
				    },
			   InvertibleBinary => {
						"has-friend" => ["","","unknown"],
						"has-acquaintence" => ["","","unknown"],
						"not-talking" => ["","","unknown"],
					       },
			   Fields => [],
			   Objects => {
				      },
			  },
   "suppositional reasoner" => {
				Unary => {
					 },
				InvertibleBinary => {
						    },
				Fields => [],
				Objects => {
					   },
			       },
   "tactics" => {
		 Unary => {
			  },
		 InvertibleBinary => {
				     },
		 Fields => [],
		 Objects => {
			    },
		},

   "contexts" => {
		  Unary => {
			   },
		  InvertibleBinary => {
				       "inherits" => ["","","unknown"],
				       "isa" => ["","","unknown"],
				       "genls" => ["","","unknown"],
				      },
		  Fields => [],
		  Objects => {
			     },
		 },

   "genealogy" => {
		   Unary => {
			    },
		   InvertibleBinary => {
					"Son" => ["Son of", "", "black"],
					"Daughter" => ["Daughter of", "", "black"],
					"Brother" => ["Brother of", "", "black"],
					"Sister" => ["Sister of", "", "black"],
					"Husband" => ["Husband of", "", "black"],
					"Wife" => ["Wife of", "", "black"],
				       },
		   Fields => [],
		   Objects => {
			      },
		  },

   "inventory" => {
		   Unary => {
			     "broken" => ["black"],
			     "lost" => ["grey"],
			     "dirty" => ["brown"],
			     "borrowed" => ["unknown"],
			    },
		   InvertibleBinary => {
					"on-top-of" => ["On top of", "holding up", "black"],
					"inside" => ["Inside","","black"],
					"beside" => ["Beside","","black"],
					"below" => ["Below","","black"],
					"supporting" => ["Supporting","","black"],
					"attached-to" => ["Attached to","","black"],
				       },
		   Fields => [],
		   Objects => {
			       "" => {},
			      },
		  },

   "critic" => {
		Unary => {
			 },
		InvertibleBinary => {
				     "prefer" => ["","","unknown"],
				    },
		Fields => [],
		Objects => {
			   },
	       },

   "doxastic" => {
		  Unary => {
			   },
		  InvertibleBinary => {
				      },
		  Fields => [],
		  Objects => {
			     },
		 },

   "deontic" => {
		 Unary => {
			   # "must" => [""],

			   "obligatory" => ["green"],
			   "ought" => [""],
			   "permissible" => ["yellow"],
			   "forbidden" => ["red"],

			   "supererogatory" => ["gold"],

			   "omissible" => [""],
			   "optional" => [""],
			   "indifferent" => [""],

			   "the least one can do" => ["bronze"],

			   "best" => ["gold"],
			   "good" => ["silver"],
			   "bad" => ["bronze"],

			  },
		 InvertibleBinary => # claim || liberty || power || immunity
		 {
		  "better than" => ["Better than","Not as good as","purple"],
		 },
		 Fields => [],
		 Objects => {
			    },
		},
   "planning" => {
		  Unary => {
			    "completed" => ["blue"],
			    "deleted" => ["brown"],
			    "cancelled" => ["brown"],
			    "ridiculous" => ["brown"],
			    "obsoleted" => ["brown"],
			    "rejected" => ["brown"],
			    "skipped" => ["brown"],
			    "showstopper" => ["red"],
			   },
		  InvertibleBinary => {
				       "depends" => ["Depends on", "Precondition for", "red"]
				       "eases" => ["Eases", "Eased by", "gold"]
				       "provides" => ["Provides", "Provided by", "green"]
				       "prefer" => ["Prefer", "Deferred to", "purple"]
				      },
		  Fields => [
			     "costs", "disputed", "comment", "solution", "assigned-by", "has-feeling", "assigned-to", "belongs-to-system"
			    ],
		  Objects => {
			     },
		 },
  };

foreach my $logic (keys %$logics) {
  foreach my $pred (@{$logics->{$logic}->[0]}) {
    push @$assertions, ["unary-predicate", $pred];
    push @$assertions, ["english-gloss-for-predicate", $pred, Capitalize($pred)];
    push @$assertions, ["graph-color-for-unary-predicate", "possible", "yellow"],
  }

  foreach my $key (keys %{$logics->{$logic}->[1]}) {
    my $items =
      [
       ["inversible-binary-predicate", $pred],
       ["english-gloss-for-predicate", $pred, $binary->{$key}->[0]],
       ["english-gloss-for-predicate-inverse", $pred, $binary->{$key}->[1]],
       ["graph-label-for-predicate", $pred, $pred],
       ["graph-label-for-negated-predicate", $pred, "not $pred"],
       ["graph-color-for-predicate", $pred, $binary->{$key}->[2]],
      ];
    push @$assertions, @$items;
  }

  foreach my $field (@{$logics->{$logic}->[2]}) {
    push @$assertions, ["field", $field];
    push @$assertions, ["english-gloss-for-predicate", $field, Capitalize($field)];
  }
}

foreach my $assertion (@$assertions) {
  my %sendargs =
    (
     Assert => [$assertion],
     Context => $context,
     QueryAgent => 1,
     InputType => "Interlingua",
     Flags => {
	       AssertWithoutCheckingConsistency => 1,
	      },
    );

  my $res = $client->Send
    (
     %sendargs,
    );
  # print Dumper($res);
}
