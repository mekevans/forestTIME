# QA flags

Currently, the query functions are returning data as-is, as it was downloaded from FIA DB. 
There are a number of potential data quality issues that we may not need to filter out completely, but should at least notify users about (and probably provide the option to filter out).

The following emerge from the forestTIME data:

* A tree has a PREV_TRE_CN that would have it showing up in a different location (county/unit/plot).
* A tree changes SPCD over time.
* A tree has been visited multiple times per CYCLE.
* A tree has had multiple OWNCDs over time.

Others are recorded within FIADB itself:

* STATUSCD
* ACTUALHT vs HT
* others?