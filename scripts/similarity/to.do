  # skip this for now, just repair the new system
  # now we need to know the asserter, etc.
  # search goals for any that entail this, using RTE or what not...
  # if nothing is found, create a new goal
  # (have the ability to assert guiding knowledge: for instance "it
  # is not necessary to do the goal similarity search just
  # yet (although I just remember the POSI code has it, as we are
  # more concerned about modelling domains.  we can entity resolve
  # later.  then also use entity resolution stuff.)" )

  # (string similarity)
  # (bag of words/baysesian similarity)
  # (system-finder similarity)
  # (meteor similarity)
  # (RTE)
  # (text clustering)
  # (anything that incorporates more information - try knext comparison)
  # (advanced text classification)
  # probably want to add this to the current context
  # see if it is okay to create this goal?


# doesn't really apply
# use Capability::Similarity::Semantic;

# this is similar to the RTE system I wrote that first clusters and then compares
# use Capability::TextClustering;

# don't see how this really applies
# use Capability::TextClassification;
