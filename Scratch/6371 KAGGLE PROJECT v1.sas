proc import datafile ='/home/u38039150/train.csv'
out = train1 dbms=csv replace;
run;

proc import datafile ='/home/u38039150/test.csv'
out = test1 dbms=csv replace;
run;

proc import datafile ='/home/u38039150/test with blank saleprice column.csv'
out = test2 dbms=csv replace;
run;

proc reg data = work.train1; 
model SalePrice =  GrLivArea TotRmsAbvGrd  / selection = forward slentry = 0.1 adjrsq;
run;
/*basic model saleprice = beta1(area) + beta2(rooms above ground) + b, with entry pvalue = 0.1 */

proc reg data = work.train1; 
model SalePrice =  GrLivArea TotRmsAbvGrd  / selection = backward slstay = 0.1 adjrsq;
run;

proc reg data = work.train1; 
model SalePrice =  GrLivArea TotRmsAbvGrd  / selection = stepwise slentry = 0.1 slstay = 0.1 adjrsq;
run;
 /* all of these get r^2 about 0.5 but this is just an example we'll adjust more values later*/

/* all this doesn't work, need to figure out how to feed the model the test data */
proc reg data = work.train1;
model SalePrice = GrLivArea TotRmsAbvGrd; 
Output out=want p = SalePricepredicted LCL=SalePricelowerin LCLM=SalePricelowermean UCLSalePrice UCLM=SalePriceuppermean;
run;

proc logistic data = work.train1;
model SalePrice = GrLivArea TotRmsAbvGrd;
score data = work.test1 out = mypreds1;
run;
/* ok this one gets me... something
can't use with test data, b/c there's no saleprice field
even if make one, it is invalid data?? */