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
    visited.last = [x, y];
    return visited;
}

function unappend(visited, [x, y], [x2, y2]) {
    delete visited[`${x}-${y}`];
    visited.last = [x2, y2];
    return visited;
}

function size(visited) {
    return Object.keys(visited).length - 2;
}

function distance([x1, y1], [x2, y2]) {
    return Math.abs(x1 - x2) + Math.abs(y1 - y2);
}

function nextDirections(terrain, [x, y], visited = {}, end) {
    const l = level(terrain, [x, y]);
    const directions = [[x, y - 1], [x + 1, y], [x - 1, y], [x, y + 1]].filter(([x, y]) => !contains(visited, [x, y]) && x >= 0 && y >= 0 && y < terrain.length && x < terrain[y].length);

    const higher = []
    const same = []
    directions.forEach(([x, y]) => {
        const cl = level(terrain, [x, y]);
        if (cl === l + 1) {
            higher.push([x, y])
        } else if (cl === l) {
            same.push([x, y])
        }
    });
    return higher.concat(end ? same.sort((a, b) => distance(a, end) - distance(b, end)) : same);
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
// let bound = 2 * Math.max(terrain.length, terrain[0].length);
// let bound = 3 * (terrain.length + terrain[0].length);

let steps = 0;

function boundLimitReached(visited, end) {
    const curSize = size(visited);
    // console.log({ curSize, bound, end, visited });
    return curSize >= bound ||
        (end && curSize + distance(visited.last, end) >= bound) ||
        curSize + (26 - level(terrain, visited.last)) >= bound ||
        false;
}

function traverse(terrain, end, visited) {
    // console.log({ visited });
    steps++;
    if (steps % 1000000 === 0) {
        console.log(size(visited), bound);
        steps = 0;
        dump(terrain, visited);
    }
    if (boundLimitReached(visited)) {
        return;
    }
    const current = visited.last;
    if (current[0] === end[0] && current[1] === end[1]) {
        console.log(`found path with length ${size(visited)}`);
        bound = size(visited);
        path = Object.assign({}, visited);
        return;
    }
    nextDirections(terrain, current, visited, end).forEach(next => {
        traverse(terrain, end, append(visited, next));
        unappend(visited, next, current);
    });
}

traverse(terrain, findSymbol(terrain, "E"), append({}, findSymbol(terrain, 'S')));

const part1 = size(path);
console.log(`Part 1: ${part1}`);
