{valves, graph} =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn line ->
    regex =
      ~r/Valve (?<valve>\w+) has flow rate=(?<flow_rate>\d+); tunnels? leads? to valves? (?<tunnels>.*)/

    if Regex.match?(regex, line) do
      match = Regex.named_captures(regex, line)
      name = match["valve"]

      {name, {String.to_integer(match["flow_rate"]), String.split(match["tunnels"], ", ")}}
    else
      raise "Could not parse line: '#{line}'"
    end
  end)
  |> Enum.reduce({[], []}, fn {name, {flow_rate, to}}, {valves, tunnels} ->
    new_valves = if flow_rate > 0, do: [{name, flow_rate} | valves], else: valves
    tunnels = [{name, to} | tunnels]
    {new_valves, tunnels}
  end)
  |> (fn {valves, tunnels} -> {Enum.into(valves, %{}), Enum.into(tunnels, %{})} end).()

defmodule BFS do
  def bfs(graph, start, goals) do
    bfs(graph, MapSet.new([start]), goals, MapSet.new(), 0, %{})
  end

  defp bfs(graph, border, goals, visited, step, results) do
    visited = MapSet.union(border, visited)
    border = MapSet.new(Enum.flat_map(border, &graph[&1])) |> MapSet.difference(visited)
    step = step + 1

    results =
      Enum.reduce(MapSet.intersection(border, goals), results, fn goal, results ->
        Map.put(results, goal, step)
      end)

    new_goals = MapSet.difference(goals, border)

    if MapSet.size(goals) == 0 or MapSet.size(border) == 0 do
      results
    else
      bfs(graph, border, new_goals, visited, step, results)
    end
  end
end

distances =
  (["AA"] ++ Map.keys(valves))
  |> Enum.map(fn start ->
    result = BFS.bfs(graph, start, MapSet.new(Map.keys(valves)))
    {start, result}
  end)
  |> Enum.into(%{})

defmodule Data do
  defstruct [:valves, :distances, :graph, :limit]

  def new(valves, distances, graph, limit) do
    %Data{valves: valves, distances: distances, graph: graph, limit: limit}
  end
end

defmodule Calculate do
  def flow(data, way) do
    [start | remaining] = way

    [rate, time, _, released] =
      Enum.reduce(remaining, [0, 0, start, 0], fn valve, [rate, time, position, released] ->
        valve_rate = data.valves[valve]
        distance = data.distances[position][valve]
        new_rate = rate + valve_rate
        new_time = time + distance + 1
        released = released + rate * (new_time - time)
        [new_rate, new_time, valve, released]
      end)

    released + rate * (data.limit - time)
  end

  def next(data, remaining, time, from) do
    order =
      MapSet.to_list(remaining)
      |> Enum.map(fn to ->
        {to, time + data.distances[from][to] + 1}
      end)
      |> Enum.filter(fn {_to, time} -> time <= data.limit end)

    if order == [], do: [nil], else: order
  end
end

defmodule Traversal do
  def traverse(data, from) when is_bitstring(from) do
    traverse(data, from, 0, MapSet.new(Map.keys(data.valves)), [])
  end

  def traverse(data, from) when is_tuple(from) do
    traverse(data, from, {0, 0}, MapSet.new(Map.keys(data.valves)), {[], []})
  end

  def traverse(data, {from1, from2}, {time1, time2}, remaining, {visited1, visited2}) do
    visited1 = visited1 ++ [from1]
    visited2 = visited2 ++ [from2]

    remaining = MapSet.difference(remaining, MapSet.new(visited1 ++ visited2))

    order =
      for(
        o1 <- Calculate.next(data, remaining, time1, from1),
        o2 <- Calculate.next(data, remaining, time2, from2),
        {o1, o2} != {nil, nil},
        o1 == nil or o2 == nil or elem(o1, 0) != elem(o2, 0),
        do: {o1, o2}
      )

    if length(order) == 0 do
      Calculate.flow(data, visited1) + Calculate.flow(data, visited2)
    else
      Enum.map(order, fn args ->
        case args do
          {{to1, time1}, nil} ->
            Calculate.flow(data, visited2) +
              traverse(data, to1, time1, remaining, visited1)

          {nil, {to2, time2}} ->
            Calculate.flow(data, visited1) +
              traverse(data, to2, time2, remaining, visited2)

          {{to1, time1}, {to2, time2}} ->
            traverse(data, {to1, to2}, {time1, time2}, remaining, {visited1, visited2})
        end
      end)
      |> Enum.max()
    end
  end

  def traverse(data, from, time, remaining, visited) do
    visited = visited ++ [from]

    remaining = MapSet.difference(remaining, MapSet.new(visited))

    order = Calculate.next(data, remaining, time, from)

    case order do
      [nil] ->
        Calculate.flow(data, visited)

      _ ->
        Enum.map(order, fn {to, time} ->
          traverse(data, to, time, remaining, visited)
        end)
        |> Enum.max()
    end
  end
end

data1 = Data.new(valves, distances, graph, 30)

# Calculate.flow(data1, ["AA", "DD", "BB", "JJ", "HH", "EE", "CC"])
# |> IO.inspect(label: "Example 1")

Traversal.traverse(data1, "AA") |> IO.inspect(label: "Part 1")

data2 = Data.new(valves, distances, graph, 26)

# (Calculate.flow(data2, ["AA", "JJ", "BB", "CC"]) +
#    Calculate.flow(data2, ["AA", "DD", "HH", "EE"]))
# |> IO.inspect(label: "Example 2")

Traversal.traverse(data2, {"AA", "AA"}) |> IO.inspect(label: "Part 2")
