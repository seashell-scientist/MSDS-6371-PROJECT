/* convenient list of variables, alphebetized */

%macro numeric_vars;
BsmtFinSF1   
BsmtFinSF2  
BsmtUnfSf      
EnclosedPorch  
GarageArea  
GarageYrBlt  
GrLivArea      
LotArea      
LotFrontage    
LowQualFinSF 
MasVnrArea   
MiscVal        
MoSold       
OpenPorchSF    
OverallCond  
OverallQual  
PoolArea 
ScreenPorch  
TotalBsmtSF  
TotRmsAbvGrd   
WoodDeckSF 
x1stFlrSF     
x2ndFlrSF   
x3SsnPorch  
YearBuilt    
YearRemodAdd   
YrSold   
%mend numeric_vars;

%macro categorical_vars;
BedroomAbvGr 
BldgType     
BsmtCond       
BsmtExposure  
BsmtFinType1 
BsmtFinType2  
BsmtFullBath  
BsmtHalfBath  
BsmtQual     
CentralAir    
/* Condition1  */
/* Condition2  */
Electrical 
ExterCond 
Exterior1st   
Exterior2nd  
ExterQual     
Foundation    
Heating      
HeatingQC      
HouseStyle     
LandContour 
LandSlope      
/* LotConfig     */
LotShape       
MasVnrType     
MSSubClass    
MSZoning      
Neighborhood   
RoofMatl 
RoofStyle     
SaleCondition   
SaleType     
Street       
/* Utilities  */
%mend categorical_vars;

%macro submit(name=,);
data &name._sub;
set &name._result;
if Predict  > log(10000) then SalePrice = exp(Predict);
if Predict <= log(10000) then SalePrice = 10000;
keep id SalePrice;
where id > 1460;
run;
%mend  submit;

/* simply read in the raw data, translating any 'NA' values into blanks 
   result will be all character data */
data work.raw_train;
infile '/folders/myfolders/Project/train.csv' dsd truncover;
file '/folders/myfolders/Project/train_to_sas.csv' dsd;
length word $200;
do i=1 to 81;
input word @;
if word='NA' then word=' ';
put word @;
end;
put;
run;
data work.raw_test;
infile '/folders/myfolders/Project/test.csv' dsd truncover;
file '/folders/myfolders/Project/test_to_sas.csv' dsd;
length word $200;
do i=1 to 81;
input word @;
if word='NA' then word=' ';
put word @;
end;
put;
run;

/* now read the files from which 'NA' has been elided 
   here is where SAS can determine the types of the columns */
proc import out=work.train datafile='/folders/myfolders/Project/train_to_sas.csv' dbms=csv replace;
getnames=yes;
datarow=2;
run;
proc import out=work.test datafile='/folders/myfolders/Project/test_to_sas.csv' dbms=csv replace;
getnames=yes;
datarow=2;
run;

/* finally do the right thing with any blank input fields 
   in some cases, this means changing blanks to 'None' 
   in some cases, it means inserting a meaningful numeric value 
   here also, i take the log of sale price, since that 
   transform might prove useful */
data clean_train;
set work.train;
logp = log(SalePrice);
/* several variables that were 'NA' actually should be given meaningful values */
if GarageType  = ' ' then GarageType   = 'None';
if FireplaceQu = ' ' then FireplaceQu  = 'None';
if GarageType  = ' ' then GarageType   = 'None';
if GarageFinish= ' ' then GarageFinish = 'None';
if GarageQual  = ' ' then GarageQual   = 'None';
if GarageCond  = ' ' then GarageCond   = 'None';
if PoolQC      = ' ' then PoolQC       = 'None';
if Fence       = ' ' then Fence        = 'None';
if MiscFeature = ' ' then MiscFeature  = 'None';
if MasVnrType  = ' ' then MasVnrType   = 'None';
if BsmtQual    = ' ' then BsmtQual     = 'None';
if BsmtCond    = ' ' then BsmtCond     = 'None';
if BsmtExposure= ' ' then BsmtExposure = 'None';
if BsmtFinType1= ' ' then BsmtFinType1 = 'None';
if BsmtFinType2= ' ' then BsmtFinType2 = 'None';
if Electrical  = ' ' then Electrical   = 'None';
if FireplaceQu = ' ' then FireplaceQu  = 'None';
if Garagetype  = ' ' then Garagetype   = 'None';
if GarageFinish= ' ' then GarageFinish = 'None';
if GarageQual  = ' ' then GarageQual   = 'None';
if GarageCond  = ' ' then GarageCond   = 'None';
/* if Utilities   = ' ' then Utilities    = 'None'; */
if Functional  = ' ' then Functional   = 'Typ';
/* for these three, replace missing values with means */
if LotFrontage = ' ' then LotFrontage  = 70;
if MasVnrArea  = ' ' then MasVnrArea   = 104;
if GarageYrBlt = ' ' then GarageYrBlt  = 1978;
/* for these, replace with 0 */
if BsmtFinSF1  = ' ' then BsmtFinSF1   = 0;
if BsmtFinSF2  = ' ' then  BsmtFinSF2 = 0;
if BsmtFinSF   = ' ' then BsmtFinSF = 0;
if TotalBsmtSF = ' ' then TotalBsmtSF = 0;
if BsmtFullBath  = ' ' then BsmtFullBath = 0;
if BsmtHalfBath  = ' ' then BsmtHalfBath = 0;
if GarageCars   = ' ' then GarageCars = 0;
/* sane values */
if GarageCars   = 0 then GarageArea = 0;
if MSZoning    = ' ' then MSZoning = 'RL';
run;

