/*--- Criando dois níveis de tratamento ---*/
/*--- Criando dois níveis de tratamento ---*/
libname rais     "\\sbsb2\DPTI\Bases\Rais\New";
libname bndes    "\\sbsb2\DPTI\Bases\BNDES\New";
libname exp      "\\sbsb2\dpti\Bases\Secex\New\Exportação";
libname imp      "\\sbsb2\dpti\Bases\Secex\New\Importação";
libname bacen    "\\sbsb2\dpti\Bases\BANCO CENTRAL\Bases";
libname patentes "\\sbsb2\DIEST\Microdados Estatistica\PATENTES";
libname salve	 "\\sbsb2\DPTI\Bases\BNDES\New\Análise";


%macro set;
%do ano=2002 %to 2015;
data rais&ano.(compress=yes); /*Criando Rais para cada ano com as seguintes variáveis*/
retain empresa cnae2 set_bndes;
length set_bndes $25.;
set rais.raisempresa&ano.(rename=contratos=pot keep= empresa contratos ren_media_me msal uf empr_anos 
                                 Experiencia_Me share cien eng pesq rot IDADE_Me Tempo_Estudo_Me 
                                 PO_TGrau cnae10 cnae20 where=(pot>=30) );

/*Fitro indústria*/
cnae2=substr(cnae20,1,2);
if "05"<=substr(cnae20,1,2)<="33";
     if "05"<= cnae2 <="09" then set_bndes="IND. EXTRATIVA";
else if "10"<= cnae2 <="33" then set_bndes="TRANSFORMAÇÃO";
else delete;

/* Variável regiao*/
regiao =substr(compress(uf),1,1);

/* Criação de algumas variáveis de proporção*/
prop_3g   = PO_Tgrau /pot; /* nº de funcionários com 3º grau por contrato*/
prop_eng  = eng      /pot; /* nº de engenheiros por contrato*/
prop_cien = cien     /pot; /* nº de cientistas por contrato*/
prop_pesq = pesq     /pot; /* nº de pesquisadores por contrato*/
potec     = sum(eng,cien,pesq,0); 

/* Criação de algumas variáveis log*/
lpot    = log(pot+1);
lage    = log(empr_anos+1);
lesc    = log(Tempo_Estudo_Me+1);
lmsal   = log(msal+1);
lpotec  = log(potec+1);

run;
%end;
%mend set;
%set;

data bndes(compress=yes); /* Uma variável contratacao para cada ano*/
merge bndes.Bndes2002(rename=CONTRATACAO=CONTRATACAO2002) bndes.Bndes2003(rename=CONTRATACAO=CONTRATACAO2003)
      bndes.Bndes2004(rename=CONTRATACAO=CONTRATACAO2004) bndes.Bndes2005(rename=CONTRATACAO=CONTRATACAO2005)
      bndes.Bndes2006(rename=CONTRATACAO=CONTRATACAO2006) bndes.Bndes2007(rename=CONTRATACAO=CONTRATACAO2007) 
      bndes.Bndes2008(rename=CONTRATACAO=CONTRATACAO2008) bndes.Bndes2009(rename=CONTRATACAO=CONTRATACAO2009)
      bndes.Bndes2010(rename=CONTRATACAO=CONTRATACAO2010) bndes.Bndes2011(rename=CONTRATACAO=CONTRATACAO2011)
      bndes.Bndes2012(rename=CONTRATACAO=CONTRATACAO2012) bndes.Bndes2013(rename=CONTRATACAO=CONTRATACAO2013)
	  bndes.Bndes2014(rename=CONTRATACAO=CONTRATACAO2014) bndes.Bndes2015(rename=CONTRATACAO=CONTRATACAO2015);
by empresa; /*por empresa*/
run;



%macro merge;
%do ano=2002 %to 2015;
data bndes_rais&ano.(compress=yes);
merge rais&ano.(in=a) bndes.bndes&ano. bndes;
if a;
by empresa;
if CONTRATACAO2002=. then BNDES2002=0;ELSE BNDES2002=1;
if CONTRATACAO2003=. then BNDES2003=0;ELSE BNDES2003=1;
if CONTRATACAO2004=. then BNDES2004=0;ELSE BNDES2004=1;
if CONTRATACAO2005=. then BNDES2005=0;ELSE BNDES2005=1;
if CONTRATACAO2006=. then BNDES2006=0;ELSE BNDES2006=1;
if CONTRATACAO2007=. then BNDES2007=0;ELSE BNDES2007=1;
if CONTRATACAO2008=. then BNDES2008=0;ELSE BNDES2008=1;
if CONTRATACAO2009=. then BNDES2009=0;ELSE BNDES2009=1;
if CONTRATACAO2010=. then BNDES2010=0;ELSE BNDES2010=1;
if CONTRATACAO2011=. then BNDES2011=0;ELSE BNDES2011=1;
if CONTRATACAO2012=. then BNDES2012=0;ELSE BNDES2012=1;
if CONTRATACAO2013=. then BNDES2013=0;ELSE BNDES2013=1;
if CONTRATACAO2014=. then BNDES2014=0;ELSE BNDES2014=1;
if CONTRATACAO2015=. then BNDES2015=0;ELSE BNDES2015=1;
ano=&ano.;
run;
%end;
%mend merge;
%merge;


