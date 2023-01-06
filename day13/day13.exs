input =
  IO.read(:stdio, :all)
  |> String.trim()

defmodule Check do
  def check(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left == right ->
        :cont

      left < right ->
        true

      left > right ->
        false
    end
  end

  def check(left, right) when is_list(left) and is_list(right) do
    # IO.inspect({left, right}, label: "lst-lst")

    cond do
      length(left) > 0 and length(right) == 0 ->
        false

      length(left) == 0 and length(right) > 0 ->
        true

      length(left) == 0 and length(right) == 0 ->
        :cont

      true ->
        [hl | tl] = left
        [hr | tr] = right

        # IO.inspect({hl, hr}, label: "hed-hed")

        case check(hl, hr) do
          :cont ->
            # IO.inspect({tl, tr}, label: "tal-tal")
            check(tl, tr)

          res ->
            res
        end
    end
  end

  def check(left, right) do
    # IO.inspect({left, right}, label: "con-con")
    check(to_list(left), to_list(right))
  end

  def to_list(int) when is_integer(int) do
    [int]
  end

  def to_list(str) when is_bitstring(str) do
    if String.at(str, 0) != "[" or String.at(str, String.length(str) - 1) != "]" do
      throw("not a valid input: '#{str}'")
    end

    content = str |> String.slice(1, String.length(str) - 2)
    tokenize(content, ",")
  end

  defp append(list, buffer) when is_list(list) and is_bitstring(buffer) do
    cond do
      Regex.match?(~r/^[0-9]+$/, buffer) ->
        list ++ [String.to_integer(buffer)]

      String.length(buffer) > 0 ->
        list ++ [buffer]

      true ->
        list
    end
  end

  defp tokenize(str, token) when is_bitstring(str) and is_bitstring(token) do
    String.codepoints(str)
    |> Enum.concat(["END"])
    |> Enum.reduce({[], 0, ""}, fn v, {acc, level, buffer} ->
      cond do
        v == "[" ->
          # |> IO.inspect(label: "open")
          {acc, level + 1, buffer <> v}

        v == "]" ->
          # |> IO.inspect(label: "close")
          {acc, level - 1, buffer <> v}

        level == 0 and (v == token or v == "END") ->
          # |> IO.inspect(label: "append")
          {append(acc, buffer), level, ""}

        true ->
          # |> IO.inspect(label: "buffer")
          {acc, level, buffer <> v}
      end
    end)
    |> elem(0)
  end
end

pairs =
  input
  |> String.split("\n\n")
  |> Enum.map(fn pair -> String.split(pair, "\n") end)

pairs
|> Enum.map(fn [l, r] -> Check.check(l, r) end)
|> Enum.with_index(1)
|> Enum.reduce(0, fn {res, idx}, acc -> if res, do: acc + idx, else: acc end)
|> IO.inspect(label: "Part 1")

dividers = ["[[2]]", "[[6]]"]

packets =
  input
  |> String.split("\n")
  |> Enum.filter(&(String.length(&1) > 0))

ordered =
  dividers
  |> Enum.concat(packets)
  |> Enum.sort(&Check.check/2)

Enum.map(dividers, fn d -> Enum.find_index(ordered, &(&1 == d)) + 1 end)
|> Enum.product()
|> IO.inspect(label: "Part 2")
