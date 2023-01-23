defmodule Manhattan do
  def distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def reverse({x, y}, d, y2) do
    diff = abs(y - y2)

    cond do
      diff == d -> x
      diff > d -> nil
      true -> {x - (d - diff), x + (d - diff)}
    end
  end
end

defmodule Ranges do
  def simplify(list) do
    list
    |> Enum.sort()
    |> Enum.reduce([], fn {l, r}, acc ->
      case acc do
        [] -> [{l, r}]
        [{l1, r1} | t] when l1 <= l and l <= r1 + 1 -> [{l1, max(r1, r)} | t]
        _ -> [{l, r} | acc]
      end
    end)
    |> Enum.reverse()
  end
end

input =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")

line = List.first(input) |> String.to_integer()

sensors_and_beacons =
  input
  |> Enum.slice(1..-1//1)
  |> Enum.map(fn line ->
    [sx, sy, bx, by] =
      Regex.run(
        ~r/Sensor at x=([-0-9]+), y=([-0-9]+): closest beacon is at x=([-0-9]+), y=([-0-9]+)/,
        line
      )
      |> Enum.slice(1, 4)
      |> Enum.map(&String.to_integer/1)

    [{:sensor, {sx, sy}}, {:beacon, {bx, by}}]
  end)

beacons_in_line =
  sensors_and_beacons
  |> Enum.map(fn [_, {:beacon, {bx, by}}] -> {bx, by} end)
  |> Enum.filter(fn {_, y} -> y == line end)
  |> Enum.into(MapSet.new())
  |> MapSet.size()

coverage =
  sensors_and_beacons
  |> Enum.reduce(%{}, fn [{:sensor, {sx, sy}}, {:beacon, {bx, by}}], acc ->
    d = Manhattan.distance({sx, sy}, {bx, by})

    Enum.reduce(max(sy - d, 0)..min(sy + d, 2 * line), acc, fn y, acc ->
      res =
        case Manhattan.reverse({sx, sy}, d, y) do
          nil -> nil
          {l, r} -> {l, r}
          v -> {v, v}
        end

      case res do
        nil -> acc
        t -> Map.update(acc, y, [t], fn list -> Ranges.simplify(list ++ [t]) end)
      end
    end)
  end)

coverage[line]
|> Enum.map(fn {l, r} -> Range.new(l, r) |> Range.size() end)
|> Enum.reduce(-1 * beacons_in_line, &+/2)
|> IO.inspect(label: "Part 1")

pos = Map.filter(coverage, fn {_, cov} -> length(cov) >= 2 end)
y = Map.keys(pos) |> List.first()
x = (pos[y] |> List.first() |> elem(1)) + 1
# IO.inspect({x, y}, label: "missing beacon")
(x * 4_000_000 + y) |> IO.inspect(label: "Part 2")