/*identificação do instante inicial de financiamento do BNDES bndes=1 até o final*/
data painelx(compress=yes drop=CONTRATACAO2002-CONTRATACAO2015);
set bndes_rais2002 bndes_rais2003 bndes_rais2004 bndes_rais2005 bndes_rais2006
    bndes_rais2007 bndes_rais2008 bndes_rais2009 bndes_rais2010 bndes_rais2011
    bndes_rais2012 bndes_rais2013 bndes_rais2014 bndes_rais2015;
	     if ano=2002 and BNDES2002=1 then bndes=1;
	else if ano=2003 and BNDES2003=1 then bndes=1;
	else if ano=2004 and BNDES2003=1 then bndes=1;
	else if ano=2005 and BNDES2003=1 then bndes=1;
	else if ano=2006 and BNDES2003=1 then bndes=1;
	else if ano=2007 and BNDES2003=1 then bndes=1;
	else if ano=2008 and BNDES2003=1 then bndes=1;
	else if ano=2009 and BNDES2003=1 then bndes=1;
	else if ano=2010 and BNDES2003=1 then bndes=1;
	else if ano=2011 and BNDES2003=1 then bndes=1;
    else if ano=2012 and BNDES2003=1 then bndes=1;
	else bndes=0;
run;





%macro freqq;
%do ano=2004 %to 2013;
%let ano0  = %eval(&ano.+0);
%let ano_1 = %eval(&ano.-1);
%let ano_2 = %eval(&ano.-2);
%let ano1  = %eval(&ano.+1);
%let ano2  = %eval(&ano.+2);
data painelx; set painelx;
if ano=%eval(&ano0.) then do;
     if sum(bndes&ano_2.,bndes&ano_1.,bndes&ano0.,bndes&ano1.,bndes&ano2.)=0 then bndesx=0; /* controle fixo*/
else if sum(bndes&ano_2.,bndes&ano_1.)=0 and sum(bndes&ano0.,bndes&ano1.,bndes&ano2.)=3 then bndesx=1; /* Bndes contínuo a partir de t*/
else if sum(bndes&ano_2.,bndes&ano_1.,bndes&ano1.,bndes&ano2.)=0 and bndes&ano0.=1 then bndesx=2; /* Pulso puro*/
else if sum(bndes&ano_2.,bndes&ano_1.)=0 and bndes&ano0.=1 and bndes&ano1.=1 and bndes&ano2.=0 then bndesx=3; /* Pulso outros*/
else if sum(bndes&ano_2.,bndes&ano_1.)=0 and bndes&ano0.=1 and bndes&ano1.=0 and bndes&ano2.=1 then bndesx=3; /* Pulso outros*/
else bndesx=.; /* não se enquadra nas situações descritas acima */
end;

if sum(bndes2004,bndes2005,bndes2006,bndes2007,bndes2008,bndes2009,bndes2010,
	   bndes2011,bndes2012,bndes2013)=0 then bndesy=0;
if sum(bndes2004,bndes2005,bndes2006,bndes2007,bndes2008,bndes2009,bndes2010,
	   bndes2011,bndes2012,bndes2013)=10 then bndesy=1;
run;

%end;
%mend freqq;
%freqq;

proc freq data=painelx;
table bndesy*bndesx /nocum norow nocol nopercent out=yy;
by ano;
run;

proc freq data=painelx;
table bndesx / nocum out=xxx;
by ano;
run;

/* Adicionando as variáveis explicativas do modelo */
/*proc sort data=rais.raisempresa2001; by empresa; run;*/

%macro taxapo;
%do ano=2002 %to 2015;
%let ano_=%eval(&ano.-1);
data taxa_po&ano.(compress=yes keep=empresa taxa_rot lrot_t taxa_po lpo_t lpotec_t taxa_potec taxa_esc taxa_renda jc jd ec ed);
merge rais.raisempresa&ano. (in=a keep=empresa contratos Tempo_Estudo_Me REN_MEDIA_Me Rot eng pesq cien rename=(contratos=po&ano. Tempo_Estudo_Me=esc&ano. REN_MEDIA_Me=renda&ano. Rot=Rot&ano. eng=eng&ano. pesq=pesq&ano. cien=cien&ano. )) 
      rais.raisempresa&ano_.(in=b keep=empresa contratos Tempo_Estudo_Me REN_MEDIA_Me Rot eng pesq cien rename=(contratos=po&ano_ Tempo_Estudo_Me=esc&ano_ REN_MEDIA_Me=renda&ano_ Rot=Rot&ano_ eng=eng&ano_ pesq=pesq&ano_ cien=cien&ano_ ));
if a and b;
by empresa;
/*manter defasagem na base com um nome adequado*/
potec&ano.  = sum(eng&ano. ,pesq&ano. ,cien&ano. ,0);
potec&ano_. = sum(eng&ano_.,pesq&ano_.,cien&ano_.,0);

taxa_po    = log(sum(po&ano.   ,1)) - log(sum(po&ano_.    ,1));/**/
lpo_t  	   = log(sum(po&ano_.  ,1)); /* taxa defasada */
taxa_rot   = log(sum(Rot&ano.  ,1)) - log(sum(Rot&ano_.   ,1));/**/
lrot_t     = log(sum(Rot&ano_. ,1)); /* taxa defasada */
taxa_esc   = log(sum(esc&ano.  ,1)) - log(sum(esc&ano_.   ,1));
taxa_potec = log(sum(potec&ano.,1)) - log(sum(potec&ano_. ,1));
lpotec_t   = log(sum(potec&ano_. ,1)); 	
taxa_renda = log(sum(renda&ano.,1)) - log(sum(renda&ano_. ,1));

