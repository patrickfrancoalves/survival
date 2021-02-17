libname rais     "\\sbsb2\DPTI\Bases\Rais\New";
libname denegri  "\\sbsb2\DPTI\Usuarios\Patrick Alves\Denegri";

/*Setores Serviços na página 11:http://biblioteca.ibge.gov.br/visualizacao/periodicos/150/pas_2014_v16.pdf*/


/*Consulta para o BACEN*/
%macro consul;
%do ano=2002 %to 2015;

proc sql;
create table certo&ano. as 
select distinct(empresa) as empresa,contratos,eng,pesq,cien,empr_anos,rot,REN_MEDIA_Me,Tempo_Estudo_Me,msal,CNAE20
from rais.RAISEMPRESA&ano.
where  (substr(CNAE20,1,2) in ("05","06","07","08","09"))  or /*Indústria Extrativa*/
       (substr(CNAE20,1,1) in ("1","2","3"))  or /*Indústria Transformação*/
       (substr(CNAE20,1,2) in ("37","39","50","52","53","55","56","58","59",/*Serviços*/
                               "60","61","62","63","66","68","71","73","74",
                               "77","78","79","80","82","90","92","93","95","96") or
	    substr(CNAE20,1,3) in ("016","023","381","382","383","452","491","492","493",
                               "494","495","511","512","692","702","812","813","855","859") or
	    substr(CNAE20,1,4) in ("4543","6911","8111")) or
	   (substr(CNAE20,1,4) in ("4511","4512","4530","4541","4542") or /*Comércio*/
        substr(CNAE20,1,2) in ("46","47")) or
	   (substr(CNAE20,1,2) in ("41","42","43"))  /*Construção*/
group by empresa order by empresa;
quit;


proc sql;
select count(distinct(empresa)) as nemp&ano. from certo&ano.;
quit;
%end;
%mend consul;
%consul;


/*Criando Variáveis de Setor e Ano*/
%macro consul;
%do ano=2002 %to 2015;
data certo&ano.;set certo&ano.;

     if substr(CNAE20,1,1) in ("1","2","3")                                  then Setor="Indústria de Transformação";
else if substr(CNAE20,1,2) in ("05","06","07","08","09")                     then Setor="Indústria Extrativa";
else if substr(CNAE20,1,2) in ("37","39","50","52","53","55","56","58","59","60","61","62","63","66",
                               "68","71","73","74","77","78","79","80","82","90","92","93","95","96") or
	    substr(CNAE20,1,3) in ("016","023","381","382","383","452","491","492","493",
                               "494","495","511","512","692","702","812","813","855","859") or 
        substr(CNAE20,1,4) in ("4543","6911","8111")                        then Setor="Setor de Serviços";
else if substr(CNAE20,1,4) in ("4511","4512","4530","4541","4542") or 
        substr(CNAE20,1,2) in ("46","47")                                   then Setor="Comércio";
else if substr(CNAE20,1,2) in ("41","42","43")                              then Setor="Indústria da Construção";
ano=&ano.;
run;

%end;
%mend consul;
%consul;



%macro corta;
%do ano=2002 %to 2015;
data denegri.certo&ano.;set certo&ano.;
if  (Setor="Indústria de Transformação" and contratos<30) then delete;
if  (Setor="Indústria Extrativa"        and contratos<30) then delete;
if  (Setor="Setor de Serviços"          and contratos<20) then delete;
if  (Setor="Comércio"                   and contratos<20) then delete;
if  (Setor="Indústria da Construção"    and contratos<20) then delete;
run;
%end;
%mend corta;
%corta;


%macro freq;
%do ano=2002 %to 2015;
proc freq data=denegri.certo&ano.;
title &ano.;
table Setor / nocum ;
run;
%end;
%mend freq;
%freq;




/*Exportando para EXCEL e STATA*/
%macro stata;
%do ano=2002 %to 2015;
proc export data=denegri.certo&ano. outfile="\\sbsb2\DPTI\Usuarios\Patrick Alves\Denegri\certo&ano..dta" dbms=STATA replace;
run;
proc export data=denegri.certo&ano.(drop=Setor) outfile="\\sbsb2\DPTI\Usuarios\Patrick Alves\DenegriCNPJ.xlsx "
        dbms=xlsx replace;
        sheet="cnpjs&ano.";
run;
%end;
%mend stata;%stata;


data painel;
set   denegri.certo2002 denegri.certo2003 denegri.certo2004 denegri.certo2005 denegri.certo2006 
      denegri.certo2007 denegri.certo2008 denegri.certo2009 denegri.certo2010 denegri.certo2011 
      denegri.certo2012 denegri.certo2013 denegri.certo2014 denegri.certo2015;
potec=sum(eng,pesq,cien);
run;


proc sql;
select count(distinct(empresa)) as nemp,ano from painel group by ano order by ano;
quit;


/*------------------------*/
proc means data=painel;
class ano Setor;
output out=saida(drop=_type_ rename=_freq_=nfirmas) sum(contratos)=contratos sum(eng)=eng sum(potec)=potec
       sum(msal)=msal mean(rot)=rot mean(REN_MEDIA_Me)=REN_MEDIA_Me mean(Tempo_Estudo_Me)=Tempo_Estudo_Me  ;
run;



