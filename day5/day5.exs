[stacksInput, instructionsInput] =
  IO.read(:stdio, :all)
  |> String.split("\n\n")

instructions =
  instructionsInput
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&Regex.named_captures(~r/^move (?<num>\d+) from (?<from>\d+) to (?<to>\d+)$/, &1))
  |> Enum.map(fn m -> %{num: String.to_integer(m["num"]), from: m["from"], to: m["to"]} end)
  |> IO.inspect(label: "instructions")

stacks =
  stacksInput
  |> String.split("\n")
  |> Enum.reverse()
  |> Enum.map(fn line ->
    line
    |> String.codepoints()
    |> Enum.chunk_every(4)
    |> Enum.map(&Enum.at(&1, 1))
  end)
  |> Enum.reduce(%{}, fn val, acc ->
    if length(Map.keys(acc)) == 0 do
      Enum.reduce(val, %{}, fn key, acc ->
        Map.put_new(acc, key, [])
      end)
    else
      Enum.reduce(Enum.zip(Map.keys(acc), val), acc, fn e, acc ->
        k = elem(e, 0)
        v = elem(e, 1)

        if v != " " do
          Map.put(acc, k, [v] ++ Map.get(acc, k, []))
        else
          acc
        end
      end)
    end
  end)
  |> IO.inspect(label: "stacks")

Enum.reduce(instructions, stacks, fn instruction, stacks ->
  num = instruction.num

  Enum.reduce(1..num, stacks, fn _, stacks ->
    [el | from] = Map.get(stacks, instruction.from)
    to = Map.get(stacks, instruction.to)

    stacks = Map.put(stacks, instruction.from, from)
    stacks = Map.put(stacks, instruction.to, [el] ++ to)
  end)
end)
|> Map.values()
|> Enum.map(&Enum.at(&1, 0))
|> Enum.join()
|> IO.inspect(label: "Part 1")

Enum.reduce(instructions, stacks, fn instruction, stacks ->
  num = instruction.num

  from = Map.get(stacks, instruction.from)
  els = Enum.take(from, num)
  from = Enum.drop(from, num)
  to = Map.get(stacks, instruction.to)

  stacks = Map.put(stacks, instruction.from, from)
  stacks = Map.put(stacks, instruction.to, els ++ to)
end)
|> Map.values()
|> Enum.map(&Enum.at(&1, 0))
|> Enum.join()
|> IO.inspect(label: "Part 2")