/* taxa de criação e destruição de empregos */
delta_pos = po&ano.-po&ano_. ;
delta_neg = abs(po&ano.-po&ano_. );

gamma_pos = esc&ano.-esc&ano_. ;
gamma_neg = abs(esc&ano.-esc&ano_. );

if delta_pos  >0 then indj_p=1;else indj_p=0;
if delta_pos <=0 then indj_n=1;else indj_n=0;

if gamma_pos  >0 then inde_p=1;else inde_p=0;
if gamma_pos <=0 then inde_n=1;else inde_n=0;

ej  = mean(po&ano.  , po&ano_.);
ee  = mean(esc&ano. , esc&ano_.);

jc = (delta_pos/ej)*indj_p;
jd = (delta_neg/ej)*indj_n;

ec = (gamma_pos/ee)*inde_p;
ed = (gamma_neg/ee)*inde_n;

if taxa_po  =. then taxa_po  =0; 
if taxa_po2 =. then taxa_po2 =0;
if jc       =. then jc       =0;
if jd       =. then jd       =0;
if ec       =. then ec       =0;
if ed       =. then ed       =0;
run;
%end;
%mend taxapo;
%taxapo;


/* Exportações e Importações */
%macro exp;
%do ano=2001 %to 2015;
proc sql;
create table exp&ano. as 
select empresa, 1 as dummyexp
from Exp.X&ano.
group by empresa
order by empresa;
%end;

%do ano=2001 %to 2015;
create table imp&ano. as 
select empresa, 1 as dummyimp
from Imp.M&ano.
group by empresa
order by empresa;
%end;
quit;
%mend exp;
%exp;


/* Estoques de patentes */
/*--- Está linha irá abrir a programação "patentes anuais" para criar o Estoque de Patentes (kpat) ---*/
%include "\\sbsb2\diest\Microdados Estatistica\BNDES\Análise\patentes anuais.sas";

/*merge BNDES com RAIS(Indústria)*/
%macro merge;
%do ano=2002 %to 2015;

%if ano le 2004 %then %do;
data bndes_rais&ano.(compress=yes);
merge 	painelx (where=(ano=&ano.) in=a)
		rais&ano.
		bndes.bndes&ano. 
		exp&ano. 
		imp&ano. 
		taxa_po&ano.(in=b)
		bacen.bc_2000
		kpat&ano.;
%end;

%if 2005 le ano le 2009 %then %do;
data bndes_rais&ano.(compress=yes);
merge 	painelx (where=(ano=&ano.) in=a)
		rais&ano.
		bndes.bndes&ano. 
		exp&ano. 
		imp&ano. 
		taxa_po&ano.(in=b)
		bacen.bc_2005
		kpat&ano.;
%end;

%if 2009 le ano le 2015 %then %do; 
data bndes_rais&ano.(compress=yes);
merge 	painelx(where=(ano=&ano.) in=a)
		rais&ano.
		bndes.bndes&ano. 
		exp&ano. 
		imp&ano. 
		taxa_po&ano.(in=b)
		bacen.bc_2010
		kpat&ano.;
%end;


by empresa;
if a and b;
if contratacao<0 then dummybndes=0;else dummybndes=1;
if dummyexp=. then dummyexp=0;
if dummyimp=. then dummyimp=0;
if bacen=. then bacen=0;
if bndes=. then bndes=0;
if kpat=. then kpat=0;
drop bndes2002-bndes2015;
run;
%end;
%mend merge;
%merge;

/*------------------------------------------------------------------------------*/
/*---            Inclusão da Classificação OCDE: ANALISE DESCRITIVA          ---*/
/*------------------------------------------------------------------------------*/
data salve.painel(compress=yes);
set bndes_rais2002 bndes_rais2003 bndes_rais2004 bndes_rais2005 bndes_rais2006 bndes_rais2007 bndes_rais2008 
    bndes_rais2009 bndes_rais2010 bndes_rais2011 bndes_rais2012 bndes_rais2013 bndes_rais2014 bndes_rais2015;
	if contratacao>0 then bndes=1;else bndes=0;
cnae20_3d=substr(cnae20,1,3);
run;

data salve.painel;
set salve.painel;
if ano<=2008 then tempo=0;
else tempo=1;
run;

/*tabela descritiva 6*/
proc sort data=salve.painel presorted ;by tempo;run;
proc means data=salve.painel mean sum maxdec=2 nway;
by tempo;
class bndesx;
var pot taxa_po lpo_t eng pesq cien potec taxa_potec lpotec_t PO_Tgrau ren_media_me taxa_renda
    empr_anos Tempo_Estudo_Me taxa_esc rot taxa_rot lrot_t jc jd ec ed dummyexp dummyimp 
    bacen kpat contratacao;
output out=saida_medias(rename=_freq_=nfirmas) mean=;
output out=saida_somas(rename=_freq_=nfirmas) sum=;
run;

proc export data=saida_medias outfile="\\sbsb2\DPTI\Bases\BNDES\New\Análise\Relatório\tab6_medias.xlsx" dbms=xlsx; run;
proc export data=saida_somas outfile="\\sbsb2\DPTI\Bases\BNDES\New\Análise\Relatório\tab6_somas.xlsx" dbms=xlsx; run;

