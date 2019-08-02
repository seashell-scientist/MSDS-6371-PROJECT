/* variables are Id Neighborhood Area SalePrice */
proc import out=work.raw datafile='/home/u38097850/DS6371/Project/Cleaned Training Data.csv' dbms=csv replace;
getnames=yes;
datarow=2;
run;

/* the three neighborhoods of interest for problem 1 */
data n3;
set raw (keep=Id Neighborhood Area SalePrice);
logp = log(SalePrice);
loga = log(Area);
run;

ods rtf file='/home/u38097850/DS6371/Project/Prob_1.rtf'; 

/* analyze residuals by neighborhood */
title 'NAmes Outliers';
proc reg data=n3 noprint;
model SalePrice = Area / r;
where Neighborhood = 'NAmes';
output out=NAmes_r student=studresids;
run;
proc sort data=NAmes_r; by studresids;
run;
proc print data=NAmes_r;
where studresids > 2.5;
run;
proc reg data=n3 noprint;
model SalePrice = Area / influence;
where Neighborhood = 'NAmes';
output out=NAmes_l h=leverage;
run;
proc sort data=NAmes_l; by leverage;
run;
proc print data=NAmes_l;
where leverage > 0.1;
run;

title 'Edwards outliers';
proc reg data=n3 noprint;
model logp = loga / r;
where Neighborhood = 'Edwards';
output out=Edwards_r student=studresids;
run;
proc sort data=Edwards_r; by studresids;
run;
proc print data=Edwards_r;
where studresids > 2.5;
run;
proc reg data=n3 noprint;
model SalePrice = Area / influence;
where Neighborhood = 'Edwards';
output out=Edwards_l h=leverage;
run;
proc sort data=Edwards_l; by leverage;
run;
proc print data=Edwards_l;
where leverage > 0.1;
run;


title 'BrkSide outliers';
proc reg data=n3 noprint;
model logp = loga / r;
where Neighborhood = 'BrkSide';
output out=BrkSide_r student=studresids;
run;
proc sort data=BrkSide_r; by studresids;
run;
proc print data=BrkSide_r;
where studresids > 2.5;
run;
proc reg data=n3 noprint;
model SalePrice = Area / influence;
where Neighborhood = 'BrkSide';
output out=BrkSide_l h=leverage;
run;
proc sort data=BrkSide_l; by leverage;
run;
proc print data=BrkSide_l;
where leverage > 0.1;
run;

/* reject some outliers */
data n3_noout;
set n3;
/* on scatter plot, area over 4000 looks out of place */
if Area > 4000 then delete;
/* these observations have Studentized residuals over 2.5 */
if Id = 889 then delete;
if Id = 643 then delete;
if Id = 725 then delete;
/* these observations have leverage over 0.1 */
if id = 1299 then delete;
if id = 524 then delete;
if Id = 534 then delete;
if Id = 329 then delete;
run;

title 'Original Data';
proc sgpanel data=n3;
panelby Neighborhood / columns=3 rows=1;
scatter x=Area y=SalePrice;
run;
proc glm data=n3 plot=all;
Class Neighborhood;
model SalePrice = Area | Neighborhood / clparm;
run;

title 'Original Data without outliers';
proc sgpanel data=n3_noout;
panelby Neighborhood / columns=3 rows=1;
scatter x=Area y=SalePrice;
run;
proc glm data=n3_noout plot=all;
Class Neighborhood;
model SalePrice = Area | Neighborhood / clparm;
run;

title 'Log Linear All data';
proc sgpanel data=n3;
panelby Neighborhood / columns=3 rows=1;
scatter x=Area y=logp;
run;
proc glm data=n3 plot=all;
Class Neighborhood;
model logp = Area | Neighborhood / clparm;
run;

title 'Log Linear No outliers';
proc sgpanel data=n3_noout;
panelby Neighborhood / columns=3 rows=1;
scatter x=Area y=logp;
run;
proc glm data=n3_noout plot=all;
Class Neighborhood;
model logp = Area | Neighborhood / clparm;
run;

ods rtf close;

