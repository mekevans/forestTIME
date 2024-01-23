# Comparison of daisy chain and tree number

## Context

The “daisy chain” method is to link backwards in time using
`PREV_TRE_CN` and `CN`. The “tree number” method is to concatenate
columns `STATECD`, `UNITCD`, `COUNTYCD`, `PLOT`, `SUBP`, and `TREE` to
get a unique tree number for each tree. In principle these *should* give
equivalent outcomes, but we don’t know if they really always do!

## Code

### Alabama

All 152 mismatches in Alabama take the form of 2 “TREE_UNIQUE_IDS” per 1
“TREE_FIRST_CN”.

In all of these instances, a PREV_TRE_CN links to a tree previously
found on a different plot. For example, this tree is on plot 93 for 2001
and 2009, and then on plot 133 for 2016. This gives it a new UNIQUE_ID
in 2016.

<div>

> **Note**
>
> Are these accurate, and the plot spatial arrangement changed, or in
> error?

</div>

### Alaska

All 17800 (!!) mismatches in Alaska have 2 TREE_FIRST_CNs per
TREE_UNIQUE_ID.

There is a deeper dive to be done, but there are no non-NA PREV_TRE_CNs
recorded for CYCLE=2 in Alaska. There are 8873 trees where that would
cause a break in the chain, of 8899 unique trees with a mismatch. The
remaining 52 skip from CYCLE=1 to CYCLE=3 and have an NA for PREV_TRE_CN
in CYCLE=3.

Overall, 225 trees (of the mismatch pool) show inconsistent species. For
what it’s worth, 540 trees of the whole dataset have at least 2 SPCDs
associated.

### Arizona

The mismatched records in Arizona have 2 surveys for CYCLE=3. There is a
set of early surveys (2001-2002), and a set of later surveys (2007-2008)
that don’t link via the PREV_TRE_CNs to the 2001-2 surveys.

### Arkansas

All the inconsistencies in Arkansas have a single CN recorded on two
separate plots in different counties and units. Most (perhaps all) of
the breaks occur between cycles 9 and 10 (2009-2014).

### California

There are no unmatched CNs in California (?!).

### Colorado

CO has the same syndrome as AZ.

### Connecticut

None

### Delaware

None

### Florida

Florida has trees changing location, at the county/unit level.

### Georgia

Georgia has *both* syndromes. Missing PREV_TRE_CN and changing location.

### Hawaii

None

### Idaho

### Illinois

### Indiana

### Iowa

None

### Kansas

None

### Kentucky

### Minnesota

### Montana

## All states