proc sort data=salve.painel presorted ;by ano;run;
proc means data=salve.painel mean sum maxdec=2;
by ano;
class bndesx;
var ren_media_me contratacao;
output out=def_medias(rename=_freq_=nfirmas) mean=;
output out=def_somas(rename=_freq_=nfirmas) sum=;
run;
proc export data=def_medias outfile="\\sbsb2\DPTI\Bases\BNDES\New\Análise\Relatório\tab6_def_medias.xlsx" dbms=xlsx; run;
proc export data=def_somas outfile="\\sbsb2\DPTI\Bases\BNDES\New\Análise\Relatório\tab6_def_somas.xlsx" dbms=xlsx; run;

libname intec "\\sbsb2\DIEST\Microdados Estatistica\BNDES\Análise\intec";
proc format;
value ocdef 1="Baixa" 2="Média-Baixa" 3="Média-Alta" 4="Alta";
run;


proc sort data=salve.painel ;by cnae20_3d;run;
proc sort data=intec.clas_ocde_cepal_pavitt_cnae20 ;by cnae20_3d;run;
data salve.painel;
merge salve.painel(in=a) intec.Clas_ocde_cepal_pavitt_cnae20;
by cnae20_3d;
if a;
if estrato_ocde=. then estrato_ocde=0;

if estrato_ocde=1 then estrato_ocde1=1; else estrato_ocde1=0;
if estrato_ocde=2 then estrato_ocde2=1; else estrato_ocde2=0;
if estrato_ocde=3 then estrato_ocde3=1; else estrato_ocde3=0;
if estrato_ocde=4 then estrato_ocde4=1; else estrato_ocde4=0;
run;


proc freq data=salve.painel;
format estrato_ocde ocdef.;
table ano*estrato_ocde;
run;


/*---   Consulta de Frequencia Anual para cada nível BNDESx   ---*/
proc sql;
create table freq as 
select distinct ano,bndesx,count(empresa) as freq 
from salve.painel 
group by ano,bndesx order by ano,bndesx;
quit;

/*Tabela de Estatística Descritiva*/
proc transpose data=freq out=freq2 prefix=bndesx;
by ano;
id bndesx;
var freq;
run;


/* MODELO PROBIT MULTINOMIAL: Vai ficar ruim */
proc sort data=salve.painel presorted sortsize=max;by ano empresa bndesx;run;
/*ods html file="\\sbsb2\DIEST\Microdados Estatistica\BNDES\temp.xls";*/
proc logistic data=salve.painel(where=(2003 le ano le 2014)) outmodel=estim_antes;
class regiao estrato_ocde;
where bndesx ne . ;
by NOTSORTED ano ;
model bndesx(ref="0")=lpo_t lrot_t kpat lage lpotec_t share dummyexp dummyimp po_tgrau bacen regiao estrato_ocde
/ maxiter=80 link=glogit lackfit rsquare;
output out=outt(keep=empresa ano bndesx IP_0 IP_1 IP_2 IP_3) predprobs=(i);
run;
/*ods html close;*/



/*PLANILHA: Probabilidades ANTES do Boot*/
proc sort data=outt presorted sortsize=max;by ano bndesx;run;
proc means data=outt noprint;
by ano bndesx;
output out=tab11(drop=_type_ _freq_) mean(IP_0)=prob0  mean(IP_1)=prob1  mean(IP_2)=prob2  mean(IP_3)=prob3;
run;


/* CRIANDO AMOSTRA DO TAMANHO DA MENOR FREQUENCIA DO NÍVEL PARA CADA ANO */
 data strata;
input ano bndesx _nsize_;
datalines;
2004 1 113
2004 2 113
2004 3 113
2004 0 113
2005 1 188
2005 2 188
2005 3 188
2005 0 188
2006 1 182
2006 2 182
2006 3 182
2006 0 182
2007 1 253
2007 2 253
2007 3 253
2007 0 253
2008 1 352
2008 2 352
2008 3 352
2008 0 352
2009 1 502
2009 2 502
2009 3 502
2009 0 502
2010 1 600
2010 2 600
2010 3 600
2010 0 600
2011 1 378
2011 2 378
2011 3 378
2011 0 378
2012 1 334
2012 2 334
2012 3 334
2012 0 334
2013 1 132
2013 2 132
2013 3 132
2013 0 132
;
run;


proc sort data=strata sortsize=max presorted ;by bndesx ano;run;
proc sort data=salve.painel sortsize=max presorted ;by bndesx ano;run;
proc surveyselect data=salve.painel(where=(bndesx=0 or bndesx=1 or bndesx=2 or bndesx=3)) rep=1500
                                       out=salve.amo seed=1234 sampsize=strata METHOD=srs noprint;
strata bndesx ano;
run;

proc  sql;
select max(replicate) from salve.amo;
quit;


/*Consulta frequencia de anos*/
proc sql;
select distinct ano,count(ano) as contagem from amo group by ano;
quit;


/*MODELO PROBIT MULTINOMIAL depois da reamostragem*/
/*Descobrimos que precisamos sortear por 'ano replicate empresa bndesx' e declarar 'NOTSORTED' no proc logistic*/
proc sort data=salve.amo presorted sortsize=max;by ano replicate empresa bndesx;run;
/*ods select LackFitChiSq RSquare;
ods output LackFitChiSq=hosmer rsquare=rSquare(keep=ano Label1 cValue2);*/
proc logistic data=salve.amo outest=salve.estim;
where bndesx ne . ;
by NOTSORTED ano replicate ;
class regiao estrato_ocde;
model bndesx(ref="0")=lpo_t lrot_t kpat lage lpotec_t share dummyexp dummyimp po_tgrau bacen regiao estrato_ocde
/ maxiter=80 link=glogit lackfit rsquare;
output out=salve.outtamo(keep=empresa replicate ano bndesx IP_0 IP_1 IP_2 IP_3) predprobs=(i);
run;


