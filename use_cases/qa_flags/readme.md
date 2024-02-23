# QA flags

Currently, the query functions are returning data as-is, as it was downloaded from FIA DB. 
There are a number of potential data quality issues that we may not need to correct or filter out completely, but should at least notify users about (and probably provide the option to correct/remove).

Here are what Renata has seen in the data so far, and proposed responses:

* A tree has a PREV_TRE_CN that would have it showing up in a different location (county/unit/plot).
    * ??? Flag? Filter out if identifying trees using the CN's method?
* A tree changes SPCD over time.
    * Flag + default to replacing with the most recently recorded SPCD
* A tree has been visited multiple times per CYCLE.
    * ??? Flag? Filter out (usually the first) visit? 
    * Usually I see this where the PREV_TRE_CN is not recorded for one of the visits. 
* A tree has had multiple OWNCDs over time.
    * ??? Is this a flag or likely valid?
* A tree has had a STATUSCD == 2 (dead) or maybe 3 (removed) and then later shows up with a STATUSCD == 1 again. 
    * Flag + default to overwriting previous "dead" records as "alive".

Others are recorded within FIADB itself:

* STATUSCD
* ACTUALHT vs HT
* others?