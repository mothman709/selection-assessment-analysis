proc import datafile="/home/u64226081/Data Analysis projects/WorkingData (2).csv"
dbms=csv out=tempwork replace;
run;

proc factor data=work method=ml rotate=promax;
   var it1-it15;
run;


data work;
   set tempwork;
   it1r = 8 - it1;
   it2r = 8 - it2;
   it9r = 8 - it9;
   it10r = 8 - it10;
   it12r = 8 - it12;
   c = mean(it3, it5, it8, it11, it14);
   e = mean(it4, it6, it7, it13, it15);
   w = mean(it1r, it2r, it9r, it10r, it12r);
   Sup = (r1 + r2)/2;
   Infr = 4-Inf;
   Infrz = (infr - 3.3733333)/0.8779033;
   Supz = (sup - 6.1177778)/1.5325762;
   Outcome = (Infrz + supz)/2;
   cogz = (cog - 107.07)/13.54;
	cz   = (c - 3.98)/0.83;
	wz   = (w - 3.98)/0.86;
	UnitComp = mean(cogz, cz, wz);
	 OptComp = (.33005*cogz)
           + (.27347*cz)
           + (.30258*wz);
run;

proc means data=work;
	var cog c w;
	run;

proc corr data=tempwork alpha;
   var it3 it5 it8 it11 it14;
run;

proc corr data=tempwork alpha;
   var it4 it6 it7 it13 it15;
run;

proc corr data=work alpha;
   var it1r it2r it9r it10r it12r;
run;

proc print data=work;
run;

proc corr data=work;
var cog c e w;
run;


* will not do interrater realiblitiy becasue it is complicated;
proc corr data=work;
   var r1 r2;
run;


* all measure correlates as expected;
proc corr data= work;
	var cog c e w sup inf;
run;

* all predict which is good but we should get partial squared correalion to see the uniqe vairance;
proc reg data=work;
	model sup inf = cog c e w;
run;

* with squared semi parital correaltion;
proc reg data=work;
	model sup inf = cog c e w/ scorr2;
run;


*Differences between sexes and genders;
proc ttest data=work;
    class sex;
    var Sup;
run;


proc ttest data=work;
    class sex;
    var Cog;
run;

proc ttest data=work;
    class race;
    var Sup;
run;

proc ttest data=work;
    class race;
    var cog;
run;

proc ttest data=work;
    class sex;
    var Outcome;
run;

proc ttest data=work;
    class race;
    var Outcome;
run;


* compisite scores ( outcome) the difference between sexs disapeear and the effect for race shrink yet still sig;
proc reg data=work;
	model Outcome = cog c e w/ stb scorr2;
run;


* regression with the unit and optimal wieghting;
proc reg data=work;
	model Outcome = UnitComp/ stb scorr2;
run;


proc reg data=work;
	model Outcome = OptComp/ stb scorr2;
run;




