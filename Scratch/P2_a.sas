/* not in model itself 
  id
  SalePrice */

/* numeric (35)*/
%macro numeric_vars;
BedroomAbvGr
BsmtFinSF1
BsmtFinSF2
BsmtFullBath
BsmtHalfBath
BsmtUnfSF
EnclosedPorch
Fireplaces
FullBath
GarageArea
GarageCars
GarageYrBlt
GrLivArea
HalfBath
KitchenAbvGr
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

/* categorical (44) */
%macro categorical_vars;
Alley
BldgType
BsmtCond
BsmtExposure
BsmtFinType1
BsmtFinType2
BsmtQual
CentralAir
Condition1
Condition2
Electrical
ExterCond
Exterior1st
Exterior2nd
ExterQual
Fence
FireplaceQu
Foundation
Functional
GarageCond
GarageFinish
GarageQual
GarageType
Heating
HeatingQC
HouseStyle
KitchenQual
LandContour
LandSlope
LotConfig
LotShape
MasVnrType
MiscFeature
MSSubClass
MSZoning
Neighborhood
PavedDrive
PoolQC
RoofMatl
RoofStyle
SaleCondition
SaleType
Street
Utilities
%mend categorical_vars;

/* Here is where it really starts 
   simply read in the raw data, translating any 'NA' values into blanks 
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
if Alley       = ' ' then Alley        = 'None';
if KitchenQual = ' ' then KitchenQual  = 'TA';
if PavedDrive  = ' ' then PavedDrive   = 'Unk'; 
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
if Utilities   = ' ' then Utilities    = 'None';
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
if Alley       = ' ' then Alley        = 'None';
if KitchenQual = ' ' then KitchenQual  = 'TA';
if PavedDrive  = ' ' then PavedDrive   = 'Unk'; 
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
if Utilities   = ' ' then Utilities    = 'None';
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

/* put the training and test datasets together */
data union;
set clean_train clean_test;
/* Here is where I delete by observation number the points
   determined to be outliers 
   
   keep them all in for now...
   
if id = 1299 then delete;
if id = 524  then delete;

  */
run;


/* open up hard copy */
ods rtf file='/folders/myfolders/Project/Prob_2_results_10Aug19.rtf';

/*======================================================================== 
  start of proc to include everything
  ========================================================================
  first proc glm attempts to put all variables in.
  Call the result creosote, in honor of the character in 
  Monty Python's meaning of life, who tried to include
  everything
  */
proc glm data=work.union plots=all;
Class 
%categorical_vars
;
model logp = 
/* categorical */
%categorical_vars
/* numeric */
%numeric_vars
;
output out=creosote_result p=Predict;
run;

/* make a submission dataset, with only the id and Price.
   Keep prices in sensible range (over $10k)
   drop all other values, and keep only observations
   from the test dataset */
data creosote_sub;
set creosote_result;
if Predict  > log(10000) then SalePrice = exp(Predict);
if Predict <= log(10000) then SalePrice = 10000;
/*
if Predict  > 10000 then SalePrice = Predict;
if Predict <= 10000 then SalePrice = 10000;
*/
keep id SalePrice;
where id > 1460;
run;

/* sanity check - look at means of the submission */
proc means data = creosote_sub;
var SalePrice;
run;

/* Study the residuals, to look for outliers */
/* 
proc reg data=work.union;
model logp = 
GrLivArea      
OverallQual  
OverallCond  
GarageArea
/ r vif clb influence;
output out=union_r student=studresids cookd = cook h = leverage;
run;


title "Large studentized residuals";
proc print data=union_r;
var id cook studresids leverage;
where studresids > 7.5 or studresids < -7.5;
run;

title "Large Cooks D";
proc print data=union_r;
var id cook studresids leverage;
where cook > 0.1;
run;

title "Large Leverage";
proc print data=union_r;
var id cook studresids leverage;
where leverage > 0.4;
run;
*/

/*======================================================================== 
  start of modest model, selected by hand
  ========================================================================
  */
proc glm data=work.union plots=all;
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
output out=modest_result p=Predict;
run;

/* make a submission dataset, with only the id and Price.
   Keep prices in sensible range (over $10k)
   drop all other values, and keep only observations
   from the test dataset */
data modest_sub;
set modest_result;
if Predict  > log(10000) then SalePrice = exp(Predict);
if Predict <= log(10000) then SalePrice = 10000;
/*
if Predict  > 10000 then SalePrice = Predict;
if Predict <= 10000 then SalePrice = 10000;
*/
keep id SalePrice;
where id > 1460;
run;

proc means data = modest_sub;
var SalePrice;
run;

/*======================================================================== 
  start of proc for select forward
  ========================================================================*/
proc glmselect data=union;
Class 
%categorical_vars
;
model logp = 
/* categorical ( 35 variables ) */
%categorical_vars
/* numeric (27 variables) */
%numeric_vars
/ selection=Forward(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq;
output out=forward_result p=Predict;
run;

/* make a submission dataset, with only the id and Price.
   Keep prices in sensible range (over $10k)
   drop all other values, and keep only observations
   from the test dataset */
data forward_sub;
set forward_result;
if Predict  > log(10000) then SalePrice = exp(Predict);
if Predict <= log(10000) then SalePrice = 10000;
/*
if Predict  > 10000 then SalePrice = Predict;
if Predict <= 10000 then SalePrice = 10000;
*/
keep id SalePrice;
where id > 1460;
run;

/*======================================================================== 
  start of proc for select backward
  ========================================================================*/
proc glmselect data=union;
Class 
%categorical_vars
;
model logp = 
/* categorical ( 35 variables ) */
%categorical_vars
/* numeric (27 variables) */
%numeric_vars
/ selection=Backward(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq;
output out=backward_result p=Predict;
run;

/* make a submission dataset, with only the id and Price.
   Keep prices in sensible range (over $10k)
   drop all other values, and keep only observations
   from the test dataset */
data backward_sub;
set backward_result;
if Predict  > log(10000) then SalePrice = exp(Predict);
if Predict <= log(10000) then SalePrice = 10000;
/*
if Predict  > 10000 then SalePrice = Predict;
if Predict <= 10000 then SalePrice = 10000;
*/
keep id SalePrice;
where id > 1460;
run;

/*========================================================================  
  start of proc for select stepwise 
  ========================================================================*/ 
proc glmselect data=union; 
Class  
%categorical_vars 
; 
model logp =  
/* categorical ( 35 variables ) */ 
%categorical_vars 
/* numeric (27 variables) */ 
%numeric_vars 
/ selection=Stepwise(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq; 
output out=stepwise_result p=Predict; 
run; 
 
/* make a submission dataset, with only the id and Price. 
   Keep prices in sensible range (over $10k) 
   drop all other values, and keep only observations 
   from the test dataset */ 
data stepwise_sub; 
set stepwise_result; 
if Predict  > log(10000) then SalePrice = exp(Predict); 
if Predict <= log(10000) then SalePrice = 10000; 
/* 
if Predict  > 10000 then SalePrice = Predict; 
if Predict <= 10000 then SalePrice = 10000; 
*/ 
keep id SalePrice; 
where id > 1460; 
run; 


/* close hard copy */
ods rtf close;
