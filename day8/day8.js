const stdin = process.openStdin();
let data = "";
stdin.on("data", function (chunk) {
    data += chunk;
});


stdin.on("end", function () {
    const trees = data.trimEnd().split("\n").map((line) => line.split("").map(x => parseInt(x, 10)))

    function directions(row, col) {
        const re = { n: [], e: [], s: [], w: [] }
        for (let r = row + 1; r < trees.length; r++) {
            re.s.push(trees[r][col]);
        }
        for (let r = row - 1; r >= 0; r--) {
            re.n.push(trees[r][col]);
        }
        for (let c = col + 1; c < trees[0].length; c++) {
            re.e.push(trees[row][c]);
        }
        for (let c = col - 1; c >= 0; c--) {
            re.w.push(trees[row][c]);
        }
        return re;
    }


    function visible(row, col) {
        const current = trees[row][col];
        return Object.values(directions(row, col)).some((direction) => direction.every(x => x < current))
    }

    function scenicScore(row, col) {
        const current = trees[row][col];
        const scores = Object.values(directions(row, col)).map((direction) => {
            const idx = direction.findIndex(x => x >= current);
            if (idx === -1) return direction;
            return direction.slice(0, idx + 1);
        });
        return scores.reduce((acc, cur) => acc * cur.length, 1);
    }

    let part1 = 0;
    let part2 = 0;

    trees.forEach((_, row) => {
        trees[row].forEach((_, col) => {
            const isVisible = visible(row, col);
            if (isVisible) part1++;

            const score = scenicScore(row, col);
            if (score > part2) part2 = score;

            const value = trees[row][col].toString();
            process.stdout.write(isVisible ? `\x1b[31m${value}\x1b[0m` : value);
        })
        process.stdout.write("\n");
    })

    console.log('Part 1:', part1);
    console.log('Part 2:', part2);
});
