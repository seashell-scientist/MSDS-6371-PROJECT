/* numeric 
Id
SalePrice
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
*/

/* categorical
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
Condition1 
Condition2    
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
LotConfig    
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
Utilities     
*/

data work.raw_train;
infile '/home/u38097850/DS6371/Project/train.csv' dsd truncover;
file '/home/u38097850/DS6371/Project/train_to_sas.csv' dsd;
length word $200;
do i=1 to 81;
input word @;
if word='NA' then word=' ';
put word @;
end;
put;
run;

data work.raw_test;
infile '/home/u38097850/DS6371/Project/test.csv' dsd truncover;
file '/home/u38097850/DS6371/Project/test_to_sas.csv' dsd;
length word $200;
do i=1 to 81;
input word @;
if word='NA' then word=' ';
put word @;
end;
put;
run;


proc import out=work.train datafile='/home/u38097850/DS6371/Project/train_to_sas.csv' dbms=csv replace;
getnames=yes;
datarow=2;
run;

proc import out=work.test datafile='/home/u38097850/DS6371/Project/test_to_sas.csv' dbms=csv replace;
getnames=yes;
datarow=2;
run;

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
/* for these three, replace missing values with means */
if LotFrontage = ' ' then LotFrontage  = 70;
if MasVnrArea  = ' ' then MasVnrArea   = 104;
if GarageYrBlt = ' ' then GarageYrBlt  = 1978;
run;

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
if LotFrontage = ' ' then LotFrontage  = 70;
if MasVnrArea  = ' ' then MasVnrArea   = 104;
if GarageYrBlt = ' ' then GarageYrBlt  = 1978;
run;

data union;
set clean_train clean_test;
run;

ods rtf file='/home/u38097850/DS6371/Project/Prob_2_results_06Aug19.rtf';

proc sgpanel data=work.union;
panelby Neighborhood / columns=5 rows=5;symbol c=blue v=dot;
scatter x=GrLivArea y=logp;
run;

proc glm data=work.union;
Class 
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
Condition1 
Condition2    
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
LotConfig    
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
Utilities     
;
model logp = 
/* categorical */
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
Condition1 
Condition2    
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
LotConfig    
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
Utilities     
/* numeric */
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
;
output out=creosote p=Predict;
run;

data creosote_sub;
set creosote;
if Predict  > 0 then SalePrice = exp(Predict);
if Predict <= 0 then SalePrice = 10000;
keep id SalePrice;
where id > 1460;
run;

proc means data = creosote_sub;
var SalePrice;
run;

proc glm data=work.union;
Class 
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
Condition1 
Condition2    
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
LotConfig    
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
Utilities     
;
model logp = 
/* categorical */
BldgType     
BsmtFullBath  
MSZoning      
Neighborhood   
RoofMatl 
/* numeric */
GrLivArea      
YearBuilt    
OverallQual  
OverallCond  
TotalBsmtSF  
GarageArea  
;
output out=modest p=Predict;
run;

data modest_sub;
set modest;
if Predict  > 0 then SalePrice = exp(Predict);
if Predict <= 0 then SalePrice = 10000;
keep id SalePrice;
where id > 1460;
run;

proc means data = modest_sub;
var SalePrice;
run;

proc glmselect data=union;
Class 
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
Condition1 
Condition2    
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
LotConfig    
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
Utilities     
;
model logp = GrLivArea
/* categorical */
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
Condition1 
Condition2    
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
LotConfig    
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
Utilities     
/* numeric */
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
/ selection=Stepwise(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq;
run;

ods rtf close;
