%let dir = C:\DadosCovid;

proc sql;
	select anomes
		  ,catt("dados_covid_",anomes) as nomeArq
		  ,count(*) as qtde
	into :an1- :an&sysmaxlong, :nArq1- :nArq&sysmaxlong, :qtde
	from(
		select distinct put(Date_reported,yymmn6.) as anomes  
		from WHO_COVID_19_GLOBAL_DATA
	);
quit;

%macro geraBases;
	%do i=1 %to &qtde;
		data &&narq&i;
			set WHO_COVID_19_GLOBAL_DATA;
			if put(Date_reported,yymmn6.) = "&&an&i";
		run;
		proc export data=&&narq&i outfile="&dir\&&narq&i...csv" dbms=csv replace;
	%end;
%mend;
%geraBases;


