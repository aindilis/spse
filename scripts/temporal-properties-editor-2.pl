# go ahead and build a temporal properties editor


# due-date-for-entry

# start-date
# end-date
# duration

# improve this in the future - for now, just make something simple.
# have a version 2 that has more advanced temporal specification
# capabilities - as we collect requirements and engineer it better.


# have several different modes: past, present and future


# we want a few buttons



# here is what we can have
# start-date selector (has a time widget to pop up;5~)


# PAST

# (due-date-for-entry (entry-fn pse 325235) "1 hours")


# (has-time-constraints (entry-fn pse 325235))
# (possible (entry-fn pse 325235))
# (start-date (entry-fn pse 325235) "TZID=America/Chicago:20090404T100000")
# (end-date (entry-fn pse 325235) "TZID=America/Chicago:20090404T100000")
# (event-duration (entry-fn pse 325235) "1 hours")



# (start-goal (entry-fn pse 325235))
# (finish-goal (entry-fn pse 325235))




# PRESENT
# (due-date-for-entry (entry-fn pse 325235) "Now, in one hour, in three and a half days, before noon tomorrow")
# use timex3?
# (before (entry-fn pse 325235) (entry-fn pse 325235))
# (after (entry-fn pse 325235) (entry-fn pse 325235))


# we want to specify when something is possible

# can have relative or absolute properties



# it is supposed to be relative to a certain time




# (event-duration (entry-fn pse 325235) "1 hours")

# interpret locations, etc perhaps stave off for a future system

# (due-date-for-entry-relative "Now, in one hour, in three and a half days" timestamp location)

# start-date
# end-date
# duration

# completed
# (start-date TZID=America/Chicago:20100416T144640)
# (units 0000-00-00_01:00:00)

# (have a before, after, during, etc, regular temporal logic skip for now)
