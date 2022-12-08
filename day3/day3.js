const stdin = process.openStdin();
let data = "";
stdin.on("data", function (chunk) {
    data += chunk;
});

function prio(char) {
    if (char.charCodeAt(0) >= 97) {
        return char.charCodeAt(0) - 96;
    } else {
        return char.charCodeAt(0) - 65 + 27;
    }
}
['a', 'b', 'z', 'A', 'B', 'Z'].forEach((char) => {
    console.log(char, prio(char));
});

stdin.on("end", function () {
    const rucksacks = data
        .trim()
        .split("\n")
        .map((line) => {
            const a = line.substring(0, line.length / 2)
            const b = line.substring(line.length / 2)
            const e = a.split('').find(i => b.includes(i))
            return ({ a, b, e, p: prio(e) });
        })
    console.log({ rucksacks });

    const part1 = rucksacks.reduce((acc, { p }) => acc + p, 0);
    console.log('part 1', part1);

    const groups = data
        .trim()
        .split("\n").reduce((acc, l, i) => {
            if (i % 3 === 0) {
                acc.push([]);
            }
            acc[acc.length - 1].push(l);
            return acc;
        }, []).map(gr => {
            const b = gr[0].split('').find(i => gr[1].includes(i) && gr[2].includes(i));
            return ({ gr, b, p: prio(b) });
        })
    console.log({ groups });

    const part2 = groups.reduce((acc, { p }) => acc + p, 0);
    console.log('part 2', part2);
});
