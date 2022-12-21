import readDataFromStdin from "../read-data.mjs";

function readMonkeys(data) {
    const regex = /Monkey (?<monkey>\d+):\n  Starting items: (?<items>.*?)\n  Operation: new = old (?<operation>.) (?<argument>.*?)\n  Test: divisible by (?<test>\d+)\n    If true: throw to monkey (?<true>\d+)\n    If false: throw to monkey (?<false>\d+)/mgs

    const monkeys = {}

    for (let match; match = regex.exec(data);) {
        const monkey = {
            items: match.groups.items.split(', ').map(Number),
            inspections: 0,
            inspect: (old) => {
                monkey.inspections++;

                const { operation, argument } = match.groups;

                let num
                if (argument === 'old') {
                    num = old;
                } else {
                    num = Number(argument);
                }

                switch (operation) {
                    case '+':
                        return old + num;
                    case '-':
                        return old - num;
                    case '*':
                        return old * num;
                    case '/':
                        return old / num;
                    default:
                        throw new Error(`Unknown operation ${operation}`);
                }
            },
            test: (num) => {
                const t = num % Number(match.groups.test) === 0;
                return t ? match.groups.true : match.groups.false;
            },
            div: Number(match.groups.test)
        }

        monkeys[match.groups.monkey] = monkey;
    }
    return monkeys;
}

function dump(monkeys) {
    Object.keys(monkeys).forEach((monkey) => {
        console.log(monkey, monkeys[monkey].inspections, monkeys[monkey].items);
    })
    console.log();
}

function executeRound(monkeys, worryreducer) {
    Object.keys(monkeys).forEach((monkey) => {
        const m = monkeys[monkey];
        while (m.items.length > 0) {
            const item = m.items.shift();
            const newLevel = m.inspect(item);
            const unworried = worryreducer(newLevel);
            const nextMonkey = m.test(unworried);
            monkeys[nextMonkey].items.push(unworried);
        }
    })
}

function monkeyBusiness(monkeys) {
    return Object.values(monkeys).map(m => m.inspections).sort((a, b) => b - a).slice(0, 2).reduce((a, b) => a * b);
}

const data = await readDataFromStdin()

function part1() {
    const monkeys = readMonkeys(data);

    for (let i = 0; i < 20; i++) {
        executeRound(monkeys, item => Math.trunc(item / 3))
    }

    const part1 = monkeyBusiness(monkeys);
    console.log("Part 1:", part1);
}

part1()


function part2() {
    const monkeys = readMonkeys(data);

    const diver = Object.values(monkeys).map(m => m.div).reduce((a, b) => a * b);
    const p2unworry = item => item % diver

    for (let i = 0; i < 10000; i++) {
        executeRound(monkeys, p2unworry)
    }
    dump(monkeys)

    const part2 = monkeyBusiness(monkeys);
    console.log("Part 2:", part2);
}

part2()
