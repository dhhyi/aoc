const stdin = process.openStdin();
let data = "";
stdin.on("data", function (chunk) {
    data += chunk;
});

function distictChars(n) {
    return (_, index, array) => {
        if (index >= n - 1) {
            const window = array.slice(index - (n - 1), index + 1);
            if (window.every((v, i, a) => a.indexOf(v) === i)) {
                return (index);
            }
        }
    }
}

stdin.on("end", function () {
    const signals = data.trim().split('\n');
    for (const line of signals) {
        console.log({ line });
        const marker = line.split('').findIndex(distictChars(4))
        console.log('part 1', marker + 1);
        const message = line.split('').findIndex(distictChars(14))
        console.log('part 2', message + 1);
    }
});
