const stdin = process.openStdin();
let data = '';
stdin.on('data', function (chunk) {
    data += chunk;
});

stdin.on('end', function () {
    const elves = data.trim().split('\n').reduce((acc, line) => {
        if (line !== '') {
            acc[acc.length - 1] += +line;
        } else {
            acc.push(0);
        }
        return acc;
    }, [0])
    console.log({ elves });
    console.log('part 1:', Math.max(...elves));

    const sorted = elves.sort((a, b) => b - a);
    console.log({ sorted });

    const topThree = sorted.slice(0, 3);
    console.log({ topThree })

    console.log('part 2:', topThree.reduce((acc, val) => acc + val));
})
