plays =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&String.split(&1, " "))

defmodule RockPaperScissors do
  def result(:rock, :scissors), do: :win
  def result(:paper, :rock), do: :win
  def result(:scissors, :paper), do: :win
  def result(x, x), do: :draw
  def result(_, _), do: :lose

  def points(:rock), do: 1
  def points(:paper), do: 2
  def points(:scissors), do: 3

  def points(me, opponent) do
    points(me) +
      case result(me, opponent) do
        :win -> 6
        :draw -> 3
        :lose -> 0
      end
  end

  def which(opponent, outcome) do
    [:rock, :paper, :scissors]
    |> Enum.find(fn me -> result(me, opponent) == outcome end)
  end
end

code1 = %{
  "A" => :rock,
  "B" => :paper,
  "C" => :scissors,
  "X" => :rock,
  "Y" => :paper,
  "Z" => :scissors
}

part1 =
  plays
  |> Enum.map(fn [l, r] ->
    opponent = Map.get(code1, l)
    me = Map.get(code1, r)

    RockPaperScissors.points(me, opponent)
  end)
  |> Enum.sum()

IO.puts("Part 1: #{part1}")

code2 = %{
  "A" => :rock,
  "B" => :paper,
  "C" => :scissors,
  "X" => :lose,
  "Y" => :draw,
  "Z" => :win
}

part2 =
  plays
  |> Enum.map(fn [l, r] ->
    opponent = Map.get(code2, l)
    outcome = Map.get(code2, r)
    me = RockPaperScissors.which(opponent, outcome)

    RockPaperScissors.points(me, opponent)
  end)
  |> Enum.sum()

IO.puts("Part 2: #{part2}")
