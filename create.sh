#!/bin/sh

set -e

day="$(date +%-d)"
day="${2:-$day}"

lang="${1:-elixir}"

# mkdir -p "day$day"
dcc "dcc://$lang" "day$day" --name "AOC 2022 Day $day" --no-vscode

if [ "$lang" = "javascript" ]; then
cat <<EOF > "day$day/day$day.mjs"
import readDataFromStdin from "../read-data.mjs";
const data = await readDataFromStdin()

console.log(data);
EOF
fi

if [ "$lang" = "elixir" ]; then
cat <<EOF > "day$day/day$day.exs"
IO.read(:stdio, :all)
|> String.trim()
|> String.split("\n")
|> IO.inspect()
EOF
fi

code-insiders "day$day"
