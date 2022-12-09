#!/bin/sh

set -e

day="$(date +%-d)"
day="${2:-$day}"

lang="${1:-javascript}"

# mkdir -p "day$day"
dcc "dcc://$lang" "day$day" --name "AOC 2022 Day $day" --no-vscode

if [ "$lang" = "javascript" ]; then
cat <<EOF > "day$day/day$day.mjs"
import readDataFromStdin from "../read-data.mjs";
const data = await readDataFromStdin()

console.log(data);
EOF
fi

code-insiders "day$day"
