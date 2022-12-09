#!/bin/sh

set -e

day="$(date +%-d)"
day="${2:-$day}"

# mkdir -p "day$day"
dcc "dcc://${1:-javascript}" "day$day" --name "AOC 2022 Day $day" --no-vscode

cat <<EOF > "day$day/day$day.js"
const stdin = process.openStdin();
let data = "";
stdin.on("data", function (chunk) {
    data += chunk;
});

stdin.on("end", function () {
    console.log(data);
});
EOF

code-insiders "day$day"
