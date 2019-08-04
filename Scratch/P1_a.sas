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

ods rtf file='/home/u38097850/DS6371/Project/Prob_1_results.rtf';

title 'Untransfomed Data with all points';

proc sgpanel data=n3;
panelby Neighborhood / columns=3 rows=1;symbol c=blue v=dot;
scatter x=Area y=SalePrice;
run;

ods text="From the initial scatter plot, it is clear that homes over 4000 
square feet do not fit in this population.  We will drop them and continue.";

data n3_no_large;
set n3;
if Area > 4000 then delete;
run;

title1 'No large homes';
title2 'untransformed';
proc glm data=n3_no_large plot=all;
Class Neighborhood;
model SalePrice = Area | Neighborhood / solution clparm;
run;

ods text="After removing large homes, the variability does not appear constant";
ods text="We will try log transforms of both SalePrice and Area and look at residuals";

title2 'log linear';
proc glm data=n3_no_large plot=all;
Class Neighborhood;
model logp = Area | Neighborhood / solution clparm;
run;

title2 'linear log';
proc glm data=n3_no_large plot=all;
Class Neighborhood;
model SalePrice = loga | Neighborhood / solution clparm;
run;

title2 'log log';
proc glm data=n3_no_large plot=all;
Class Neighborhood;
model logp = loga | Neighborhood / solution clparm;
run;

ods text="The log linear transform produces better looking residuals 
than the linear log transform.  The log log transform is similar, but 
The F-values for parameters are not as good, and it produces a larger 
confidence interval for the intercept.  In addition, it will be more 
difficult to interpret log-log transformed data.  Thus, we will go with 
a log of SalePrice vs Area.";

ods text="The next step is to look analyze residuals separately 
by Neighborhood, looking for outlisers";


/* analyze residuals by neighborhood */
title 'NAmes Outliers';
proc reg data=n3_no_large ;
model logp = Area / r vif clb influence;
where Neighborhood = 'NAmes';
output out=NAmes_r student=studresids cookd = cook h = leverage;
run;

ods text = "For NAmes, a threshold of 0.018 is appropriate 
for Cooks D.  A threshold of 0.04 would seem to isolate 
the points that stand out with high leverage";

title "Large studentized residuals for NAmes";
proc print data=NAmes_r;
where studresids > 2.5 or studresids < -2.5;
run;

title "Large Cooks D for NAmes";
proc print data=NAmes_r;
where cook > 0.018;
run;

title "Large Leverage for NAmes";
proc print data=NAmes_r;
where leverage > 0.04;
run;

ods text="in NAmes, observation id number 643 stands out with large studentized 
Residual, cooks d, and leverage.  It has an exceptionally large price and area. 
id number 659 stands out with large residual and distance.  It has an exceptionally
low price.";


title 'Edwards Outliers';
proc reg data=n3_no_large ;
model logp = Area / r vif clb influence;
where Neighborhood = 'Edwards';
output out=Edwards_r student=studresids cookd = cook h = leverage;
run;

ods text = "For Edwards, a threshold of 0.041 is appropriate 
for Cooks D.  A threshold of 0.04 would seem to isolate 
the points that stand out with high leverage";

title "Large studentized residuals for Edwards";
proc print data=Edwards_r;
where studresids > 2.5 or studresids < -2.5;
run;

title "Large Cooks D for Edwards";
proc print data=Edwards_r;
where cook > 0.041;
run;

title "Large Leverage for Edwards";
proc print data=Edwards_r;
where leverage > 0.04;
run;

ods text="in Edwards, observation id number 411 and 725 stand out with large studentized 
Residual, and cooks d.  Id 411 has a low price, and 725 has a relatively high price";

title 'BrkSide Outliers';
proc reg data=n3_no_large ;
model logp = Area / r vif clb influence;
where Neighborhood = 'BrkSide';
output out=BrkSide_r student=studresids cookd = cook h = leverage;
run;

ods text = "For BrkSide, a threshold of 0.069 is appropriate 
for Cooks D.  A threshold of 0.07 would seem to isolate 
the points that stand out with high leverage";


title "Large studentized residuals for BrkSide";
proc print data=BrkSide_r;
where studresids > 2.5 or studresids < -2.5;
run;

title "Large Cooks D for BrkSide";
proc print data=BrkSide_r;
where cook > 0.069;
run;

title "Large Leverage for BrkSide";
proc print data=BrkSide_r;
where leverage > 0.07;
run;

ods text = "In BrkSide, observation 251 has a high studentized residual. 
It stands out with a low price.  Observation 534 has high cooks d and 
leverage.  It has a very small area and sales price.";

ods text = "The observations that stand out with high studentized residual, 
cooks D, or leverage, appear to be atypical only in that they are either 
small properties with low sales price or large properties with high sales 
price.  They may in fact have valuable information that builds a better model.  
We will perform the analysis with and without them to see if there 
is a discernable difference.";

/* reject some probable outliers */
data n3_noout;
set n3_no_large;
if id = 543 then delete;
if id = 659 then delete;
if id = 411 then delete;
if id = 725 then delete;
if id = 251 then delete;
if id = 534 then delete;
run;

title 'Log Linear model, rejecting only very large properties';
proc sgpanel data=n3_no_large;
panelby Neighborhood / columns=3 rows=1;
scatter x=Area y=logp;
run;
proc glm data=n3_no_large plot=all;
Class Neighborhood;
model logp = Area | Neighborhood / solution clparm;
run;

ods text = "In order to perform cross validation, we do forward model selectionmodel selection.";
proc glmselect data=n3_no_large;
class Neighborhood;
model logp = Area | Neighborhood / selection=Forward(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq;
run;

title 'Log Linear model, rejecting very large properties and potential outliers';
proc sgpanel data=n3_noout;
panelby Neighborhood / columns=3 rows=1;
scatter x=Area y=logp;
run;
proc glm data=n3_noout plot=all;
Class Neighborhood;
model logp = Area | Neighborhood / solution clparm;
run;
proc glmselect data=n3_noout;
class Neighborhood;
model logp = Area | Neighborhood / selection=Forward(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq;
run;

ods text = "The model is not significantly different when the suspected outliers are withheld.  
Therefore, we will use the model that is created by dropping only the two vary large area 
properties.";

ods rtf close; 

