
	use dbTicket

	--- ## Verifica a existencia da tabela de feriados, cria a tabela e a popula (substituivel por uma tabela auxiliar de feriados)
	if object_id('tempdb.dbo.#feriados_nacionais') is not null begin drop table #feriados_nacionais end
	if object_id('tempdb.dbo.#DataAtt') is not null begin drop table #DataAtt end

	create table #feriados_nacionais(
		 pkFn int not null identity(1,1)
		,NumeDiaMes int not null
		,NumeMes int not null
		,Dscr varchar(250)
	)

	insert into #feriados_nacionais values (1,1,'Confraternização Universal')
	insert into #feriados_nacionais values (21,4,'Tiradentes')
	insert into #feriados_nacionais values (1,5,'Dia do Trabalhador')
	insert into #feriados_nacionais values (7,9,'Dia da Pátria')
	insert into #feriados_nacionais values (12,10,'Nossa Senhora Aparecida')
	insert into #feriados_nacionais values (2,11,'Finados')
	insert into #feriados_nacionais values (15,11,'Proclamação da República')
	insert into #feriados_nacionais values (25,12,'Natal')
	-- ##

	-- ## Faz a seleção do dia útil correspondente para cada data dentro da dimensão de data
	select pkData
		  ,DataExte
		  ,case when FinaSemaFlag = 's' or fn.pkFn is not null -- ## Quando for um final de semana ou estiver dentro da tabela de feriados, dia útil = 0
					then 0
				else row_number() over (partition by NumeAnoMes,FinaSemaFlag,fn.pkFn order by pkData asc) -- ## Faz o row_number para as datas dos dias úteis
		   end as dia_util
	into #DataAtt
	from DataMart.dimData as dt
	left join #feriados_nacionais as fn 
			on dt.NumeDiaMes = fn.NumeDiaMes 
			and dt.NumeMes = fn.NumeMes
	-- ##


	-- ## Merge para atualizar o campo de dia util na dimensão de data
	merge into DataMart.dimData as dim
	using #DataAtt as att
		on dim.pkData = att.pkData
	when matched and dim.NumeDiaUtilMes <> att.dia_util 
		then
			update set dim.NumeDiaUtilMes = att.dia_util;
	-- ##