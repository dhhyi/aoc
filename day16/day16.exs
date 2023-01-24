valves =
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
  |> Enum.into(%{})

execute_example = fn approach ->
  example_path = [
    {:goto, "DD"},
    {:open, "DD"},
    {:goto, "CC"},
    {:goto, "BB"},
    {:open, "BB"},
    {:goto, "AA"},
    {:goto, "II"},
    {:goto, "JJ"},
    {:open, "JJ"},
    {:goto, "II"},
    {:goto, "AA"},
    {:goto, "DD"},
    {:goto, "EE"},
    {:goto, "FF"},
    {:goto, "GG"},
    {:goto, "HH"},
    {:open, "HH"},
    {:goto, "GG"},
    {:goto, "FF"},
    {:goto, "EE"},
    {:open, "EE"},
    {:goto, "DD"},
    {:goto, "CC"},
    {:open, "CC"},
    {:noop},
    {:noop},
    {:noop},
    {:noop},
    {:noop}
  ]

  example_path
  |> Enum.reduce(approach, fn action, approach ->
    # IO.inspect(Approach.status(approach))
    # IO.inspect(Extrapolate.calculate_possible_max(approach))
    Approach.next(approach, action)
  end)
  |> IO.inspect()
end

defmodule Approach do
  defstruct [
    :valves,
    :open_valves,
    :closed_valves,
    :flow_rate,
    :released,
    :minute,
    :room,
    :limit,
    :next
  ]

  def new(valves) do
    %Approach{
      valves: valves,
      flow_rate: 0,
      released: 0,
      minute: 0,
      room: "AA",
      limit: 30,
      next: [],
      open_valves: MapSet.new(),
      closed_valves:
        Map.keys(valves)
        |> Enum.filter(fn valve -> elem(valves[valve], 0) > 0 end)
        |> Enum.sort_by(fn valve -> elem(valves[valve], 0) end, :desc)
    }
    |> advance()
  end

  def status(approach) do
    {approach.minute, approach.room, approach.flow_rate, approach.released, approach.open_valves,
     length(approach.closed_valves) == 0}
  end

  defp advance(approach) do
    if approach.minute >= approach.limit do
      raise "Limit reached"
    else
      next =
        cond do
          approach.minute + 1 >= approach.limit ->
            []

          length(approach.closed_valves) == 0 ->
            [{:noop}]

          true ->
            if(Enum.member?(approach.closed_valves, approach.room),
              do: [{:open, approach.room}],
              else: []
            ) ++
              (elem(approach.valves[approach.room], 1)
               |> Enum.map(fn room -> {:goto, room} end))
        end

      %Approach{
        approach
        | minute: approach.minute + 1,
          released: approach.released + approach.flow_rate,
          next: next
      }
    end
  end

  def next(approach, {:noop}) do
    advance(approach)
  end

  def next(approach, {:open, room}) do
    current = elem(approach.valves[room], 0)

    %Approach{
      approach
      | flow_rate: approach.flow_rate + current,
        open_valves: MapSet.put(approach.open_valves, room),
        closed_valves: Enum.filter(approach.closed_valves, fn v -> v != room end)
    }
    |> advance()
  end

  def next(approach, {:goto, room}) do
    %Approach{approach | room: room} |> advance()
  end
end

defmodule Extrapolate do
  defp ideal_steps(approach) do
    all = Enum.flat_map(approach.closed_valves, fn room -> [{:goto, room}, {:open, room}] end)

    if Enum.at(all, 0) == {:goto, approach.room} do
      Enum.slice(all, 1, length(all) - 1)
    else
      all
    end
  end

  def calculate_possible_max(approach) do
    Enum.reduce(
      (approach.minute + 1)..approach.limit,
      {approach.released, approach.flow_rate, ideal_steps(approach)},
      fn _, {released, rate, steps} ->
        case steps do
          [{:goto, _} | rest] ->
            {released + rate, rate, rest}

          [{:open, room} | rest] ->
            current = elem(approach.valves[room], 0)
            {released + rate + current, rate + current, rest}

          [] ->
            {released + rate, rate, steps}
        end
      end
    )
    |> elem(0)
  end
end

defmodule Traverse do
  defp traverse(approach, current_max) do
    case approach.next do
      [] ->
        if approach.released > current_max, do: approach.released, else: current_max

      _ ->
        Enum.reduce(approach.next, current_max, fn action, current_max ->
          possible_max = Extrapolate.calculate_possible_max(approach)

          if possible_max < current_max do
            current_max
          else
            new_max = traverse(Approach.next(approach, action), current_max)

            if new_max > current_max, do: new_max, else: current_max
          end
        end)
    end
  end

  def traverse(approach) do
    traverse(approach, 0)
  end
end

approach = Approach.new(valves)

# execute_example.(approach)

Traverse.traverse(approach) |> IO.inspect(label: "Part 1")