proc sql;
select max(replicate) as max from salve.outtamo;
quit;


proc sort data=bndes.outtamo presorted sortsize=max;by empresa bndesx ano;
proc means data=bndes.outtamo noprint;
by empresa bndesx ano;
output out=bndes.bootamo(drop=_type_ rename=_freq_=nboot) mean(IP_0)=prob0 mean(IP_1)=prob1 mean(IP_2)=prob2 mean(IP_3)=prob3; 
run;

/*Patrick: Daqui pra frente*/
/*CONFERÊNCIA SIMPLES*/
proc sql;
select distinct ano,bndesx,count(ano) from bndes.bootamo group by ano,bndesx;
quit;


/*PLANILHA: PROBABILIDADES DEPOIS DO BOOT*/
data salve.bootamo;set bndes.bootamo(where=(bndesx ne .));
max=max(prob0, prob1, prob2, prob3);
if max=prob0 then bndesx_pred=0;
if max=prob1 then bndesx_pred=1;
if max=prob2 then bndesx_pred=2;
if max=prob3 then bndesx_pred=3;
run;
proc sort data=salve.bootamo sortsize=max presorted;by ano;run;
proc freq data=salve.bootamo ;tables bndesx*bndesx_pred / nocol nofreq nopercent; by ano; run;



/*--- Resumindo os parâmetros estimados para cada amostra através de médias e desvios ---*/
proc means data=salve.estim noprint;
by ano;
var Intercept_1 Intercept_2 Intercept_3 
    lpo_t_1 lpo_t_2 lpo_t_3
    lrot_t_1 lrot_t_2 lrot_t_3
    kpat_1 kpat_2 kpat_3
    lage_1 lage_2 lage_3
	lpotec_t_1 lpotec_t_2 lpotec_t_3
    dummyexp_1 dummyexp_2 dummyexp_3   
    dummyimp_1 dummyimp_2 dummyimp_3 
    PO_TGrau_1 PO_TGrau_2 PO_TGrau_3
    bacen_1 bacen_2 bacen_3 
    share_1 share_2 share_3 ;
output out=media(drop=_type_ rename=_freq_=nboot) mean()=; 
run;
proc means data=salve.estim noprint;
 var Intercept_1 Intercept_2 Intercept_3 
    lpo_t_1 lpo_t_2 lpo_t_3
    lrot_t_1 lrot_t_2 lrot_t_3
    kpat_1 kpat_2 kpat_3
    lage_1 lage_2 lage_3
	lpotec_t_1 lpotec_t_2 lpotec_t_3
    dummyexp_1 dummyexp_2 dummyexp_3   
    dummyimp_1 dummyimp_2 dummyimp_3 
    PO_TGrau_1 PO_TGrau_2 PO_TGrau_3
    bacen_1 bacen_2 bacen_3 
    share_1 share_2 share_3;
by ano;
output out=desvio(drop=_type_ _freq_) std()=; 
run;


proc transpose data=media  out=media (drop=_LABEL_) prefix=media  ;by ano;run;
proc transpose data=desvio out=desvio(drop=_LABEL_) prefix=desvio ;by ano;run;

proc sort data=media  ;by _NAME_ ano;run;
proc sort data=desvio ;by _NAME_ ano;run;
data media;merge media desvio;
by _NAME_ ano;
est=media1/desvio1;
pvalor =1-probnorm(abs(est));
run;


proc sql;
create table xrsqr as 
   select distinct ano, avg(input(cValue2,5.)) as rsqr
from rSquare group by ano;
quit;



/************* CRIANDO SUPORTE COMUM COM 25%, 75% ***************/
/* Máximo de P0 e mínimo de P1 P2 e P3 por ano*/
proc sort data=salve.bootamo;by ano bndesx ;run;
proc means data=salve.bootamo noprint;
by ano bndesx ;
output out=sup(drop=_freq_ _type_)
  p25(prob0)=probinf0 p75(prob0)=probsup0
  p25(prob1)=probinf1 p75(prob1)=probsup1
  p25(prob2)=probinf2 p75(prob2)=probsup2
  p25(prob3)=probinf3 p75(prob3)=probsup3;
run;


%macro transp(var);
proc sort data=sup sortsize=max presorted;by ano;run;
proc transpose data=sup out=&var. prefix=&var._;
by ano;
id bndesx;
var &var.;
run; 
%mend transp;
%transp(probinf0);
%transp(probinf1);
%transp(probinf2);
%transp(probinf3);
%transp(probsup0);
%transp(probsup1);
%transp(probsup2);
%transp(probsup3);

data sup2;
merge probinf0 probinf1 probinf2 probinf3 
      probsup0 probsup1 probsup2 probsup3;
by ano;
run;


data salve.bootamo2;merge salve.bootamo sup2;
by ano;
if (bndesx=1 and prob1>probsup1_0) and
   (bndesx=2 and prob2>probsup2_0) and
   (bndesx=3 and prob3>probsup3_0) then delete;

if (bndesx=0 and prob1<probinf1_1) or 
   (bndesx=0 and prob2<probinf2_2) or
   (bndesx=0 and prob3<probinf3_3) then delete;
run;



