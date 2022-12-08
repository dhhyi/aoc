const stdin = process.openStdin();
let data = '';
stdin.on('data', function (chunk) {
    data += chunk;
});

const points1 = {
    //rock
    A: {
        //rock
        X: 1 + 3,
        //paper
        Y: 2 + 6,
        //scissors
        Z: 3 + 0
    },
    //paper
    B: {
        X: 1 + 0,
        Y: 2 + 3,
        Z: 3 + 6
    },
    //scissors
    C: {
        X: 1 + 6,
        Y: 2 + 0,
        Z: 3 + 3
    },
}

const points2 = {
    //rock
    A: {
        //lose
        X: 3 + 0,
        //draw
        Y: 1 + 3,
        //win
        Z: 2 + 6
    },
    //paper
    B: {
        X: 1 + 0,
        Y: 2 + 3,
        Z: 3 + 6
    },
    //scissors
    C: {
        X: 2 + 0,
        Y: 3 + 3,
        Z: 1 + 6
    },
}

stdin.on('end', function () {
    const lines = data.split('\n').filter(x => !!x).map(line => line.split(' '));
    const results1 = lines.map(line => {
        const [you, me] = line;
        return { me, you, points: points1[you][me] }
    })
    console.log({ results1 });
    const result1 = results1.reduce((acc, curr) => acc + curr.points, 0);
    console.log('part 1', result1);

    const results2 = lines.map(line => {
        const [you, me] = line;
        return { me, you, points: points2[you][me] }
    })
    console.log({ results2 });
    const result2 = results2.reduce((acc, curr) => acc + curr.points, 0);
    console.log('part 2', result2);
})
