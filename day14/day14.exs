input =
  IO.read(:stdio, :all)
  |> String.trim()

defmodule Cave do
  defstruct [:rocks, :sand, :start, :min, :max, :bottom?]

  def calc_min_max(cave) do
    elems = MapSet.put(cave.rocks, cave.start)

    cave_min =
      {Enum.min_by(elems, &elem(&1, 0)) |> elem(0), Enum.min_by(elems, &elem(&1, 1)) |> elem(1)}

    cave_max =
      {Enum.max_by(elems, &elem(&1, 0)) |> elem(0), Enum.max_by(elems, &elem(&1, 1)) |> elem(1)}

    %{cave | min: cave_min, max: cave_max}
  end

  def new(rocks, start, bottom? \\ false) do
    %Cave{rocks: rocks, sand: MapSet.new(), start: start, bottom?: bottom?} |> calc_min_max()
  end

  def is_in_bound?(cave, {x, y}) do
    if cave.bottom? do
      true
    else
      x >= cave.min |> elem(0) and x <= cave.max |> elem(0) and y >= cave.min |> elem(1) and
        y <= cave.max |> elem(1)
    end
  end

  def is_blocked?(cave, {x, y}) do
    MapSet.member?(cave.rocks, {x, y}) or
      MapSet.member?(cave.sand, {x, y}) or (cave.bottom? and elem(cave.max, 1) + 2 == y)
  end

  def sand_count(cave) do
    MapSet.size(cave.sand)
  end

  def dump(cave) do
    %{min: orig_min, max: orig_max} =
      %{cave | rocks: MapSet.union(cave.rocks, cave.sand)} |> calc_min_max()

    {cave_min, cave_max} =
      if cave.bottom? do
        {{(orig_min |> elem(0)) - 2, orig_min |> elem(1)},
         {(orig_max |> elem(0)) + 2, (orig_max |> elem(1)) + 1}}
      else
        {orig_min, orig_max}
      end

    for y <- (cave_min |> elem(1))..(cave_max |> elem(1)) do
      for x <- (cave_min |> elem(0))..(cave_max |> elem(0)) do
        cond do
          {x, y} == cave.start -> "+"
          MapSet.member?(cave.rocks, {x, y}) -> "#"
          MapSet.member?(cave.sand, {x, y}) -> "o"
          cave.bottom? and elem(cave.max, 1) + 2 == y -> "#"
          true -> "."
        end
      end
      |> Enum.join()
      |> IO.puts()
    end

    cave
  end

  defp fall_direction(cave, {x, y}) do
    cond do
      not Cave.is_in_bound?(cave, {x, y}) or Cave.is_blocked?(cave, cave.start) ->
        {:invalid, {x, y}}

      not Cave.is_blocked?(cave, {x, y + 1}) ->
        {:falling, {x, y + 1}}

      not Cave.is_blocked?(cave, {x - 1, y + 1}) ->
        {:falling, {x - 1, y + 1}}

      not Cave.is_blocked?(cave, {x + 1, y + 1}) ->
        {:falling, {x + 1, y + 1}}

      true ->
        {:resting, {x, y}}
    end
  end

  defp fall(cave, position) do
    case fall_direction(cave, position) do
      {:falling, pos} ->
        fall(cave, pos)

      {:resting, pos} ->
        %{cave | sand: MapSet.put(cave.sand, pos)}

      {:invalid, _} ->
        nil
    end
  end

  def fall(cave) do
    case fall(cave, cave.start) do
      nil ->
        cave

      cave ->
        fall(cave)
    end
  end
end

cave =
  input
  |> String.split("\n")
  |> Enum.map(fn line ->
    String.split(line, " -> ")
    |> Enum.map(fn c ->
      [x, y] = String.split(c, ",")
      {String.to_integer(x), String.to_integer(y)}
    end)
  end)
  |> Enum.flat_map(fn line -> Enum.chunk_every(line, 2, 1, :discard) end)
  |> Enum.flat_map(fn [{x1, y1}, {x2, y2}] ->
    for(x <- x1..x2, y <- y1..y2, do: {x, y})
  end)
  |> Enum.into(MapSet.new())
  |> Cave.new({500, 0})

cave
|> Cave.fall()
# |> Cave.dump()
|> Cave.sand_count()
|> IO.inspect(label: "Part 1")

%{cave | bottom?: true}
|> Cave.fall()
# |> Cave.dump()
|> Cave.sand_count()
|> IO.inspect(label: "Part 2")
