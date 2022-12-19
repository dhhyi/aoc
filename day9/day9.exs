directions =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")
  |> Enum.flat_map(fn line ->
    [direction, num] = String.split(line, " ")
    for(_ <- 1..String.to_integer(num), do: direction)
  end)

head =
  Enum.reduce(directions, [[0, 0]], fn direction, acc ->
    [x, y] = List.last(acc)

    case direction do
      "U" -> acc ++ [[x, y + 1]]
      "D" -> acc ++ [[x, y - 1]]
      "R" -> acc ++ [[x + 1, y]]
      "L" -> acc ++ [[x - 1, y]]
    end
  end)

dir = fn x -> (x / abs(x)) |> trunc end

nextHead = fn [hx, hy], [tx, ty] ->
  dx = hx - tx
  dy = hy - ty

  cond do
    abs(dx) <= 1 and abs(dy) <= 1 -> [tx, ty]
    dx == 0 and abs(dy) == 2 -> [tx, ty + dir.(dy)]
    abs(dx) == 2 and dy == 0 -> [tx + dir.(dx), ty]
    abs(dx) == 1 and abs(dy) == 2 -> [tx + dx, ty + dir.(dy)]
    abs(dx) == 2 and abs(dy) == 1 -> [tx + dir.(dx), ty + dy]
    abs(dx) == 2 and abs(dy) == 2 -> [tx + dir.(dx), ty + dir.(dy)]
    true -> throw("#{hx},#{hy} -> #{tx},#{ty}")
  end
end

tails =
  Enum.reduce(1..9, [head], fn _, acc ->
    acc ++
      [
        Enum.reduce(List.last(acc), [[0, 0]], fn head, a ->
          last = List.last(a)
          next = nextHead.(head, last)
          if next == last, do: a, else: a ++ [next]
        end)
      ]
  end)

tails
|> Enum.at(1)
|> Enum.uniq()
|> Enum.count()
|> IO.inspect(label: "Part 1")

tails
|> Enum.at(-1)
|> Enum.uniq()
|> Enum.count()
|> IO.inspect(label: "Part 2")
