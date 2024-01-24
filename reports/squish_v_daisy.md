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

### Nevada

### North Carolina

NC has trees with INVYR == 9999 that are visited a second time in a
cycle. It also has trees changing counties and plots.

### Oregon

### South Carolina

### Tennessee

### Utah

### Virginia

### West Virginia

## All states

|   X | STATE | STATEFP | STATENS | STATE_NAME     | multiple_trees_or_cns | description                                                       |     n | n_trees_overall |
|----:|:------|--------:|--------:|:---------------|:----------------------|:------------------------------------------------------------------|------:|----------------:|
|   1 | AL    |       1 | 1779775 | Alabama        | trees                 | tree changes plot/county/unit                                     |    76 |          341392 |
|   2 | AK    |       2 | 1785533 | Alaska         | cns                   | cycle with missing PREV_TRE_CNs                                   |  8899 |          112462 |
|   3 | AZ    |       4 | 1779777 | Arizona        | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             |  1626 |           71627 |
|   4 | AR    |       5 |   68085 | Arkansas       | trees                 | tree changes plot/county/unit                                     |    26 |          212257 |
|   5 | CA    |       6 | 1779778 | California     | neither               | OK                                                                |     0 |          201767 |
|   6 | CO    |       8 | 1779779 | Colorado       | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             |  8536 |          145355 |
|   7 | CT    |       9 | 1779780 | Connecticut    | neither               | OK                                                                |     0 |           11734 |
|   8 | DE    |      10 | 1779781 | Delaware       | neither               | OK                                                                |     0 |            7106 |
|  10 | FL    |      12 |  294478 | Florida        | trees                 | tree changes plot/county/unit                                     |   110 |          165170 |
|  11 | GA    |      13 | 1705317 | Georgia        | both                  | cycle with missing PREV_TRE_CNs and tree changes plot/county/unit |   272 |          296533 |
|  12 | HI    |      15 | 1779782 | Hawaii         | neither               | OK                                                                |     0 |           14084 |
|  13 | ID    |      16 | 1779783 | Idaho          | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             |  1108 |          114697 |
|  14 | IL    |      17 | 1779784 | Illinois       | cns                   | cycle with missing PREV_TRE_CNs                                   |    14 |           34345 |
|  15 | IN    |      18 |  448508 | Indiana        | cns                   | cycle with missing PREV_TRE_CNs                                   |    23 |           54641 |
|  16 | IA    |      19 | 1779785 | Iowa           | neither               | OK                                                                |     0 |           19410 |
|  17 | KS    |      20 |  481813 | Kansas         | neither               | OK                                                                |     0 |           14558 |
|  18 | KY    |      21 | 1779786 | Kentucky       | trees                 | tree changes plot/county/unit                                     |   110 |           91639 |
|  19 | LA    |      22 | 1629543 | Louisiana      | neither               | OK                                                                |     0 |          146389 |
|  20 | ME    |      23 | 1779787 | Maine          | neither               | OK                                                                |     0 |          229423 |
|  21 | MD    |      24 | 1714934 | Maryland       | neither               | OK                                                                |     0 |           21362 |
|  22 | MA    |      25 |  606926 | Massachusetts  | neither               | OK                                                                |     0 |           23708 |
|  23 | MI    |      26 | 1779789 | Michigan       | neither               | OK                                                                |     0 |          494218 |
|  24 | MN    |      27 |  662849 | Minnesota      | cns                   | cycle with missing PREV_TRE_CNs                                   |    18 |          351211 |
|  25 | MS    |      28 | 1779790 | Mississippi    | neither               | OK                                                                |     0 |          217692 |
|  26 | MO    |      29 | 1779791 | Missouri       | neither               | OK                                                                |     0 |          153908 |
|  27 | MT    |      30 |  767982 | Montana        | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             |  2144 |          167422 |
|  28 | NE    |      31 | 1779792 | Nebraska       | neither               | OK                                                                |     0 |            8132 |
|  29 | NV    |      32 | 1779793 | Nevada         | both                  | multiple visits in one cycle with no PREV_TRE_CN link             |   424 |           44838 |
|  30 | NH    |      33 | 1779794 | New Hampshire  | neither               | OK                                                                |     0 |           68058 |
|  31 | NJ    |      34 | 1779795 | New Jersey     | neither               | OK                                                                |     0 |           24265 |
|  32 | NM    |      35 |  897535 | New Mexico     | neither               | OK                                                                |     0 |           86954 |
|  33 | NY    |      36 | 1779796 | New York       | neither               | OK                                                                |     0 |          156959 |
|  34 | NC    |      37 | 1027616 | North Carolina | neither               | tree changes plot/county/unit and INVYR = 9999                    |  1533 |          291155 |
|  35 | ND    |      38 | 1779797 | North Dakota   | neither               | OK                                                                |     0 |            5552 |
|  36 | OH    |      39 | 1085497 | Ohio           | neither               | OK                                                                |     0 |           58999 |
|  37 | OK    |      40 | 1102857 | Oklahoma       | neither               | OK                                                                |     0 |           71711 |
|  38 | OR    |      41 | 1155107 | Oregon         | trees                 | tree changes plot/county/unit                                     |    27 |          382221 |
|  39 | PA    |      42 | 1779798 | Pennsylvania   | neither               | OK                                                                |     0 |          132527 |
|  40 | RI    |      44 | 1219835 | Rhode Island   | neither               | OK                                                                |     0 |            5226 |
|  41 | SC    |      45 | 1779799 | South Carolina | neither               | tree changes plot/county/unit                                     |    22 |          213560 |
|  42 | SD    |      46 | 1785534 | South Dakota   | neither               | OK                                                                |     0 |           15193 |
|  43 | TN    |      47 | 1325873 | Tennessee      | cns                   | multiple visits in one cycle                                      |  1096 |          141400 |
|  44 | TX    |      48 | 1779801 | Texas          | neither               | OK                                                                |     0 |          258416 |
|  45 | UT    |      49 | 1455989 | Utah           | cns                   | multiple visits in one cycle with no PREV_TRE_CN link             |  2560 |           92537 |
|  46 | VT    |      50 | 1779802 | Vermont        | neither               | OK                                                                |     0 |           51461 |
|  47 | VA    |      51 | 1779803 | Virginia       | trees                 | tree changes plot/county/unit                                     |    32 |          203303 |
|  48 | WA    |      53 | 1779804 | Washington     | neither               | OK                                                                |     0 |          279379 |
|  49 | WV    |      54 | 1779805 | West Virginia  | cns                   | cycle with missing PREV_TRE_CNs                                   | 49095 |          111491 |
|  50 | WI    |      55 | 1779806 | Wisconsin      | neither               | OK                                                                |     0 |          323024 |
|  51 | WY    |      56 | 1779807 | Wyoming        | neither               | OK                                                                |     0 |          129626 |

    "","x"
    "1","C:/Users/renatadiaz/OneDrive - University of Arizona/Documents/GitHub/FIA/in-the-trees/reports/state_situations.csv"