|   X | STATE | STATEFP | STATENS | STATE_NAME                                   | multiple_trees_or_cns | description                                                       | n_mismatches |     n |
|----:|:------|--------:|--------:|:---------------------------------------------|:----------------------|:------------------------------------------------------------------|:-------------|------:|
|   1 | AL    |       1 | 1779775 | Alabama                                      | trees                 | tree changes plot/county/unit                                     | NA           |   152 |
|   2 | AK    |       2 | 1785533 | Alaska                                       | cns                   | cycle with missing PREV_TRE_CNs                                   | NA           | 17798 |
|   3 | AZ    |       4 | 1779777 | Arizona                                      | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             | NA           |  3252 |
|   4 | AR    |       5 |   68085 | Arkansas                                     | trees                 | tree changes plot/county/unit                                     | NA           |    52 |
|   5 | CA    |       6 | 1779778 | California                                   | neither               | NA                                                                | NA           |    NA |
|   6 | CO    |       8 | 1779779 | Colorado                                     | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             | NA           | 17072 |
|   7 | CT    |       9 | 1779780 | Connecticut                                  | NA                    | NA                                                                | NA           |    NA |
|   8 | DE    |      10 | 1779781 | Delaware                                     | NA                    | NA                                                                | NA           |    NA |
|   9 | DC    |      11 | 1702382 | District of Columbia                         | NA                    | NA                                                                | NA           |    NA |
|  10 | FL    |      12 |  294478 | Florida                                      | trees                 | tree changes plot/county/unit                                     | NA           |   220 |
|  11 | GA    |      13 | 1705317 | Georgia                                      | both                  | cycle with missing PREV_TRE_CNs and tree changes plot/county/unit | NA           |   544 |
|  12 | HI    |      15 | 1779782 | Hawaii                                       | NA                    | NA                                                                | NA           |    NA |
|  13 | ID    |      16 | 1779783 | Idaho                                        | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             | NA           |  2216 |
|  14 | IL    |      17 | 1779784 | Illinois                                     | cns                   | cycle with missing PREV_TRE_CNs                                   | NA           |    28 |
|  15 | IN    |      18 |  448508 | Indiana                                      | cns                   | cycle with missing PREV_TRE_CNs                                   | NA           |    46 |
|  16 | IA    |      19 | 1779785 | Iowa                                         | NA                    | NA                                                                | NA           |    NA |
|  17 | KS    |      20 |  481813 | Kansas                                       | NA                    | NA                                                                | NA           |    NA |
|  18 | KY    |      21 | 1779786 | Kentucky                                     | trees                 | tree changes plot/county/unit                                     | NA           |   220 |
|  19 | LA    |      22 | 1629543 | Louisiana                                    | NA                    | NA                                                                | NA           |    NA |
|  20 | ME    |      23 | 1779787 | Maine                                        | NA                    | NA                                                                | NA           |    NA |
|  21 | MD    |      24 | 1714934 | Maryland                                     | NA                    | NA                                                                | NA           |    NA |
|  22 | MA    |      25 |  606926 | Massachusetts                                | NA                    | NA                                                                | NA           |    NA |
|  23 | MI    |      26 | 1779789 | Michigan                                     | NA                    | NA                                                                | NA           |    NA |
|  24 | MN    |      27 |  662849 | Minnesota                                    | cns                   | cycle with missing PREV_TRE_CNs                                   | NA           |    36 |
|  25 | MS    |      28 | 1779790 | Mississippi                                  | NA                    | NA                                                                | NA           |    NA |
|  26 | MO    |      29 | 1779791 | Missouri                                     | NA                    | NA                                                                | NA           |    NA |
|  27 | MT    |      30 |  767982 | Montana                                      | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             | NA           |  4288 |
|  28 | NE    |      31 | 1779792 | Nebraska                                     | NA                    | NA                                                                | NA           |    NA |
|  29 | NV    |      32 | 1779793 | Nevada                                       | NA                    | NA                                                                | NA           |   848 |
|  30 | NH    |      33 | 1779794 | New Hampshire                                | NA                    | NA                                                                | NA           |    NA |
|  31 | NJ    |      34 | 1779795 | New Jersey                                   | NA                    | NA                                                                | NA           |    NA |
|  32 | NM    |      35 |  897535 | New Mexico                                   | NA                    | NA                                                                | NA           |    NA |
|  33 | NY    |      36 | 1779796 | New York                                     | NA                    | NA                                                                | NA           |    NA |
|  34 | NC    |      37 | 1027616 | North Carolina                               | NA                    | NA                                                                | NA           |  3066 |
|  35 | ND    |      38 | 1779797 | North Dakota                                 | NA                    | NA                                                                | NA           |    NA |
|  36 | OH    |      39 | 1085497 | Ohio                                         | NA                    | NA                                                                | NA           |    NA |
|  37 | OK    |      40 | 1102857 | Oklahoma                                     | NA                    | NA                                                                | NA           |    NA |
|  38 | OR    |      41 | 1155107 | Oregon                                       | NA                    | NA                                                                | NA           |    54 |
|  39 | PA    |      42 | 1779798 | Pennsylvania                                 | NA                    | NA                                                                | NA           |    NA |
|  40 | RI    |      44 | 1219835 | Rhode Island                                 | NA                    | NA                                                                | NA           |    NA |
|  41 | SC    |      45 | 1779799 | South Carolina                               | NA                    | NA                                                                | NA           |    NA |
|  42 | SD    |      46 | 1785534 | South Dakota                                 | NA                    | NA                                                                | NA           |    NA |
|  43 | TN    |      47 | 1325873 | Tennessee                                    | NA                    | NA                                                                | NA           |    NA |
|  44 | TX    |      48 | 1779801 | Texas                                        | NA                    | NA                                                                | NA           |    NA |
|  45 | UT    |      49 | 1455989 | Utah                                         | NA                    | NA                                                                | NA           |    NA |
|  46 | VT    |      50 | 1779802 | Vermont                                      | NA                    | NA                                                                | NA           |    NA |
|  47 | VA    |      51 | 1779803 | Virginia                                     | NA                    | NA                                                                | NA           |    NA |
|  48 | WA    |      53 | 1779804 | Washington                                   | NA                    | NA                                                                | NA           |    NA |
|  49 | WV    |      54 | 1779805 | West Virginia                                | NA                    | NA                                                                | NA           |    NA |
|  50 | WI    |      55 | 1779806 | Wisconsin                                    | NA                    | NA                                                                | NA           |    NA |
|  51 | WY    |      56 | 1779807 | Wyoming                                      | NA                    | NA                                                                | NA           |    NA |
|  52 | AS    |      60 | 1802701 | American Samoa                               | NA                    | NA                                                                | NA           |    NA |
|  53 | GU    |      66 | 1802705 | Guam                                         | NA                    | NA                                                                | NA           |    NA |
|  54 | MP    |      69 | 1779809 | Commonwealth of the Northern Mariana Islands | NA                    | NA                                                                | NA           |    NA |
|  55 | PR    |      72 | 1779808 | Puerto Rico                                  | NA                    | NA                                                                | NA           |    NA |
|  56 | UM    |      74 | 1878752 | U.S. Minor Outlying Islands                  | NA                    | NA                                                                | NA           |    NA |
|  57 | VI    |      78 | 1802710 | United States Virgin Islands                 | NA                    | NA                                                                | NA           |    NA |
