
	-- ## Function que filtra valor de input baseado em uma expressão regular

	create function NumberExtract(
		@expression_to_be_searched AS varchar(max),
		@regex_search_expression AS varchar(max),
		@replacement_expression AS varchar(max)
	) returns varchar(max)

	as

	begin
		while patindex('%' + @regex_search_expression + '%', @expression_to_be_searched) <> 0
		begin
			set @expression_to_be_searched = stuff(@expression_to_be_searched, patindex('%' + @regex_search_expression + '%', @expression_to_be_searched), 1, @replacement_expression)
		end
		set @expression_to_be_searched = case when @expression_to_be_searched = '' then null else @expression_to_be_searched end
		return @expression_to_be_searched
	end