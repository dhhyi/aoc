trees =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn line -> String.codepoints(line) |> Enum.map(&String.to_integer/1) end)

# |> IO.inspect(label: "trees")

x_max = Enum.count(trees)
y_max = Enum.count(trees |> List.first())

level = fn [x, y] -> Enum.at(Enum.at(trees, y), x) end

defmodule Ranges do
  def expand([s..e, y]) when s >= 0 and e >= 0 do
    Enum.map(s..e, fn x -> [x, y] end)
  end

  def expand([x, s..e]) when s >= 0 and e >= 0 do
    Enum.map(s..e, fn y -> [x, y] end)
  end

  def expand(_) do
    []
  end
end

directions = fn [x, y] ->
  [
    [(x - 1)..0, y] |> Ranges.expand() |> Enum.map(&level.(&1)),
    [(x + 1)..(x_max - 1), y] |> Ranges.expand() |> Enum.map(&level.(&1)),
    [x, (y - 1)..0] |> Ranges.expand() |> Enum.map(&level.(&1)),
    [x, (y + 1)..(y_max - 1)] |> Ranges.expand() |> Enum.map(&level.(&1))
  ]
end

visible = fn [x, y] ->
  l = level.([x, y])
  Enum.any?(directions.([x, y]), fn d -> Enum.all?(d, &(&1 < l)) end)
end

scenicscore = fn [x, y] ->
  l = level.([x, y]) - 1

  Enum.map(directions.([x, y]), fn d ->
    dist = Enum.take_while(d, &(&1 <= l)) |> Enum.count()
    if dist != Enum.count(d), do: dist + 1, else: dist
  end)
  |> Enum.product()
end

(2 * x_max + 2 * y_max - 4 +
   (for(x <- 1..(x_max - 2), y <- 1..(y_max - 2), do: [x, y])
    |> Enum.filter(&visible.(&1))
    |> Enum.count()))
|> IO.inspect(label: "Part 1")

# scenicscore.([2, 1]) |> IO.inspect(label: "ss 2,1")
# scenicscore.([2, 3]) |> IO.inspect(label: "ss 2,3")

for(x <- 1..(x_max - 2), y <- 1..(y_max - 2), do: [x, y])
|> Enum.map(&scenicscore.(&1))
|> Enum.max()
|> IO.inspect(label: "Part 2")
