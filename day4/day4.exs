groups =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn line ->
    Enum.map(String.split(line, ","), fn x ->
      Enum.map(String.split(x, "-"), &String.to_integer/1) |> (fn [a, b] -> a..b end).()
    end)
  end)

Enum.count(groups, fn [first, last] ->
  Enum.all?(first, &(&1 in last)) || Enum.all?(last, &(&1 in first))
end)
|> IO.inspect(label: "Part 1")

Enum.count(groups, fn [first, last] ->
  Enum.any?(first, &(&1 in last)) || Enum.any?(last, &(&1 in first))
end)
|> IO.inspect(label: "Part 2")
