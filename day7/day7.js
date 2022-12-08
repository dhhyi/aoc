const stdin = process.openStdin();
let data = "";
stdin.on("data", function (chunk) {
    data += chunk;
});

function calculateDirSize(dir) {
    let size = 0;
    for (const key in dir) {
        if (typeof dir[key] === "number") {
            size += dir[key];
        } else {
            size += calculateDirSize(dir[key]);
        }
    }
    return size;
}

function traverseDirs(dir, callback) {
    for (const key in dir) {
        if (typeof dir[key] === "object") {
            callback(key, dir[key]);
            traverseDirs(dir[key], callback);
        }
    }
}

stdin.on("end", function () {
    const root = {};
    let current;
    let parents = [];

    data.trimEnd().split("\n").forEach((line) => {
        if (line.startsWith("$ ")) {
            const command = line.slice(2);
            if (command.startsWith("cd ")) {
                const dir = command.slice(3);
                if (dir === "/") {
                    current = root;
                } else if (dir === "..") {
                    current = parents.pop();
                } else {
                    parents.push(current);
                    current = current[dir];
                }
            } else if (command === "ls") {
                // do nothing
            }
        } else {
            const dirPattern = /^dir (.+)$/
            const filePattern = /^([0-9]+) (.+)$/
            if (dirPattern.test(line)) {
                const dirName = dirPattern.exec(line)[1];
                current[dirName] = {};
            } else if (filePattern.test(line)) {
                const [, size, fileName] = filePattern.exec(line);
                current[fileName] = +size;
            }
        }
    });

    console.log({ '/': root })

    let part1 = 0;
    traverseDirs({ '/': root }, (_, dir) => {
        const size = calculateDirSize(dir);
        if (size <= 100000) {
            part1 += size;
        }
    });
    console.log('Part 1:', part1);

    const free = 70000000 - calculateDirSize(root);
    const needed = 30000000 - free;

    let sizeMin = calculateDirSize(root);
    traverseDirs({ '/': root }, (_, dir) => {
        const size = calculateDirSize(dir);
        if (size >= needed && size < sizeMin) {
            sizeMin = size;
        }
    });

    console.log('Part 2:', sizeMin);
});
