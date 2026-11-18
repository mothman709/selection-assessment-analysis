/*==========================================================================
  Selection assessment analysis
  Author: Mohammed Othman

  Purpose
  Find out which hiring assessment items predict sales associate performance,
  whether using them would disadvantage any group, and how to combine them.

  Data
  The data file is not included in this repository. It belongs to a course
  case. Put your own copy at the path in &datafile below. It needs these
  columns (see the README for what each one means):
  Race, cog, r1, r2, Inf, it1-it15, sex
==========================================================================*/

%let datafile = /path/to/WorkingData.csv;   * change this to your file;


/*--------------------------------------------------------------------------
  1. Import the data
--------------------------------------------------------------------------*/
proc import datafile="&datafile"
    dbms=csv out=tempwork replace;
run;


/*--------------------------------------------------------------------------
  2. Factor analysis of the 15 items
  Check how many things the items measure. Three factors came out.
--------------------------------------------------------------------------*/
proc factor data=tempwork method=ml rotate=promax;
    var it1-it15;
run;


/*--------------------------------------------------------------------------
  3. Build the scales and outcomes
  c = conscientiousness (items 3, 5, 8, 11, 14)
  e = emotional stability (items 4, 6, 7, 13, 15)
  w = counterproductive work behavior, CWB (items 1, 2, 9, 10, 12)
  Items 1, 2, 9, 10 and 12 are reverse scored (8 minus the response).
  Z scores use the sample means and standard deviations. The constants
  below were taken from PROC MEANS on this data.
--------------------------------------------------------------------------*/
data work;
    set tempwork;

    * reverse scoring;
    it1r  = 8 - it1;
    it2r  = 8 - it2;
    it9r  = 8 - it9;
    it10r = 8 - it10;
    it12r = 8 - it12;

    * predictor scales;
    c = mean(it3, it5, it8, it11, it14);
    e = mean(it4, it6, it7, it13, it15);
    w = mean(it1r, it2r, it9r, it10r, it12r);

    * outcomes;
    Sup     = (r1 + r2) / 2;                    * average of the two manager ratings;
    Infr    = 4 - Inf;                          * reverse coded so higher is better;
    Infrz   = (Infr - 3.3733333) / 0.8779033;
    Supz    = (Sup  - 6.1177778) / 1.5325762;
    Outcome = (Infrz + Supz) / 2;               * combined outcome;

    * standardized predictors;
    cogz = (cog - 107.07) / 13.54;
    cz   = (c   - 3.98)   / 0.83;
    wz   = (w   - 3.98)   / 0.86;

    * composites using the three recommended predictors;
    UnitComp = mean(cogz, cz, wz);              * equal weights;
    OptComp  = (.33005 * cogz)                  * regression weights;
             + (.27347 * cz)
             + (.30258 * wz);
run;

proc means data=work;
    var cog c w;
run;


/*--------------------------------------------------------------------------
  4. Reliability of each scale (Cronbach's alpha)
--------------------------------------------------------------------------*/
proc corr data=tempwork alpha;
    var it3 it5 it8 it11 it14;                  * conscientiousness;
run;

proc corr data=tempwork alpha;
    var it4 it6 it7 it13 it15;                  * emotional stability;
run;

proc corr data=work alpha;
    var it1r it2r it9r it10r it12r;             * CWB;
run;


/*--------------------------------------------------------------------------
  5. Correlations between predictors and outcomes
--------------------------------------------------------------------------*/
* agreement between the two managers;
proc corr data=work;
    var r1 r2;
run;

proc corr data=work;
    var cog c e w;                              * predictors with each other;
run;

proc corr data=work;
    var cog c e w sup inf;                      * predictors with outcomes;
run;


/*--------------------------------------------------------------------------
  6. Regressions
  Which predictors add something once the others are in the model.
  scorr2 gives the unique variance each predictor explains.
--------------------------------------------------------------------------*/
proc reg data=work;
    model sup inf = cog c e w;
run;

proc reg data=work;
    model sup inf = cog c e w / scorr2;
run;


/*--------------------------------------------------------------------------
  7. Group differences by sex and race
--------------------------------------------------------------------------*/
proc ttest data=work; class sex;  var Sup;     run;
proc ttest data=work; class sex;  var Cog;     run;
proc ttest data=work; class race; var Sup;     run;
proc ttest data=work; class race; var cog;     run;
proc ttest data=work; class sex;  var Outcome; run;
proc ttest data=work; class race; var Outcome; run;


/*--------------------------------------------------------------------------
  8. Combined outcome, and the two weighting methods
--------------------------------------------------------------------------*/
proc reg data=work;
    model Outcome = cog c e w / stb scorr2;
run;

proc reg data=work;
    model Outcome = UnitComp / stb scorr2;
run;

proc reg data=work;
    model Outcome = OptComp / stb scorr2;
run;


/*--------------------------------------------------------------------------
  9. Adverse impact
  Hire the top 100 of the 225 people under each weighting method, then
  compare selection rates between groups.
  Race: 1 = white, 0 = non-white.  Sex: 1 = female, 0 = male.
  Adverse impact ratio = selection rate of the lower group divided by
  the selection rate of the higher group. Below 0.80 is the usual warning line.
--------------------------------------------------------------------------*/
proc rank data=work out=ranked descending ties=low;
    var UnitComp OptComp;
    ranks UnitRank OptRank;
run;

data ranked;
    set ranked;
    UnitHired = (UnitRank <= 100);
    OptHired  = (OptRank  <= 100);
run;

* number hired from each group, equal weights;
proc freq data=ranked;
    tables Race*UnitHired sex*UnitHired / nopercent nocol;
run;

* number hired from each group, regression weights;
proc freq data=ranked;
    tables Race*OptHired sex*OptHired / nopercent nocol;
run;

* adverse impact ratios;
proc sql;
    create table ai_ratios as
    select 'Unit weighting' as Method,
           (sum(UnitHired*(Race=0)) / sum(Race=0)) /
           (sum(UnitHired*(Race=1)) / sum(Race=1)) as Race_AI format=5.2,
           (sum(UnitHired*(sex=1))  / sum(sex=1))  /
           (sum(UnitHired*(sex=0))  / sum(sex=0))  as Sex_AI  format=5.2
    from ranked
    union all
    select 'Optimal weighting',
           (sum(OptHired*(Race=0)) / sum(Race=0)) /
           (sum(OptHired*(Race=1)) / sum(Race=1)),
           (sum(OptHired*(sex=1))  / sum(sex=1))  /
           (sum(OptHired*(sex=0))  / sum(sex=0))
    from ranked;
quit;

proc print data=ai_ratios noobs;
run;
