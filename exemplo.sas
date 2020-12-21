libname mylib  "C:\Users\patrick\OneDrive\Documentos\GitHub\sobrevivencia";
/*https://stats.idre.ucla.edu/sas/seminars/sas-survival/*/
proc format;
value gender
	  0 = "Male"
	  1 = "Female";
run;

data whas500;
set mylib.whas500;
format gender gender.;
run;


ods output ProductLimitEstimates = ple;
proc lifetest data=whas500(where=(fstat=1))  nelson outs=outwhas500;
time lenfol*fstat(0);
run;
proc sgplot data = ple;
series x = lenfol y = CumHaz;
run;
