function readDataFromStdin() {
    return new Promise((resolve, reject) => {
        let data = "";
        process.stdin.on("data", (chunk) => {
            data += chunk;
        });

        process.stdin.on("error", (err) => {
            reject(err);
        });

        process.stdin.on("end", () => {
            resolve(data.trimEnd());
        });
    });
}

export default readDataFromStdin;
