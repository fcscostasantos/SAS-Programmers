%let caminho = C:\DadosCovid;

filename dir "&caminho";

data arquivos;
	fid = dopen("dir");
	if fid > 0 then do;
		contagem = dnum(fid);
		do i = 1 to contagem;
			nome_arquivo = dread(fid, i);
			output;
		end;
	end;
run;

proc sql;
	select nome_arquivo
		  ,scan(nome_arquivo,1,".") as nome_base
		  ,count(*) as qtde
	into :Arq1- :Arq&sysmaxlong,:nb1- :nb&sysmaxlong, :qtde
	from arquivos
	where nome_arquivo contains "dados_covid_20";
quit;

%macro importa;
	%do i =1 %to &qtde;

		proc import datafile="&caminho\&&Arq&i" out=&&nb&i dbms=csv replace;
		run;
/*		data &&nb&i;*/
/*		    infile "&caminho\&&Arq&i"*/
/*		        lrecl=90*/
/*		        encoding="wlatin1"*/
/*		        termstr=crlf*/
/*		        delimiter=","*/
/*		        missover*/
/*		        dsd ;*/
/*		    input*/
/*		        v    : ?? YYMMDD10.*/
/*		        Country_code     : $CHAR2.*/
/*		        Country          : $CHAR56.*/
/*		        WHO_region       : $CHAR5.*/
/*		        New_cases        : ?? BEST6.*/
/*		        Cumulative_cases : ?? BEST7.*/
/*		        New_deaths       : ?? BEST4.*/
/*		        Cumulative_deaths : ?? BEST6. ;*/
/*		run;*/
		proc append base=base_covid_acum data=&&nb&i force;run;
	%end;
%mend;
%importa;
