defmodule StatefulStream do
  defstruct [:elements, :index]

  def new(elements) do
    %StatefulStream{elements: elements, index: 0}
  end

  def next(%StatefulStream{elements: elements, index: index} = stream) do
    element = Enum.at(elements, index)
    new_index = rem(index + 1, Enum.count(elements))

    {element, %{stream | index: new_index}}
  end

  def take(_, n) when n < 1 do
    raise "n must be greater than 0"
  end

  def take(stream, 1) do
    {element, stream} = next(stream)
    {[element], stream}
  end

  def take(stream, n) do
    {element, stream} = next(stream)
    {elements, upstream} = take(stream, n - 1)
    {[element | elements], upstream}
  end
end

jets =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.codepoints()
  |> StatefulStream.new()

blocks = StatefulStream.new([:HLine, :Plus, :RevL, :VLine, :Block])

defmodule Chamber do
  defp spawn(chamber, tile) do
    height = max_y(chamber) + 1

    pos =
      case tile do
        :HLine -> height + 3
        :Plus -> height + 5
        :RevL -> height + 5
        :VLine -> height + 6
        :Block -> height + 4
      end

    {2, pos}
  end

  defp elements(:HLine, {x, y}) do
    MapSet.new([{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}])
  end

  defp elements(:Plus, {x, y}) do
    MapSet.new([{x + 1, y}, {x, y - 1}, {x + 1, y - 1}, {x + 2, y - 1}, {x + 1, y - 2}])
  end

  defp elements(:RevL, {x, y}) do
    MapSet.new([{x + 2, y}, {x + 2, y - 1}, {x, y - 2}, {x + 1, y - 2}, {x + 2, y - 2}])
  end

  defp elements(:VLine, {x, y}) do
    MapSet.new([{x, y}, {x, y - 1}, {x, y - 2}, {x, y - 3}])
  end

  defp elements(:Block, {x, y}) do
    MapSet.new([{x, y}, {x + 1, y}, {x, y - 1}, {x + 1, y - 1}])
  end

  defp max_y(set) do
    set
    |> Enum.max_by(fn {_, y} -> y end, fn -> {0, -1} end)
    |> elem(1)
  end

  def height(chamber) do
    max_y(chamber) + 1
  end

  def push(chamber, tile, {x, y}, direction) do
    {nx, ny} =
      case direction do
        ">" -> {x + 1, y}
        "<" -> {x - 1, y}
        "v" -> {x, y - 1}
      end

    next_elems = elements(tile, {nx, ny})

    if not Enum.any?(next_elems, fn {x, y} -> x < 0 or x > 6 or y < 0 end) and
         not Enum.any?(next_elems, fn b -> MapSet.member?(chamber, b) end) do
      {nx, ny}
    else
      nil
    end
  end

  defp fill_(chamber, jets, tile, pos) do
    {jet, jets} = StatefulStream.next(jets)

    npos =
      case push(chamber, tile, pos, jet) do
        nil -> pos
        npos -> npos
      end

    case push(chamber, tile, npos, "v") do
      nil ->
        {jets, MapSet.union(chamber, elements(tile, npos))}

      nnpos ->
        fill_(chamber, jets, tile, nnpos)
    end
  end

  def fill(chamber, jets, blocks, num) do
    Enum.reduce(1..num, {chamber, jets, blocks}, fn iteration, {chamber, jets, blocks} ->
      {block, blocks} = StatefulStream.next(blocks)

      chamber =
        if rem(iteration, 50) == 0 do
          simplify(chamber)
        else
          chamber
        end

      {jets, chamber} = fill_(chamber, jets, block, spawn(chamber, block))

      {chamber, jets, blocks}
    end)
    |> elem(0)
  end

  defp outline(blocks, border, visited, elements) do
    new_visited = MapSet.union(visited, border)

    new_border =
      Enum.flat_map(border, fn {x, y} -> [{x - 1, y}, {x + 1, y}, {x, y - 1}] end)
      |> Enum.filter(fn {x, y} -> x >= 0 and x <= 6 and y >= 0 end)
      |> Enum.into(MapSet.new())
      |> MapSet.difference(visited)

    outline_elements = MapSet.intersection(new_border, blocks)
    outline_elements = MapSet.union(outline_elements, elements)
    new_border = MapSet.difference(new_border, outline_elements)

    if MapSet.size(new_border) == 0 do
      outline_elements
    else
      outline(blocks, new_border, new_visited, outline_elements)
    end
  end

  def simplify(chamber) do
    max_y = max_y(chamber)

    visited = MapSet.new(for(x <- 0..6, do: {x, max_y + 1}))
    border = MapSet.new(for(x <- 0..6, do: {x, max_y}))

    outline(chamber, border, visited, MapSet.new())
  end
end

Chamber.fill(MapSet.new(), jets, blocks, 2022)
|> Chamber.height()
|> IO.inspect(label: "Part 1")

# num = 1_000_000_000_000
num = 500_000
# num = 2022

Chamber.fill(MapSet.new(), jets, blocks, num)
|> Chamber.height()
|> IO.inspect(label: "Part 2")