proc sql;
select distinct ano,bndesx,count(empresa)
from salve.bootamo2 
group by ano,bndesx 
order by ano,bndesx;
quit;


proc sort data=salve.bootamo2 sortsize=max presorted;by bndesx ano;run;

/* PROBABILIDADES PREDITAS*/
proc means data=salve.bootamo2;
by bndesx ano;
output out=tabIS(drop=_type_ _freq_)  mean(prob0)=prob0 mean(prob1)=prob1  
                                      mean(prob2)=prob2 mean(prob3)=prob3;
run;


/* APLICANDO SUPORTE COMUM */
proc sort data=salve.bootamo2; by empresa ano; run;
proc sort data=salve.painel; by empresa ano; run;

data salve.painel2;merge salve.painel salve.bootamo2 (in=a);
by empresa ano;
if a;
if bndesx=1  then bndesx1=1;else bndesx1=0;
if bndesx=2  then bndesx2=1;else bndesx2=0;
if bndesx=3  then bndesx3=1;else bndesx3=0;
if ano<=2008 then tempo=0;
else if ano>2008 then tempo=1;

/* CRIAÇÃO DOS PESOS ATE E ATT */

sucesso = 1 -prob0;
if bndesx=0 then peso = 1 /(1-sucesso);
if bndesx>0 then peso = 1 /sucesso;
if bndesx=0 then peso1 =sucesso/ (1 - sucesso);
if bndesx>0 then peso1 = 1;
run;


proc freq data=salve.painel2;
table ano*bndesx / out=freqIS nocol nopercent;
run;

/* CRIANDO VARIÁVEL BNDESXX PARA 2 NÍVEIS */
data salve.painel2; set salve.painel2;
if bndesx=0 then bndesxx=0;
if bndesx=1 then bndesxx=1;
if bndesx=2 then bndesxx=1;
if bndesx=3 then bndesxx=1;
/* criação de lrenda*/
lrenda=log(ren_media_me);
run;

/* REALIZANDO TESTE DE MÉDIAS ENTRE TRATADOS E NÃO TRATADOS */
proc sort data=salve.painel2; by ano; run;
proc ttest data=salve.painel2;
by ano;
var lpo_t lrot_t kpat lage lpotec share dummyexp dummyimp po_tgrau bacen;
weight peso;
class bndesxx ;
run;


/** RODAR REGRESSÃO COM E SEM PESO (ATE) E (ATT) COM E SEM VARIÁVEIS EXPLICATIVAS**/

/* ATE */
proc sort data=salve.painel2; by tempo; run;
/*lpot rot kpat lage share dummyexp dummyimp po_tgrau bacen*/
%macro reg(var);
ods output ParameterEstimates=betas&var.;
proc reg data=salve.painel2 outest=betasw_&var.;
by tempo;
model &var. = bndesx1 bndesx2 bndesx3 /*regiao2 *//*lpo_t*/ lrot_t lpotec_t kpat lage share dummyexp dummyimp po_tgrau bacen
             /*regiao3 regiao4 regiao5*/ estrato_ocde1 estrato_ocde2 estrato_ocde3;
weight peso; /* peso1 para efeito sobre tratados */
run;
%mend reg;
%reg(lpot); 
%reg(taxa_po); 
%reg(rot);  
%reg(taxa_rot); 
%reg(lesc);
%reg(taxa_esc);
%reg(lpotec);
%reg(taxa_potec);
%reg(lrenda);
%reg(taxa_renda);
%reg(jc); 
%reg(jd);
%reg(ec); 
%reg(ed);

/* estimativas */
%macro transpose(var);
proc sort data=Betas&var.;by Dependent;run;
proc transpose data=Betas&var. out=estim_&var.(drop=_LABEL_ _name_) prefix=estim_;
by Dependent;
where Variable ne "Intercept";
id tempo Variable;
var estimate;
run;
%mend transpose;
%transpose(lpot); 
%transpose(taxa_po); 
%transpose(rot);  
%transpose(taxa_rot); 
%transpose(lesc);
%transpose(taxa_esc);
%transpose(lpotec);
%transpose(taxa_potec);
%transpose(lrenda);
%transpose(taxa_renda);
%transpose(jc); 
%transpose(jd);
%transpose(ec); 
%transpose(ed);


data Estim_betas;
retain Dependent Estim_0bndesx1 Estim_0bndesx2 Estim_0bndesx3 Estim_1bndesx1 Estim_1bndesx2 Estim_1bndesx3 ;
set Estim_lpot Estim_taxa_po Estim_rot Estim_taxa_rot Estim_lesc 
    Estim_taxa_esc Estim_lpotec Estim_taxa_potec Estim_lrenda
    Estim_taxa_renda Estim_jc Estim_jd Estim_ec Estim_ed;
run;


/* Erro padrão */
%macro transpose(var);
proc sort data=Betas&var.;by Dependent;run;
proc transpose data=Betas&var. out=std_&var.(drop=_LABEL_ _name_) prefix=std_;
by Dependent;
where Variable ne "Intercept";
id tempo Variable;
var stderr;
run;
%mend transpose;
%transpose(lpot); 
%transpose(taxa_po); 
%transpose(rot);  
%transpose(taxa_rot); 
%transpose(lesc);
%transpose(taxa_esc);
%transpose(lpotec);
%transpose(taxa_potec);
%transpose(lrenda);
%transpose(taxa_renda);
%transpose(jc); 
%transpose(jd);
%transpose(ec); 
%transpose(ed);

