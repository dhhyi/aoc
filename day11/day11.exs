regex =
  ~r/Monkey (?<monkey>\d+):\n  Starting items: (?<items>.*?)\n  Operation: new = old (?<operation>.) (?<argument>.*?)\n  Test: divisible by (?<test>\d+)\n    If true: throw to monkey (?<true>\d+)\n    If false: throw to monkey (?<false>\d+)/m

[items, inspectFunctions, testFunctions, dividers] =
  IO.read(:stdio, :all)
  |> String.split("\n\n")
  |> Enum.map(fn input ->
    parsed = Regex.named_captures(regex, input)

    operation =
      case parsed["operation"] do
        "+" ->
          fn item -> item + String.to_integer(parsed["argument"]) end

        "*" ->
          if parsed["argument"] == "old" do
            fn item -> item * item end
          else
            fn item -> item * String.to_integer(parsed["argument"]) end
          end
      end

    [
      String.split(parsed["items"], ", ") |> Enum.map(&String.to_integer/1),
      operation,
      fn item ->
        if rem(item, String.to_integer(parsed["test"])) == 0,
          do: String.to_integer(parsed["true"]),
          else: String.to_integer(parsed["false"])
      end,
      String.to_integer(parsed["test"])
    ]
  end)
  |> Enum.zip_with(& &1)

monkeys = Enum.count(items)

executeRound = fn [inspects, items], unworry ->
  1..monkeys
  |> Enum.reduce([inspects, items], fn monkey, [inspects, items] ->
    inspect = Enum.at(inspectFunctions, monkey - 1)
    test = Enum.at(testFunctions, monkey - 1)
    monkeyItems = Enum.at(items, monkey - 1)

    inspects =
      List.replace_at(
        inspects,
        monkey - 1,
        Enum.at(inspects, monkey - 1) + Enum.count(monkeyItems)
      )

    items =
      monkeyItems
      |> Enum.reduce(items, fn item, allItems ->
        newItem = inspect.(item) |> unworry.()
        to = test.(newItem)

        List.replace_at(allItems, to, [newItem | Enum.at(allItems, to)])
      end)
      |> List.replace_at(monkey - 1, [])

    [inspects, items]
  end)
end

monkeyBusiness = fn [inspects, _], print ->
  if print do
    Enum.with_index(inspects, &IO.puts("Monkey #{&2} inspected #{&1} items"))
  end

  Enum.sort(inspects) |> Enum.slice(-2..-1) |> Enum.product()
end

unworry1 = fn item -> trunc(item / 3) end

1..20
|> Enum.reduce([List.duplicate(0, monkeys), items], fn _, data ->
  executeRound.(data, unworry1)
end)
|> monkeyBusiness.(false)
|> IO.inspect(label: "Part 1")

unworry2 = fn item -> rem(item, Enum.product(dividers)) end

1..10000
|> Enum.reduce([List.duplicate(0, monkeys), items], fn _, data ->
  executeRound.(data, unworry2)
end)
|> monkeyBusiness.(false)
|> IO.inspect(label: "Part 2")
