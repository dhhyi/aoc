import readDataFromStdin from "../read-data.mjs";
const data = await readDataFromStdin()

let x = 1;
const signals = []

data.split("\n").forEach(instruction => {
    const [command, arg] = instruction.split(" ");
    if (command === "noop") {
        signals.push(x);
    } else if (command === "addx") {
        signals.push(x);
        signals.push(x);
        x += Number(arg);
    } else {
        throw new Error(`Unknown command: ${command}`);
    }
});

const freqs = [20, 60, 100, 140, 180, 220]
const strengths = freqs.map(freq => signals[freq - 1] * freq)
const part1 = strengths.reduce((a, b) => a + b, 0)

console.log({ x, strengths })
console.log("Part 1:", part1)

// signals.forEach((level, index) => {
//     if (index < 10) {
//         console.log(index, level);
//     }
// })
signals.forEach((level, index) => {
    const calcIndex = index % 40;
    if (Math.abs(level - calcIndex) <= 1) {
        process.stdout.write("#");
    } else {
        process.stdout.write(".");
    }
    if ((index + 1) % 40 === 0) {
        process.stdout.write("\n");
    }
});
