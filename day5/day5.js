const stdin = process.openStdin();
let data = "";
stdin.on("data", function (chunk) {
    data += chunk;
});

function createmover9000(stacks, num, from, to) {
    const newStack = { ...stacks };
    for (let n = 0; n < num; n++) {
        const elem = newStack[from][newStack[from].length - 1];
        const newArr = newStack[from].slice(0, newStack[from].length - 1);
        newStack[from] = newArr;
        newStack[to] = [...newStack[to], elem];
    }
    return newStack;
}

function createmover9001(stacks, num, from, to) {
    return {
        ...stacks,
        [from]: stacks[from].slice(0, stacks[from].length - num),
        [to]: [...stacks[to], ...stacks[from].slice(stacks[from].length - num)]
    };
}

stdin.on("end", function () {
    const [stacksInput, instructions] = data.split('\n\n').map((group) => group.split('\n'));
    console.log({ stacksInput, instructions });

    const stacks = stacksInput.reverse().reduce((acc, stack) => {
        if (acc === null) {
            const numOfStacks = ((stack.length + 2) / 4)
            acc = {}
            for (let i = 1; i <= numOfStacks; i++) {
                acc[i] = []
            }
        } else {
            for (let i = 1; i <= Object.keys(acc).length; i++) {
                const cha = stack[1 + (i - 1) * 4]?.trim()
                if (cha) {
                    acc[i].push(cha)
                }
            }
        }
        return acc
    }, null);
    console.log({ stacks });

    const newStacks = instructions.reduce((acc, instruction) => {
        const parsed = instruction.match(/move (?<num>\d+) from (?<from>\d+) to (?<to>\d+)/)?.groups;
        if (parsed) {
            const { num, from, to } = parsed;
            return createmover9000(acc, +num, from, to);
        }
        return acc;
    }, stacks)
    console.log({ newStacks });

    console.log('part 1', Object.values(newStacks).map((stack) => stack[stack.length - 1]).join(''));

    const newStacks2 = instructions.reduce((acc, instruction) => {
        const parsed = instruction.match(/move (?<num>\d+) from (?<from>\d+) to (?<to>\d+)/)?.groups;
        if (parsed) {
            const { num, from, to } = parsed;
            return createmover9001(acc, +num, from, to);
        }
        return acc;
    }, stacks)
    console.log({ newStacks2 });

    console.log('part 2', Object.values(newStacks2).map((stack) => stack[stack.length - 1]).join(''));
});
