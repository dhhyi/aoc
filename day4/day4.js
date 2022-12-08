const stdin = process.openStdin();
let data = "";
stdin.on("data", function (chunk) {
    data += chunk;
});

function range(start, end) {
    return Array(end - start + 1).fill().map((_, idx) => start + idx)
}

stdin.on("end", function () {
    const sections = data.trim().split("\n").map((line) => line.split(',').map((item) => item.split('-').map((item) => parseInt(item))).map(arr => range(arr[0], arr[1])));
    console.log(sections);

    const part1 = sections.map(([a, b]) => a.every(i => b.includes(i)) || b.every(i => a.includes(i))).filter(Boolean).length;
    console.log('part 1', part1);

    const part2 = sections.map(([a, b]) => a.some(i => b.includes(i)) || b.some(i => a.includes(i))).filter(Boolean).length;
    console.log('part 2', part2);
});