data std_betas;
retain Dependent Std_0bndesx1 Std_0bndesx2 Std_0bndesx3 Std_1bndesx1 Std_1bndesx2 Std_1bndesx3 ;
set Std_lpot Std_taxa_po Std_rot Std_taxa_rot Std_lesc 
    Std_taxa_esc Std_lpotec Std_taxa_potec Std_lrenda
    Std_taxa_renda Std_jc Std_jd Std_ec Std_ed;
run;


/* P-valor */
%macro transpose(var);
proc sort data=Betas&var.;by Dependent;run;
proc transpose data=Betas&var. out=pvalor_&var.(drop=_LABEL_ _name_) prefix=pvalor_;
by Dependent;
where Variable ne "Intercept";
id tempo Variable;
var probt;
run;
%mend transpose;
%transpose(lpot); 
%transpose(taxa_po); 
%transpose(rot);  
%transpose(taxa_rot); 
%transpose(lesc);
%transpose(taxa_esc);
%transpose(lpotec);
%transpose(taxa_potec);
%transpose(lrenda);
%transpose(taxa_renda);
%transpose(jc); 
%transpose(jd);
%transpose(ec); 
%transpose(ed);

data pvalor_betas;
retain Dependent Pvalor_0bndesx1 Pvalor_0bndesx2 Pvalor_0bndesx3 Pvalor_1bndesx1 Pvalor_1bndesx2 Pvalor_1bndesx3 ;
set Pvalor_lpot Pvalor_taxa_po Pvalor_rot Pvalor_taxa_rot Pvalor_lesc 
    Pvalor_taxa_esc Pvalor_lpotec Pvalor_taxa_potec Pvalor_lrenda
    Pvalor_taxa_renda Pvalor_jc Pvalor_jd Pvalor_ec Pvalor_ed;
run;

/* organizando a tabela */
proc sort data=estim_betas; by dependent; run;
proc sort data=pvalor_betas; by dependent; run;
data tab_ate;
merge estim_betas pvalor_betas;
by dependent;
run;

/* macro sig*/
%macro sig;
%do i=0 %to 1;
%do j=1 %to 3;
data tab_ate;
set tab_ate;
if pvalor_&i.bndesx&j le 0.01 then _&i.sig&j = "***";
else if 0.01 lt pvalor_&i.bndesx&j le 0.05 then _&i.sig&j = "**";
else if 0.05 lt pvalor_&i.bndesx&j le 0.1 then _&i.sig&j = "*";
else _&i.sig&j = " ";
_&i.c&j=round(estim_&i.bndesx&j,0.001);
_&i.tab&j=compress(_&i.c&j||_&i.sig&j);
run;
%end;
%end;
%mend sig;
%sig;

data tab_ate;
set tab_ate;
keep dependent _0tab1 _0tab2 _0tab3 _1tab1 _1tab2 _1tab3;
run;

data std_ate;
set std_betas;
run;

/* ATT */
proc sort data=salve.painel2; by tempo; run;
/*lpot rot kpat lage share dummyexp dummyimp po_tgrau bacen*/
%macro reg(var);
ods output ParameterEstimates=betas&var.;
proc reg data=salve.painel2 outest=betasw_&var.;
by tempo;
model &var. = bndesx1 bndesx2 bndesx3 /*regiao2 *//*lpo_t*/ lrot_t lpotec_t kpat lage share dummyexp dummyimp po_tgrau bacen
             /*regiao3 regiao4 regiao5*/ estrato_ocde1 estrato_ocde2 estrato_ocde3;
weight peso1; /* peso1 para efeito sobre tratados */
run;
%mend reg;
%reg(lpot); 
%reg(taxa_po); 
%reg(rot);  
%reg(taxa_rot); 
%reg(lesc);
%reg(taxa_esc);
%reg(lpotec);
%reg(taxa_potec);
%reg(lrenda);
%reg(taxa_renda);
%reg(jc); 
%reg(jd);
%reg(ec); 
%reg(ed);


/* estimativas */
%macro transpose(var);
proc sort data=betas&var.;by Dependent;run;
proc transpose data=betas&var. out=estim_&var.(drop=_LABEL_ _name_) prefix=estim_;
by Dependent;
where Variable ne "Intercept";
id tempo Variable;
var estimate;
run;
%mend transpose;
%transpose(lpot); 
%transpose(taxa_po); 
%transpose(rot);  
%transpose(taxa_rot); 
%transpose(lesc);
%transpose(taxa_esc);
%transpose(lpotec);
%transpose(taxa_potec);
%transpose(lrenda);
%transpose(taxa_renda);
%transpose(jc); 
%transpose(jd);
%transpose(ec); 
%transpose(ed);


data Estim_betas;
retain Dependent Estim_0bndesx1 Estim_0bndesx2 Estim_0bndesx3 Estim_1bndesx1 Estim_1bndesx2 Estim_1bndesx3 ;
set Estim_lpot Estim_taxa_po Estim_rot Estim_taxa_rot Estim_lesc 
    Estim_taxa_esc Estim_lpotec Estim_taxa_potec Estim_lrenda
    Estim_taxa_renda Estim_jc Estim_jd Estim_ec Estim_ed;
run;


