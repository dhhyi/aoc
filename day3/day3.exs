backpacks =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")

prio = fn char ->
  code = char |> String.to_charlist() |> hd

  if code >= 97 do
    code - 96
  else
    code - 65 + 27
  end
end

part1 =
  backpacks
  |> Enum.map(fn bp ->
    l = String.length(bp)

    [
      String.slice(bp, 0, (l / 2) |> trunc),
      String.slice(bp, (l / 2) |> trunc, l)
    ]
  end)
  |> Enum.map(fn backpack ->
    other = Enum.at(backpack, 1)
    items = Enum.at(backpack, 0) |> String.split("", trim: true)

    Enum.find(items, fn item ->
      String.contains?(other, item)
    end)
    |> prio.()
  end)
  |> Enum.sum()

IO.puts("Part 1: #{part1}")

part2 =
  backpacks
  |> Enum.chunk_every(3)
  |> Enum.map(fn group ->
    other1 = Enum.at(group, 1)
    other2 = Enum.at(group, 2)
    items = Enum.at(group, 0) |> String.split("", trim: true)

    Enum.find(items, fn item ->
      String.contains?(other1, item) && String.contains?(other2, item)
    end)
    |> prio.()
  end)
  |> Enum.sum()

IO.puts("Part 2: #{part2}")
