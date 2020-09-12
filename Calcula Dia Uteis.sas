%let ano = 2020;
data pascoa;
     length Descricao $ 50;
   a = mod(&ano, 19);
   b = floor(&ano / 100);
   c = mod(&ano, 100);
   d = floor(b / 4);
   e = mod(b, 4) ;
   f = floor( (b + 8) / 25 );
   g = floor((b - f + 1) / 3);
   h = mod(19*a + b - d - g + 15, 30);
   i = floor(c / 4);
   k = mod(c, 4);
   L = mod( (32 + 2*e + 2*i - h - k), 7);
   m = floor( (a + 11*h + 22*L) / 451);
   mes = floor( (h + L - 7*m + 114) / 31);
   dia =  mod(h + L - 7*m + 114, 31) + 1 ;
   Feriado1 = mdy(mes, dia, &ano);/*Pascoa*/
   Feriado2 = feriado1 - 48; /*Carnaval*/
   Feriado3 = feriado1 - 47; /*Carnaval*/
   Feriado4 = feriado1 - 2;     /*Paixão de Cristo*/
   Feriado5 = feriado1 - 60; /*Corpo de Cristo*/
   format Feriado1 Feriado2 Feriado3 Feriado4 Feriado5 ddmmyy10.;
run;

proc transpose data=pascoa out=pascoa_aux(rename=(_NAME_ = Feriado COL1 = dt));
     by Feriado1 Feriado2 Feriado3 Feriado4 Feriado5;
     var Feriado1 Feriado2 Feriado3 Feriado4 Feriado5;
run;

data pascoa_aux;
     length feriado_aux $ 50;
     set pascoa_aux;
     if feriado = "Feriado1" then feriado_aux = "Pascoa";
     if feriado = "Feriado2" then feriado_aux = "Carnaval";
     if feriado = "Feriado3" then feriado_aux = "Carnaval";
     if feriado = "Feriado4" then feriado_aux = "Paixão de Cristo";
     if feriado = "Feriado5" then feriado_aux = "Corpo de Cristo";


     if compress(put(dt,downame9.)) = "Monday" then NomeSemana = "Segunda-Feira";
     if compress(put(dt,downame9.)) = "Tuesday" then NomeSemana = "Terça-Feira";
     if compress(put(dt,downame9.)) = "Wednesday" then NomeSemana = "Quarta-Feira";
     if compress(put(dt,downame9.)) = "Thursday" then NomeSemana = "Quinta-Feira";
     if compress(put(dt,downame9.)) = "Friday" then NomeSemana = "Sexta-Feira";
     if compress(put(dt,downame9.)) = "Saturday" then NomeSemana = "Sábado";
     if compress(put(dt,downame9.)) = "Sunday" then NomeSemana = "Domingo";
     
     id = substr(put(dt,date9.),1,5);
     QtdeDiasAno = intck("day",mdy(01,01,&ano),mdy(12,31,&ano)) + 1;
     dta = substr(put(dt,ddmmyy10.),1,5);

     drop feriado;
     keep feriado_aux dt  NomeSemana id QtdeDiasAno dta 
     ;
     rename feriado_aux = feriado;
run;



data feriados;
infile datalines delimiter=",";
length dta $ 10 feriado $ 50;
input dta $ feriado $;
datalines;
01/01,Confraternização Universal
21/04,Tiradentes
01/05,Dia do Trabalho
07/09,Idependência do Brasil
12/10,Nossa Senhora Aparecida
02/11,Finados
15/11,Proclamação da Republica
25/12,Natal
;
run;


data feriados_aux;
     set feriados;
          dt = mdy(scan(dta,2,"/"),scan(dta,1,"/"),&ano);
          QtdeDiasAno = intck("day",mdy(01,01,&ano),mdy(12,31,&ano)) + 1;

          format dt date9.;
          id = substr(put(dt,date9.),1,5);
          if compress(put(dt,downame9.)) = "Monday" then NomeSemana = "Segunda-Feira";
          if compress(put(dt,downame9.)) = "Tuesday" then NomeSemana = "Terça-Feira";
          if compress(put(dt,downame9.)) = "Wednesday" then NomeSemana = "Quarta-Feira";
          if compress(put(dt,downame9.)) = "Thursday" then NomeSemana = "Quinta-Feira";
          if compress(put(dt,downame9.)) = "Friday" then NomeSemana = "Sexta-Feira";
          if compress(put(dt,downame9.)) = "Saturday" then NomeSemana = "Sábado";
          if compress(put(dt,downame9.)) = "Sunday" then NomeSemana = "Domingo";
run;

data baseDeFeriados;
     set feriados_aux pascoa_aux;
run;

data diasAnoTodos;
     do dt=intnx('day',mdy(01,01,&ano.),0) to intnx('day',mdy(12,31,&ano.),0);
          dt_aux = dt;
          output;
     end;
     format dt date9. dt_aux downame9.;
run;

data diasAnoTodos_aux;
     set diasAnoTodos;
          if compress(put(dt_aux,downame9.)) = "Monday" then NomeSemana = "Segunda-Feira";
          if compress(put(dt_aux,downame9.)) = "Tuesday" then NomeSemana = "Terça-Feira";
          if compress(put(dt_aux,downame9.)) = "Wednesday" then NomeSemana = "Quarta-Feira";
          if compress(put(dt_aux,downame9.)) = "Thursday" then NomeSemana = "Quinta-Feira";
          if compress(put(dt_aux,downame9.)) = "Friday" then NomeSemana = "Sexta-Feira";
          if compress(put(dt_aux,downame9.)) = "Saturday" then NomeSemana = "Sábado";
          if compress(put(dt_aux,downame9.)) = "Sunday" then NomeSemana = "Domingo";

          id = substr(put(dt,date9.),1,5);
run;

proc sql;
     create table diasAnoTodos_aux01 as
          select  a.dt format ddmmyy10.
				  ,a.NomeSemana
                  ,b.feriado as Feriado
                  ,case when weekday(a.dt) not in(7 1) and missing(b.feriado) then 1
                          else 0 end as DiaUtil
                ,case when weekday(a.dt) not in(1) then 1
                          else 0 end as DiaUtil2
                  ,case when calculated DiaUtil = 1 then "Considerar" 
                          else "Desconsiderar" end as FlagDiaUtil
                  ,put(a.dt,yymmn6.) as Anomes
          from diasAnoTodos_aux as a
          left join baseDeFeriados as b
          on a.id = b.id
          order by dt, anomes, FlagDiaUtil, DiaUtil;
quit;

proc sql;
	create table baseFeriadosFinal as 
		select a.dt as Data
			  ,a.NomeSemana
			  ,a.Feriado
			  ,a.FlagDiaUtil as DiaUtil
			  ,a.Anomes
			  ,b.QtdeDiaUtil
		from diasAnoTodos_aux01 as a
		left join (
			select anomes
				  ,sum(DiaUtil) as qtdeDiaUtil
			from diasAnoTodos_aux01 
			group by 1
		) as b
		on a.anomes = b.anomes
		order by data;
quit;
