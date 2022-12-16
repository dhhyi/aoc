lines =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")

calories =
  Enum.reduce(lines, [0], fn line, acc ->
    if line == "" do
      [0] ++ acc
    else
      [head | tail] = acc
      [head + String.to_integer(line) | tail]
    end
  end)
  |> Enum.sort()

IO.puts("Part 1: #{calories |> Enum.at(-1)}")

IO.puts("Part 2: #{calories |> Enum.take(-3) |> Enum.reduce(&+/2)}")
