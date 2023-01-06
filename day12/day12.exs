defmodule Terrain do
  defstruct [:terrain, :maxX, :maxY, :levels]

  def create(terrainRaw) do
    maxX = terrainRaw |> Enum.at(0) |> String.length()
    maxY = Enum.count(terrainRaw)

    levels =
      terrainRaw
      |> Enum.with_index(fn line, y ->
        String.to_charlist(line)
        |> Enum.with_index(fn ch, x ->
          {{x, y},
           case ch do
             # 'S' -> 'a'
             83 -> 97
             # 'E' -> 'z'
             69 -> 122
             _ -> ch
           end - 97}
        end)
      end)
      |> List.flatten()
      |> Enum.into(%{})

    %Terrain{terrain: terrainRaw, maxX: maxX, maxY: maxY, levels: levels}
  end

  def findSymbol(terrain, symbol) do
    y =
      Enum.find_index(terrain.terrain, fn line ->
        String.contains?(line, symbol)
      end)

    x = String.split(Enum.at(terrain.terrain, y), symbol) |> List.first() |> String.length()
    {x, y}
  end

  def nextDirections(terrain, {x, y}) do
    l = terrain.levels[{x, y}]

    Enum.filter(
      [
        {x - 1, y},
        {x, y - 1},
        {x, y + 1},
        {x + 1, y}
      ],
      fn {x, y} ->
        x >= 0 and x < terrain.maxX and y >= 0 and y < terrain.maxY and
          l - terrain.levels[{x, y}] <= 1
      end
    )
  end

  def area(terrain), do: terrain.maxX * terrain.maxY

  def distance({x1, y1}, {x2, y2}) do
    dx = x1 - x2
    dy = y1 - y2
    trunc(:math.sqrt(:math.pow(dx, 2) + :math.pow(dy, 2)))
    # abs(dx) + abs(dy)
  end

  def dumpPath(terrain, path) do
    terrain.terrain
    |> Enum.with_index(fn line, y ->
      if y == 0 do
        tens = trunc(String.length(line) / 10)

        if tens > 0 do
          IO.write("    ")

          Enum.each(0..tens, fn col ->
            IO.write("|" <> String.pad_trailing(Integer.to_string(col * 10), 3) <> "      ")
          end)

          IO.puts("")
        end

        IO.write("    ")

        Enum.each(0..(String.length(line) - 1), fn col ->
          IO.write("#{rem(col, 10)}")
        end)

        IO.puts("")
      end

      IO.write(String.pad_leading(Integer.to_string(y), 3, " ") <> " ")

      Enum.with_index(String.codepoints(line), fn char, x ->
        color = MapSet.member?(path, {x, y})

        if color do
          IO.write("\e[31m" <> char <> "\e[0m")
        else
          IO.write(char)
        end
      end)

      IO.puts("")
    end)
  end
end

defmodule SP do
  # https://de.wikipedia.org/wiki/Breitensuche

  #   BFS(start_node, goal_node)
  #     return BFS'({start_node}, ∅, goal_node);

  #   BFS'(fringe, gesehen, goal_node)
  #     if(fringe == ∅)
  #     // Knoten nicht gefunden
  #         return false;
  #     if (goal_node ∈ fringe)
  #         return true;
  #     return BFS'({child | x ∈ fringe, child ∈ nachfolger(x)} \ gesehen, gesehen ∪ fringe, goal_node);

  def bfs(terrain, start_node, goal?) do
    bfs_run(terrain, MapSet.new([start_node]), MapSet.new(), goal?, 0)
  end

  defp bfs_run(terrain, fringe, visited, goal?, level) do
    cond do
      MapSet.size(fringe) == 0 ->
        false

      Enum.any?(fringe, goal?) ->
        level

      true ->
        new_fringe =
          fringe
          |> Enum.flat_map(fn n -> Terrain.nextDirections(terrain, n) end)
          |> Enum.filter(fn next -> not MapSet.member?(visited, next) end)
          |> Enum.into(MapSet.new())

        new_visited = MapSet.union(visited, fringe)

        bfs_run(
          terrain,
          new_fringe,
          new_visited,
          goal?,
          level + 1
        )
    end
  end
end

terrainRaw =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")

terrain = Terrain.create(terrainRaw)

start = terrain |> Terrain.findSymbol("E")
finish = terrain |> Terrain.findSymbol("S")

SP.bfs(terrain, start, fn pos -> pos == finish end)
|> IO.inspect(label: "Part 1")

SP.bfs(terrain, start, fn pos -> terrain.levels[pos] == 0 end)
|> IO.inspect(label: "Part 2")