/* Erro padrão */
%macro transpose(var);
proc sort data=Betas&var.;by Dependent;run;
proc transpose data=Betas&var. out=std_&var.(drop=_LABEL_ _name_) prefix=std_;
by Dependent;
where Variable ne "Intercept";
id tempo Variable;
var stderr;
run;
%mend transpose;
%transpose(lpot); 
%transpose(taxa_po); 
%transpose(rot);  
%transpose(taxa_rot); 
%transpose(lesc);
%transpose(taxa_esc);
%transpose(lpotec);
%transpose(taxa_potec);
%transpose(lrenda);
%transpose(taxa_renda);
%transpose(jc); 
%transpose(jd);
%transpose(ec); 
%transpose(ed);

data std_betas;
retain Dependent Std_0bndesx1 Std_0bndesx2 Std_0bndesx3 Std_1bndesx1 Std_1bndesx2 Std_1bndesx3 ;
set Std_lpot Std_taxa_po Std_rot Std_taxa_rot Std_lesc 
    Std_taxa_esc Std_lpotec Std_taxa_potec Std_lrenda
    Std_taxa_renda Std_jc Std_jd Std_ec Std_ed;
run;


/* P-valor */
%macro transpose(var);
proc sort data=Betas&var.;by Dependent;run;
proc transpose data=Betas&var. out=pvalor_&var.(drop=_LABEL_ _name_) prefix=pvalor_;
by Dependent;
where Variable ne "Intercept";
id tempo Variable;
var probt;
run;
%mend transpose;
%transpose(lpot); 
%transpose(taxa_po); 
%transpose(rot);  
%transpose(taxa_rot); 
%transpose(lesc);
%transpose(taxa_esc);
%transpose(lpotec);
%transpose(taxa_potec);
%transpose(lrenda);
%transpose(taxa_renda);
%transpose(jc); 
%transpose(jd);
%transpose(ec); 
%transpose(ed);

data pvalor_betas;
retain Dependent Pvalor_0bndesx1 Pvalor_0bndesx2 Pvalor_0bndesx3 Pvalor_1bndesx1 Pvalor_1bndesx2 Pvalor_1bndesx3 ;
set Pvalor_lpot Pvalor_taxa_po Pvalor_rot Pvalor_taxa_rot Pvalor_lesc 
    Pvalor_taxa_esc Pvalor_lpotec Pvalor_taxa_potec Pvalor_lrenda
    Pvalor_taxa_renda Pvalor_jc Pvalor_jd Pvalor_ec Pvalor_ed;
run;

/* organizando a tabela */
proc sort data=estim_betas; by dependent; run;
proc sort data=pvalor_betas; by dependent; run;
data tab_att;
merge estim_betas pvalor_betas;
by dependent;
run;

/* macro sig*/
%macro sig;
%do i=0 %to 1;
%do j=1 %to 3;
data tab_att;
set tab_att;
if pvalor_&i.bndesx&j le 0.01 then _&i.sig&j = "***";
else if 0.01 lt pvalor_&i.bndesx&j le 0.05 then _&i.sig&j = "**";
else if 0.05 lt pvalor_&i.bndesx&j le 0.1 then _&i.sig&j = "*";
else _&i.sig&j = " ";
_&i.c&j=round(estim_&i.bndesx&j,0.001);
_&i.tab&j=compress(_&i.c&j||_&i.sig&j);
run;
%end;
%end;
%mend sig;
%sig;

data tab_att;
set tab_att;
keep dependent _0tab1 _0tab2 _0tab3 _1tab1 _1tab2 _1tab3;
run;

data std_att;
set std_betas;
run;






/* NOVA SEÇÃO: PAINEL  */
/* criando um dataset para cada tempo*/
data painel2_t0; set salve.painel2; if tempo=0; run;
data painel2_t1; set salve.painel2; if tempo=1;if lrenda=. then delete;  run; /* resolveu problemas com a renda que tinha um valor missing*/


%include "\\sbsb2\DPTI\Bases\BNDES\New\Análise\macro_tscsreg.sas";
/* fazer para variável de impacto (y) e variáveis explicativas (x), cross=id da observação, year= id do período de tempo*/
/* Modelo em Painel (macro Alan): analise de impacto */
/* Período 0: Até 2008*/
%tscsreg(tab=painel2_t0,y=lpot,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=taxa_po,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=rot,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=taxa_rot,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=lesc,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=taxa_esc,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=lpotec,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=taxa_potec,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=lrenda,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=taxa_renda,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=jc,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=jd,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=ec,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t0,y=ed,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);


/* Período 1: Após 2008*/
%tscsreg(tab=painel2_t1,y=lpot,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=taxa_po,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=rot,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=taxa_rot,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=lesc,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=taxa_esc,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=lpotec,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=taxa_potec,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=lrenda,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=taxa_renda,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=jc,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=jd,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=ec,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);
%tscsreg(tab=painel2_t1,y=ed,x=bndesx1 bndesx2 bndesx3 ,cross=empresa,year=ano);




/* Figura 1 e 2*/
data po30;
set salve.painel;
if bndes=1;
	 if pot<=29  then FAIXA_PO=1;
else if pot<=49  then FAIXA_PO=2;
else if pot<=99  then FAIXA_PO=3;
else if pot<=249 then FAIXA_PO=4;
else if pot<=499 then FAIXA_PO=5;
else if pot> 500 then FAIXA_PO=6;
run;

proc freq data=po30;
table FAIXA_PO;
run;

proc univariate data=salve.painel;
var pot;
run;

proc sql;
create table po1 as 
select distinct ano, faixa_po, count(empresa) as firmas, sum(contratacao) as contratacao
from po
group by  ano, faixa_po;
quit;

