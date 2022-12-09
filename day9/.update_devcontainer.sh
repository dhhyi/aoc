#!/bin/sh -e

cd "$(dirname "$(readlink -f "$0")")"

curl -so- https://raw.githubusercontent.com/dhhyi/devcontainer-creator/dist/bundle.js | node - dcc://javascript . --name "AOC 2022 Day 9" --no-vscode "$@"
