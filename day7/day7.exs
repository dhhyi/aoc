instructions =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")

tree =
  instructions
  |> Enum.reduce(%{}, fn instruction, acc ->
    if String.starts_with?(instruction, "$ ") do
      instruction = String.slice(instruction, 2..-1)

      if String.starts_with?(instruction, "cd ") do
        dir = String.slice(instruction, 3..-1)

        Map.update(acc, :current, dir, fn current ->
          if dir == ".." do
            String.split(current, "+") |> Enum.drop(-1) |> Enum.join("+")
          else
            current <> "+" <> dir
          end
        end)
      else
        if instruction == "ls" do
          acc
        else
          throw("Unknown instruction: #{instruction}")
        end
      end
    else
      if String.starts_with?(instruction, "dir ") do
        acc
      else
        file =
          ~r/^(?<size>[0-9]+) (?<name>.*)/
          |> Regex.named_captures(instruction)

        size = String.to_integer(file["size"])
        current = Map.get(acc, :current) |> String.split("+")

        paths =
          Enum.map(1..length(current), fn l ->
            Enum.slice(current, 0, l) |> Enum.join("+")
          end)

        Enum.reduce(paths, acc, fn path, acc ->
          Map.update(acc, path, size, fn s ->
            size + s
          end)
        end)
      end
    end
  end)
  |> Map.drop([:current])
  |> IO.inspect(label: "tree")

tree
|> Map.values()
|> Enum.filter(fn v -> v <= 100_000 end)
|> Enum.sum()
|> IO.inspect(label: "Part 1")

remain = 70_000_000 - tree["/"]
needed = 30_000_000 - remain

tree
|> Map.values()
|> Enum.filter(fn v -> v >= needed end)
|> Enum.sort()
|> Enum.at(0)
|> IO.inspect(label: "Part 2")
