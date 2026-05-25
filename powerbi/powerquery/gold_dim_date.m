let
    Source = Sql.Database("MY_SERVER", "BrazilianEcommerceAnalytics"), //fake server name
    gold_dim_date = Source{[Schema="gold",Item="dim_date"]}[Data],

        AddedYearMonth = Table.AddColumn(
        gold_dim_date,
        "YearMonth",
        each Date.ToText([full_date], "yyyy-MM"),
        type text
    ),

    AddedYearMonthSort = Table.AddColumn(
        AddedYearMonth,
        "YearMonthSort",
        each [year_number] * 100 + [month_number],
        Int64.Type
    )

in
    AddedYearMonthSort