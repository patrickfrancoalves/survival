libname rais "\\sbsb3\Usuarios\DPTI\Bases\RAIS\Bases\RAIS_Brasil";


proc sql;
create table rais98 as select distinct(substr(CODEMUN98,1,2)) as uf,sum(eng) as eng98,sum(pesq) as pesq98,sum(cien) as cien98
from rais.Raisempresa98 where ("1"<=substr(clas_cnae,1,2)<="3" and contratos>=10) group by substr(CODEMUN98,1,2) order by uf ;

create table rais99 as select distinct(substr(CODEMUN99,1,2)) as uf,sum(eng) as eng99,sum(pesq) as pesq99,sum(cien) as cien99
from rais.Raisempresa99 where ("1"<=substr(clas_cnae,1,2)<="3" and contratos>=10) group by substr(CODEMUN99,1,2) order by uf ;

create table rais00 as select distinct(substr(CODEMUN00,1,2)) as uf,sum(eng) as eng00,sum(pesq) as pesq00,sum(cien) as cien00
from rais.Raisempresa00 where ("1"<=substr(clas_cnae,1,2)<="3" and contratos>=10) group by substr(CODEMUN00,1,2) order by uf ;

create table rais01 as select distinct(substr(CODEMUN01,1,2)) as uf,sum(eng) as eng01,sum(pesq) as pesq01,sum(cien) as cien01
from rais.Raisempresa01 where ("1"<=substr(clas_cnae,1,2)<="3" and contratos>=10) group by substr(CODEMUN01,1,2) order by uf ;

create table rais02 as select distinct(substr(CODEMUN02,1,2)) as uf,sum(eng) as eng02,sum(pesq) as pesq02,sum(cien) as cien02
from rais.Raisempresa02 where ("1"<=substr(clas_cnae,1,2)<="3" and contratos>=10) group by substr(CODEMUN02,1,2) order by uf;

create table rais03 as select distinct(substr(CODEMUN03,1,2)) as uf,sum(eng) as eng03,sum(pesq) as pesq03,sum(cien) as cien03
from rais.Raisempresa03 where ("1"<=substr(clas_cnae,1,2)<="3" and contratos>=10) group by substr(CODEMUN03,1,2) order by uf ;

create table rais04 as select distinct(substr(CODEMUN04,1,2)) as uf,sum(eng) as eng04,sum(pesq) as pesq04,sum(cien) as cien04
from rais.Raisempresa04 where ("1"<=substr(clas_cnae,1,2)<="3" and contratos>=10) group by substr(CODEMUN04,1,2) order by uf ;

create table rais05 as select distinct(substr(CODEMUN05,1,2)) as uf,sum(eng) as eng05,sum(pesq) as pesq05,sum(cien) as cien05
from rais.Raisempresa05 where ("1"<=substr(clas_cnae,1,2)<="3" and contratos>=10) group by substr(CODEMUN05,1,2) order by uf ;

create table rais06 as select distinct(substr(CODEMUN06,1,2)) as uf,sum(eng) as eng06,sum(pesq) as pesq06,sum(cien) as cien06
from rais.Raisempresa06 where ("05"<=substr(clas_cnae,1,2)<="33" and contratos>=10) group by substr(CODEMUN06,1,2) order by uf;

create table rais07 as select distinct(substr(CODEMUN,1,2)) as uf,sum(eng) as eng07,sum(pesq) as pesq07,sum(cien) as cien07
from rais.Raisempresa07 where ("05"<=substr(clas_cnae,1,2)<="33" and contratos>=10) group by substr(CODEMUN,1,2) order by uf;
quit;


data po_tec;
retain uf eng98 eng99 eng00 eng01 eng02 eng03 eng04 eng05 eng06 eng07 pesq98 pesq99 pesq00 pesq01 pesq02 pesq03 pesq04 pesq05 pesq06 pesq07;
merge rais98 rais99 rais00 rais01 rais02 rais03 rais04 rais05 rais06 rais07;
by uf;
potec98=sum(eng98,pesq98,cien98);
potec99=sum(eng99,pesq99,cien99);
potec00=sum(eng00,pesq00,cien00);
potec01=sum(eng01,pesq01,cien01);
potec02=sum(eng02,pesq02,cien02);
potec03=sum(eng03,pesq03,cien03);
potec04=sum(eng04,pesq04,cien04);
potec05=sum(eng05,pesq05,cien05);
potec06=sum(eng06,pesq06,cien06);
potec07=sum(eng07,pesq07,cien07);
run;

proc EXPORT DATA=po_tec(keep=uf potec98 potec99 potec00 potec01 potec02 potec03 potec04 potec05 potec06 potec07) 
OUTFILE="C:\Patrick\PROJETOS IPEA\Luiz Ricardo (IPEA)\po_tec_uf.xls" DBMS=EXCEL REPLACE;
SHEET="po_tec"; 
run;
proc EXPORT DATA=po_tec(drop=potec98 potec99 potec00 potec01 potec02 potec03 potec04 potec05 potec06 potec07) 
OUTFILE="C:\Patrick\PROJETOS IPEA\Luiz Ricardo (IPEA)\po_tec_uf.xls" DBMS=EXCEL REPLACE;
SHEET="eng_cien_pesq"; 
run;


