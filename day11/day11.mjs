import readDataFromStdin from "../read-data.mjs";

function dividable(num, divisor) {
    // console.log("dividable", num, divisor);
    // return !!primes(divisor).reduce((n, d) => n && n.includes(d) && n.splice(n.indexOf(d), 1) && n, [...num]);
    return num.includes(divisor)
}

const cache = {};

function primesCalc(num) {
    if (num === 0) {
        throw new Error('0 is not a valid input');
    }
    if (cache[num] !== undefined) {
        return [...cache[num]];
    }
    if (num === 1) {
        return [];
    }
    const primes = [];
    let n = num;
    for (let i = 2; i <= n; i++) {
        if (i === 2 && cache[n] !== undefined) {
            primes.push(...cache[n]);
            break;
        }
        // console.log(`testing for ${num}: ${primes} -- ${n} / ${i}`);
        if (n % i === 0) {
            primes.push(i);
            n = n / i;
            i = 1;
        }
    }
    cache[num] = [...primes];
    return primes;
}

function primes(num) {
    if (Array.isArray(num)) {
        return num;
    }
    return primesCalc(num);
}

function mult(nums, num) {
    return [...nums, ...primes(num)];
}

// function div(nums, divisor) {
//     return primes(divisor).reduce((n, d) => n && n.includes(d) && n.splice(n.indexOf(d), 1) && n, nums);
// }

function render(nums) {
    return nums.reduce((a, b) => a * b, 1);
}

function plus(nums, num) {
    const additions = primes(num);
    const newNums = [];
    const remainAdditions = [];
    for (const a of additions) {
        if (nums.includes(a)) {
            newNums.push(a);
            nums.splice(nums.indexOf(a), 1);
        } else {
            remainAdditions.push(a);
        }
    }
    // console.log({ newNums, remainAdditions, nums, render: `${render(remainAdditions)} + ${render(nums)}` });
    newNums.push(...primes(render(remainAdditions) + render(nums)))
    return newNums
}

// console.log("Primes of 100:", primes(100));
// console.log("Primes of 51:", primes(51));
// console.log("Primes of 8:", primes(8));
// console.log("Primes of 9:", primes(9));
// console.log("Primes of 10:", primes(10));
// console.log("Primes of 993869:", primes(993869));
// console.log("dividable 100:", dividable(primes(100), 2));
// console.log("dividable 100:", dividable(primes(100), 4));
// console.log("dividable 100:", dividable(primes(100), 10));
// console.log("dividable 100:", dividable(primes(100), 20));
// console.log("dividable 100:", dividable(primes(100), 11));
// console.log("mult 100 2:", mult(primes(100), 2));
// console.log("mult 100 10:", mult(primes(100), 10));
// console.log("mult 100 11:", mult(primes(100), 11));
// console.log("div 100:", div(primes(100), 2));
// console.log("div 100:", div(primes(100), 4));
// console.log("div 100:", div(primes(100), 5));
// console.log("div 100:", div(primes(100), 6));
// console.log("plus 100 2:", plus(primes(100), 2));
// console.log("plus 100 1:", plus(primes(100), 1));
// console.log("plus 100 10:", plus(primes(100), 10));
// console.log("plus 100 11:", plus(primes(100), 11));
// console.log("plus 8 8:", plus(primes(8), 8));
// console.log("plus 18 8:", plus(primes(18), 8));
// console.log("plus 6 4:", plus(primes(6), 4));
// console.log("plus 2080 6:", plus(primes(2080), 6));
// console.log("render:", render(primes(100)));
// console.log("render:", render(primes(101)));
// console.log("render:", render(primes(1)));


function readMonkeys(data) {
    const regex = /Monkey (?<monkey>\d+):\n  Starting items: (?<items>.*?)\n  Operation: new = old (?<operation>.) (?<argument>.*?)\n  Test: divisible by (?<test>\d+)\n    If true: throw to monkey (?<true>\d+)\n    If false: throw to monkey (?<false>\d+)/mgs

    const monkeys = {}

    for (let match; match = regex.exec(data);) {
        const monkey = {
            items: match.groups.items.split(', ').map(Number).map(primes),
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
                        return plus(old, num);
                    case '*':
                        return mult(old, num);
                    default:
                        throw new Error(`Unknown operation ${operation}`);
                }
            },
            test: (num) => {
                const t = dividable(num, Number(match.groups.test));
                return t ? match.groups.true : match.groups.false;
            },
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

    const unworry = item => {
        if (item < 3) throw new Error("Item too small");
        const newW = Math.trunc(render(item) / 3);
        return primes(newW)
    };

    for (let i = 0; i < 20; i++) {
        executeRound(monkeys, unworry)
    }

    const part1 = monkeyBusiness(monkeys);
    console.log("Part 1:", part1);
}

part1()

// const specialUnworry = item => item.filter((v, i, a) => a.indexOf(v) === i);
// const specialUnworry = item => {
//     return item.filter((v, i, a) => {
//         if (v === 2) {
//             const twos = a.map((v, i) => v === 2 && i).filter(v => v !== false).slice(0, 3);
//             return twos.includes(i);
//         };
//         return a.indexOf(v) === i
//     })
// }
const specialUnworry = item => [...new Set(item)]

console.log("Special unworry:", specialUnworry(primes(10000)));
console.log("Special unworry:", specialUnworry(primes(2 * 2 * 3 * 3 * 5 * 5)));

function part2() {
    const monkeys = readMonkeys(data);


    for (let i = 0; i < 20; i++) {
        executeRound(monkeys, specialUnworry)
        console.log("Round", i + 1);
        dump(monkeys)
    }

    const part2 = monkeyBusiness(monkeys);
    console.log("Part 2:", part2);
}

part2()
