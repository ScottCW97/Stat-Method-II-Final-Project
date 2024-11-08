* Importing data;
proc import out=cancer_data 
		datafile="/home/u63607157/Stat Method II/survey lung cancer.csv" dbms=csv 
		replace;
	getnames=YES;
run;

data cancer2;
	set cancer_data;

	if gender=1 then
		gen=0;

	if gender=2 then
		gen=1;

	if smoking=1 then
		smoke=0;

	if smoking=2 then
		smoke=1;

	if yellow_fingers=1 then
		fingers=0;

	if yellow_fingers=2 then
		fingers=1;

	if anxiety=1 then
		anx=0;

	if anxiety=2 then
		anx=1;

	if peer_pressure=1 then
		peer=0;

	if peer_pressure=2 then
		peer=1;

	if chronic_disease=1 then
		disease=0;

	if chronic_disease=2 then
		disease=1;

	if fatigue=1 then
		fatig=0;

	if fatigue=2 then
		fatig=1;

	if allergy=1 then
		aller=0;

	if allergy=2 then
		aller=1;

	if wheezing=1 then
		wheeze=0;

	if wheezing=2 then
		wheeze=1;

	if alcohol=1 then
		alc=0;

	if alcohol=2 then
		alc=1;

	if coughing=1 then
		cough=0;

	if coughing=2 then
		cough=1;

	if short_breath=1 then
		breath=0;

	if short_breath=2 then
		breath=1;

	if swallow=1 then
		swall=0;

	if swallow=2 then
		swall=1;

	if chest_pain=1 then
		chest=0;

	if chest_pain=2 then
		chest=1;

	
* Finding the best model with stepwise selection;
proc logistic data=cancer2 descending;
	model cancer=gen age smoke fingers anx 
		peer disease fatig aller wheeze alc cough breath swall 
		chest/selection=stepwise slentry=0.05 slstay=0.10;
run;

* Finding the best model with forward selection;
proc logistic data=cancer2 descending;
	model cancer=gen age smoke fingers anx 
		peer disease fatig aller wheeze alc cough breath swall 
		chest/selection=foward slentry=0.05;
run;

* Finding the best model with backward elimination;
proc logistic data=cancer2 descending;
	model cancer=gen age smoke fingers anx 
		peer disease fatig aller wheeze alc cough breath swall 
		chest/selection=backward slentry=0.10;
run;

* Finding the best model based on best subset;
proc logistic data=cancer2 descending;
	model cancer=gen age smoke fingers anx 
		peer disease fatig aller wheeze alc cough breath swall 
		chest/selection=score best=1;
run;


* Running tests on model found from the different selection methods;

* Hosmer-Lemeshow goodness of fit test;
proc logistic data=cancer2 descending plots(unpack label)=all;
	model cancer=smoke fingers peer disease fatig aller alc cough swall/lackfit;
	output out=diagnostic reschi=Pearson_residual resdev=deviance_residual p=pi h=hat;
run;

proc print data=diagnostic;
run;

* Pearson residual versus predicted probability;
proc sgplot data=diagnostic;
	scatter x=pi y=Pearson_residual;
run;

* Deviance residual versus predicted probability;
proc sgplot data=diagnostic;
	scatter x=pi y=deviance_residual;
run;

* Superimposing a lowess smoothing curve on the residual diagnostic plots;
proc loess data=diagnostic;
model Pearson_residual=pi;
run;

proc loess data=diagnostic;
model deviance_residual=pi;
run;


* Cutoff point;
data diagnostic2;
set diagnostic;
if pi < 0.5 then predicted=0;
else predicted=1;
if cancer=0 and predicted=0 then type1=1;
else type1=0;
if cancer=0 and predicted=1 then type2=1;
else type2=0;
if cancer=1 and predicted=0 then type3=1;
else type3=0;
if cancer=1 and predicted=1 then type4=1;
else type4=0;

proc sort data=diagnostic2;
by cancer predicted;
run;

proc print data=diagnostic2;
run;

* Showing the amount of true/false positives/negatives;
proc freq data=diagnostic2;
by cancer predicted;
tables type1 type2 type3 type4;
run;