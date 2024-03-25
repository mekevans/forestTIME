# Ingrowth/seedlings

Here is Renata's understanding of the seedlings/ingrowth problem:

* On each *microplot*, saplings between 1 and 5 cm DBH are assigned tree numbers and tracked through time. 
* On each subplot *outside of* the microplot, the minimum DBH to be measured and tracked is 5cm.
* We would like an estimate of the *biomass* and *survival* of saplings across the *whole plot*.
* Biomass (snapshot in time):
  * Calculate the biomass of saplings on the microplot
  * Multiply by the subplot scaling factor (what % of area is microplot? Possibly complicated by condition, etc; this variable is provided in FIADB - *right? where?*).
* Survival (survey-to-survey):
  * Calculate transition proportions/probabilities:
      * Sapling --> Tree
      * Sapling --> Sapling
      * Sapling --> Dead
      * Nothing --> Sapling
      * (Cannot calculate Nothing --> Tree without doing some fancy mapping)
  * There are some additional things that can happen:
      * Sapling that die may simply not be recorded next census. This is accomplished by tracking how many saplings in year X don't show up in year X + 1.
      * Saplings may get a STATUSCD == 0 in the next census.
      * Saplings may have a STATUSCD == 1 in a census and not be sampled (maybe if they are on the wrong CONDITION?).
  * If you do this only focusing on Saplings, you can then scale to the whole plot/subplot by multiplying by the %area accounted for by the microplot. 
  
  
(There is then another ingrowth question of seedling --> sapling transitions, which is harder to reconcile directly because seedlings are not given identifying numbers. I believe.)