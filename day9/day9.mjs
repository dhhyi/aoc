import readDataFromStdin from "../read-data.mjs";
const data = await readDataFromStdin()

const heads = [[0, 0]];

function newHead([x, y], direction) {
    switch (direction) {
        case "R":
            return [x + 1, y];
        case "L":
            return [x - 1, y];
        case "U":
            return [x, y - 1];
        case "D":
            return [x, y + 1];
    }
}

function newTail([tx, ty], [hx, hy]) {
    // no movement needed if adjacent
    if (Math.abs(hy - ty) <= 1 && Math.abs(hx - tx) <= 1) {
        return [tx, ty];
    }

    // vertical movement
    if (hx === tx) {
        if (hy > ty) {
            return [tx, ty + 1];
        } else {
            return [tx, ty - 1];
        }
    }

    // horizontal movement
    if (hy === ty) {
        if (hx > tx) {
            return [tx + 1, ty];
        } else {
            return [tx - 1, ty];
        }
    }

    // diagonal movement
    if (hx > tx) {
        if (hy > ty) {
            return [tx + 1, ty + 1];
        } else {
            return [tx + 1, ty - 1];
        }
    } else if (hx < tx) {
        if (hy > ty) {
            return [tx - 1, ty + 1];
        } else {
            return [tx - 1, ty - 1];
        }
    }

    // should never happen
    throw new Error(`Cannot calculate: T(${tx}, ${ty}) H(${hx}, ${hy})`)
}

for (const line of data.split("\n")) {
    const [, direction, num] = /^(R|L|U|D) (\d+)$/.exec(line);
    const times = parseInt(num, 10);
    // console.log({ direction, times });
    for (let i = 0; i < times; i++) {
        const newPosition = newHead(heads[heads.length - 1], direction);
        // console.log(newPosition);
        heads.push(newPosition);
    }
}

const tails = [heads, [[0, 0]], [[0, 0]], [[0, 0]], [[0, 0]], [[0, 0]], [[0, 0]], [[0, 0]], [[0, 0]], [[0, 0]]]

for (let i = 0; i < tails.length - 1; i++) {
    for (const head of tails[i]) {
        const oldPosition = tails[i + 1][tails[i + 1].length - 1];
        const newPosition = newTail(oldPosition, head);
        tails[i + 1].push(newPosition);
        // console.log('H', head, 'T', oldPosition, '->', newPosition);
    }
}

const part1 = tails[1].filter(([cx, cy], i, a) => {
    return a.findIndex(([x, y]) => x === cx && y === cy) === i;
}).length;
console.log("Part 1:", part1);

const part2 = tails[9].filter(([cx, cy], i, a) => {
    return a.findIndex(([x, y]) => x === cx && y === cy) === i;
}).length;
console.log("Part 2:", part2);
