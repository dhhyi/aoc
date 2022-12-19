signals =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")

distinct = fn signal, num ->
  split = signal |> String.codepoints()

  Enum.find((num - 1)..(length(split) - 1), fn i ->
    sl = Enum.slice(split, (i - (num - 1))..i)
    sl == Enum.uniq(sl)
  end) + 1
end

signals
|> Enum.map(&distinct.(&1, 4))
|> Enum.at(0)
|> IO.inspect(label: "Part 1")

signals
|> Enum.map(&distinct.(&1, 14))
|> Enum.at(0)
|> IO.inspect(label: "Part 2")
