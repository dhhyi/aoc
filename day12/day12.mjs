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
    // console.log(`level(${x}, ${y})`);
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

function contains(list, [x, y]) {
    return list.some(([x1, y1]) => x1 === x && y1 === y);
}

function distance([x1, y1], [x2, y2]) {
    return Math.abs(x1 - x2) + Math.abs(y1 - y2);
}

function nextDirections(terrain, [x, y], visited = [], end) {
    const l = level(terrain, [x, y]);
    const directions = [[x, y - 1], [x, y + 1], [x - 1, y], [x + 1, y]];
    return directions.filter(([x, y]) =>
        // terrain restrictions
        x >= 0 && y >= 0 && y < terrain.length && x < terrain[y].length &&
        // must be same or one higher level
        [l, l + 1].some(l => level(terrain, [x, y]) === l) &&
        // must not be visited
        !contains(visited, [x, y]))
        // ascending should be preferred
        .sort((a, b) => level(terrain, b) - level(terrain, a))
        // go to end first
        .sort((a, b) => (end && distance(end, a) - distance(end, b)) || 0)
}

function dump(terrain) {
    process.stdout.write("  ");
    terrain[0].forEach((_, x) => process.stdout.write((x % 10).toString()));
    process.stdout.write("\n");
    terrain.forEach((line, y) => console.log(`${y % 10} ${line.join("")}`));
}

const terrain = data.split("\n").map(line => line.split(""));

dump(terrain);

// console.log(findSymbol(terrain, "E"));
// console.log(findSymbol(terrain, "S"));

// console.log(level(terrain, findSymbol(terrain, "S")));
// console.log(level(terrain, [1, 1]));
// console.log(level(terrain, findSymbol(terrain, "E")));

console.log('S', nextDirections(terrain, findSymbol(terrain, "S")));
console.log('1-2', nextDirections(terrain, [1, 2], [], findSymbol(terrain, "E")));
console.log('2-1', nextDirections(terrain, [2, 1]));
console.log('2-2', nextDirections(terrain, [2, 2]));
console.log('2-4', nextDirections(terrain, [2, 4]));
console.log('E', nextDirections(terrain, findSymbol(terrain, "E"), [[4, 2]]));
console.log('0-1', nextDirections(terrain, [0, 1]));

let path;
let bound = terrain.length * terrain[0].length;

function traverse(terrain, end, visited) {
    if (visited.length > bound) {
        return;
    }
    const current = visited[visited.length - 1];
    if (current[0] === end[0] && current[1] === end[1]) {
        console.log(`found path with length ${visited.length - 1}`);
        bound = visited.length - 1;
        path = visited;
        return;
    }
    nextDirections(terrain, current, visited, end).forEach(next => {
        traverse(terrain, end, [...visited, next])
    })
}

traverse(terrain, findSymbol(terrain, "E"), [findSymbol(terrain, 'S')]);

const part1 = path.length - 1;
console.log(`Part 1: ${part1}`);
