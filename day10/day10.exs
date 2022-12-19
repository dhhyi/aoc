input =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")

cycles =
  input
  |> Enum.reduce([], fn line, acc ->
    level = (List.last(acc) || [1, 1]) |> Enum.at(0)

    if line == "noop" do
      acc ++ [[level, level]]
    else
      num = line |> String.split(" ") |> Enum.at(1) |> String.to_integer()
      acc ++ [[level, level], [level + num, level]]
    end
  end)

[20, 60, 100, 140, 180, 220]
|> Enum.map(fn f ->
  l = Enum.at(cycles, f - 1) |> Enum.at(1)
  l * f
end)
|> Enum.sum()
|> IO.inspect(label: "Part 1")

IO.puts("Part 2:")

cycles
|> Enum.with_index()
|> Enum.each(fn {[_, level], index} ->
  if abs(level - rem(index, 40)) <= 1 do
    IO.write("#")
  else
    IO.write(".")
  end

  if rem(index + 1, 40) == 0 do
    IO.puts("")
  end
end)