/* for the test dataset, also make placeholders for the modeled 
   and its transform.  */
data clean_test;
set test;
SalePrice = .;
logp = .;
/* several variables that were 'NA' actually should be given meaningful values */
if GarageType  = ' ' then GarageType   = 'None';
if FireplaceQu = ' ' then FireplaceQu  = 'None';
if GarageType  = ' ' then GarageType   = 'None';
if GarageFinish= ' ' then GarageFinish = 'None';
if GarageQual  = ' ' then GarageQual   = 'None';
if GarageCond  = ' ' then GarageCond   = 'None';
if PoolQC      = ' ' then PoolQC       = 'None';
if Fence       = ' ' then Fence        = 'None';
if MiscFeature = ' ' then MiscFeature  = 'None';
if MasVnrType  = ' ' then MasVnrType   = 'None';
if BsmtQual    = ' ' then BsmtQual     = 'None';
if BsmtCond    = ' ' then BsmtCond     = 'None';
if BsmtExposure= ' ' then BsmtExposure = 'None';
if BsmtFinType1= ' ' then BsmtFinType1 = 'None';
if BsmtFinType2= ' ' then BsmtFinType2 = 'None';
if Electrical  = ' ' then Electrical   = 'None';
if FireplaceQu = ' ' then FireplaceQu  = 'None';
if Garagetype  = ' ' then Garagetype   = 'None';
if GarageFinish= ' ' then GarageFinish = 'None';
if GarageQual  = ' ' then GarageQual   = 'None';
if GarageCond  = ' ' then GarageCond   = 'None';
/* if Utilities   = ' ' then Utilities    = 'None'; */
if Functional  = ' ' then Functional   = 'Typ';
/* for these, replace with mean */
if LotFrontage = ' ' then LotFrontage  = 70;
if MasVnrArea  = ' ' then MasVnrArea   = 104;
if GarageYrBlt = ' ' then GarageYrBlt  = 1978;
/* for these, replace with 0 */
if BsmtFinSF1  = ' ' then BsmtFinSF1   = 0;
if BsmtFinSF2  = ' ' then  BsmtFinSF2 = 0;
if BsmtFinSF   = ' ' then BsmtFinSF = 0;
if TotalBsmtSF = ' ' then TotalBsmtSF = 0;
if BsmtFullBath  = ' ' then BsmtFullBath = 0;
if BsmtHalfBath  = ' ' then BsmtHalfBath = 0;
if GarageCars   = ' ' then GarageCars = 0;
/* sane values */
if GarageCars   = 0 then GarageArea = 0;
if MSZoning    = ' ' then MSZoning = 'RL';
run;

/* open up hard copy */
ods rtf file='/folders/myfolders/Project/Prob_2_results_10Aug19.rtf';

/*======================================================================== 
  start of residual analysis
  ========================================================================
  */
proc glm data=work.clean_train plots=all;
Class 
%categorical_vars
;
model logp = 
/* categorical */
%categorical_vars
/* numeric */
%numeric_vars
;
output out=train_result p=Predict cookd = cook h = leverage student = studre;
run;

title 'Large cooks d';
proc print data=work.train_result;
var id Neighborhood GrLivArea SalePrice cook leverage studre;
where cook > 0.1;
run;

title 'Large Leverage';
proc print data=work.train_result;
var id Neighborhood GrLivArea SalePrice cook leverage studre;
where leverage > 0.9;
run;

title 'Large studentized residuals';
proc print data=work.train_result;
var id Neighborhood GrLivArea SalePrice cook leverage studre;
where studre not between -7.5 and 7.5;
run;

/* put the training and test datasets together */
data union_all;
set clean_train clean_test;
run;

/* reject outliers */
data union_no_outliers;
set union_all;
/* this had an exceptionally high sales price */
if id = 826 then delete;
/* this is an exceptionally large home */
if id = 524 then delete;
run;

/*======================================================================== 
  start of custom model
  ========================================================================
  */
proc glm data=work.union_no_outliers plots=all;
Class 
MSZoning
Neighborhood
SaleCondition;
model logp = 
MSZoning
Neighborhood
SaleCondition
GarageArea  
GrLivArea      
LotArea      
LotFrontage    
OverallCond  
OverallQual  
TotalBsmtSF  
YearBuilt;
output out=custom_result p=Predict;
run;

%submit(name=Custom)

proc means data = custom_sub;
var SalePrice;
run;

/*========================================================================  
  start of forward
  ======================================================================== 
  */ 
proc glmselect data=union_no_outliers plot=(criterionpanel coefficients); 
Class  
%categorical_vars 
; 
model logp =
/* categorical */ 
%categorical_vars 
/* numeric */
%numeric_vars 
/ selection=Forward(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq; 
output out=forward_result p=Predict; 
run; 
 
%submit(name=forward) 
 
/*========================================================================   
  start of backward
  ========================================================================  
  */  
proc glmselect data=union_no_outliers plot=(criterionpanel coefficients);  
Class   
%categorical_vars  
;  
model logp = 
/* categorical */  
%categorical_vars  
/* numeric */ 
%numeric_vars  
/ selection=Backward(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq;  
output out=backward_result p=Predict;  
run;  
  
%submit(name=backward)  


/*======================================================================== 
  start of stepwise
  ========================================================================
  */
proc glmselect data=union_no_outliers plot=(criterionpanel coefficients);
Class 
%categorical_vars
;
model logp =
/* categorical */
%categorical_vars
/* numeric */
%numeric_vars
/ selection=Stepwise(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq;
output out=stepwise_result p=Predict;
run;

%submit(name=Stepwise)

/* close hard copy */
ods rtf close;
