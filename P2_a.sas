data work.raw;
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

proc import out=work.original datafile='/home/u38097850/DS6371/Project/train_to_sas.csv' dbms=csv replace;
getnames=yes;
datarow=2;
run;

data work.cleaned;
set original;
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
if MiscFeature = ' ' then MisFeature   = 'None';
/* somehow handle 1stFlrSF, 2ndFlrSF, 3SsnPorch */
run;

proc sgpanel data=work.cleaned;
panelby Neighborhood / columns=5 rows=5;symbol c=blue v=dot;
scatter x=GrLivArea y=logp;
run;

/* numeric 
Id
GrLivArea     YearBuilt   YrSold  OverallQual OverallCond 

LotFrontage   LotArea     
YearRemodAdd  MasVnrArea  BsmtFinSF1  BsmtFinSF2 BsmtUnfSF  
BsmtUnfSf     TotalBsmtSF 1stFlrSF    2ndFlrSF  LowQualFinSF
TotRmsAbvGrd  GarageArea GarageYrBlt WoodDeckSF
OpenPorchSF   EnclosedPorch X3SsnPorch ScreenPorch PoolArea
MiscVal       MoSold            

SalePrice
*/

/* categorical
MSSubClass   Neighborhood  SaleType     SaleCondition  BedroomAbvGr

MSZoning     Street      LotShape     LandContour
Utilities    LotConfig   LandSlope    Condition1
Condition2   BldgType    HouseStyle  RoofStyle    RoofMatl
Exterior1st  Exterior2nd MasVnrType  ExterQual    ExterCond
Foundation   BsmtQual    BsmtCond    BsmtExposure BsmtFinType1
BsmtFinType2 Heating     HeatingQC   CentralAir   Electrical
BsmtFullBath BsmtHalfBath FullBath   HalfBath     
KitchenAbvGr KitchenQual Functional  Fireplaces   FireplaceQu
Garagetype   GarageYrBlt GarageFinish  GarageCars GarageQual
GarageCond   PavedDrive  PoolQC      Fence        MiscFeature
*/


proc glm data=work.cleaned;
Class 
MSSubClass MSZoning Street LotShape LandContour
Utilities    LotConfig   LandSlope   Neighborhood Condition1
Condition2   BldgType    HouseStyle  RoofStyle    RoofMatl
Exterior1st  Exterior2nd ExterQual ExterCond Foundation
Heating     HeatingQC   CentralAir  BsmtFullBath BsmtHalfBath
FullBath   HalfBath     BedroomAbvGr KitchenAbvGr KitchenQual 
Functional Fireplaces  GarageCars PavedDrive;
/* MasVnrType      ;
   BsmtQual    BsmtCond    BsmtExposure BsmtFinType1
BsmtFinType2 Electrical
   FireplaceQu
Garagetype   GarageYrBlt GarageFinish   GarageQual
GarageCond   PoolQC      Fence        MiscFeature
SaleType     SaleCondition
*/ 
model logp = GrLivArea 
MSSubClass MSZoning Street LotShape LandContour
Utilities    LotConfig   LandSlope   Neighborhood Condition1
Condition2   BldgType    HouseStyle  RoofStyle    RoofMatl
Exterior1st  Exterior2nd ExterQual ExterCond Foundation
Heating     HeatingQC   CentralAir  BsmtFullBath BsmtHalfBath
FullBath   HalfBath     BedroomAbvGr KitchenAbvGr KitchenQual 
Functional Fireplaces  GarageCars PavedDrive;
run;

proc glmselect data=work.cleaned;
Class 
MSSubClass   MSZoning    Street      LotShape     LandContour
Utilities    LotConfig   LandSlope   Neighborhood Condition1
Condition2   BldgType    HouseStyle  RoofStyle    RoofMatl
Exterior1st  Exterior2nd MasVnrType  ExterQual    ExterCond
Foundation   BsmtQual    BsmtCond    BsmtExposure BsmtFinType1
BsmtFinType2 Heating     HeatingQC   CentralAir   Electrical
BsmtFullBath BsmtHalfBath FullBath   HalfBath     BedroomAbvGr
KitchenAbvGr KitchenQual Functional  Fireplaces   FireplaceQu
Garagetype   GarageYrBlt GarageFinish  GarageCars GarageQual
GarageCond   PavedDrive  PoolQC      Fence        MiscFeature
SaleType     SaleCondition;
model logp = GrLivArea
  
YearBuilt     YrSold        OverallQual OverallCond LotFrontage
LotArea       YearRemodAdd  MasVnrArea  BsmtFinSF1  BsmtFinSF2 BsmtUnfSF  
BsmtUnfSf     TotalBsmtSF   LowQualFinSF
TotRmsAbvGrd  GarageArea    GarageYrBlt WoodDeckSF  OpenPorchSF
EnclosedPorch ScreenPorch PoolArea    MiscVal
MoSold    
        
MSSubClass   Neighborhood  SaleType     SaleCondition  BedroomAbvGr
MSZoning     Street      LotShape     LandContour
Utilities    LotConfig   LandSlope    Condition1
Condition2   BldgType    HouseStyle  RoofStyle    RoofMatl
Exterior1st  Exterior2nd MasVnrType  ExterQual    ExterCond
Foundation   BsmtQual    BsmtCond    BsmtExposure BsmtFinType1
BsmtFinType2 Heating     HeatingQC   CentralAir   Electrical
BsmtFullBath BsmtHalfBath FullBath   HalfBath     
KitchenAbvGr KitchenQual Functional  Fireplaces   FireplaceQu
Garagetype   GarageYrBlt GarageFinish  GarageCars GarageQual
GarageCond   PavedDrive  PoolQC      Fence        MiscFeature

YearBuilt * MSSubClass

/ selection=Stepwise(stop=CV) cvmethod=random(5) cvdetails=cvpress stats=adjrsq;

run;
