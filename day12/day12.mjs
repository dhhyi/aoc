import readDataFromStdin from "../read-data.mjs";

const data = await readDataFromStdin()

function findSymbol(terrain, symbol) {
    for (let y = 0; y < terrain.length; y++) {
        for (let x = 0; x < terrain[y].length; x++) {
            if (terrain[y][x] === symbol) {
                return [x, y];
            }
        }
    }
}

function level(terrain, [x, y]) {
    const c = terrain[y][x];
    let ch
    if (c === "S") {
        ch = 'a'
    } else if (c === "E") {
        ch = 'z'
    } else {
        ch = c;
    }
    return ch.charCodeAt(0) - 96;
}

function contains(visited, [x, y]) {
    return visited[`${x}-${y}`] === true;
}

function append(visited, [x, y]) {
    visited[`${x}-${y}`] = true;
    return visited;
}

function distance([x1, y1], [x2, y2]) {
    return Math.abs(x1 - x2) + Math.abs(y1 - y2);
}

function nextDirections(terrain, [x, y], visited = {}) {
    const l = level(terrain, [x, y]);
    const directions = [[x, y - 1], [x - 1, y], [x + 1, y], [x, y + 1]]
        .filter(([x, y]) => !contains(visited, [x, y]) &&
            x >= 0 && y >= 0 && y < terrain.length && x < terrain[y].length &&
            l - level(terrain, [x, y]) <= 1
        );
    return directions;
}

function dump(terrain, visited = {}) {
    process.stdout.write("  ");
    terrain[0].forEach((_, x) => process.stdout.write((x % 10).toString()));
    process.stdout.write("\n");
    terrain.forEach((line, y) => {
        process.stdout.write(`${y % 10} `)
        line.forEach((c, x) => {
            const color = contains(visited, [x, y]);
            const last = visited.last && visited.last[0] === x && visited.last[1] === y;
            if (last) {
                process.stdout.write("\x1b[32m");
            } else if (color) {
                process.stdout.write("\x1b[31m");
            }
            process.stdout.write(c);
            if (color) {
                process.stdout.write("\x1b[0m");
            }
        });
        process.stdout.write("\n");
    });
}

const terrain = data.split("\n").map(line => line.split(""));

// dump(terrain);

// console.log('S', nextDirections(terrain, findSymbol(terrain, "S")));
// console.log('E', nextDirections(terrain, findSymbol(terrain, "E")));

function traverse(terrain, start, isEnd) {
    const queue = [];
    const visited = {};
    queue.push([start, 0]);
    append(visited, start);
    while (queue.length > 0) {
        const [current, level] = queue.shift();
        if (isEnd(current)) {
            return level;
        } else {
            for (const next of nextDirections(terrain, current, visited)) {
                append(visited, next);
                queue.push([next, level + 1]);
            };
        }
    }
    dump(terrain, visited);
    throw new Error("No path found");
}

const end = findSymbol(terrain, 'S');

const part1 = traverse(terrain, findSymbol(terrain, 'E'), current => distance(current, end) === 0);
console.log(`Part 1: ${part1}`);

const part2 = traverse(terrain, findSymbol(terrain, 'E'), current => level(terrain, current) === 1);
console.log(`Part 2: ${part2}`);
