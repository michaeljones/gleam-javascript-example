const chokidar = require("chokidar");
const stream = require("stream");

let gleamPlugin = {
    name: "gleam",
    setup(build) {
        const childProcess = require("child_process");
        let compilePromise = null;
        const buildDir = "build";
        build.onStart(() => {
            compilePromise = new Promise((resolve) => {
                console.log("Building");
                childProcess.exec(
                    `gleam compile-package --target javascript --name shine --src src --out ${buildDir}`,
                    (stdout, stderr) => {
                        // console.log(stdout);
                        // console.log(stderr);
                        resolve();
                    }
                );
            });
        });

        const cwd = process.cwd();
        build.onResolve({ filter: /.*\.gleam/ }, async (args) => {
            await compilePromise;
            return { path: `${cwd}/${buildDir}/${args.path.replace("gleam", "js")}` };
        });
    },
};

function watch(path) {
    const watchStream = new stream.PassThrough({ objectMode: true });

    const watcher = chokidar.watch(path);

    watcher.on("ready", () => {
        watcher.on("all", async (event, path) => {
            console.log(event, path);
            watchStream.write({ event, path });
        });
    });

    return watchStream;
}

async function start() {
    const result = await require("esbuild")
        .build({
            entryPoints: ["src/app.js"],
            bundle: true,
            incremental: true,
            outfile: "public/bundle.js",
            plugins: [gleamPlugin],
        })
        .catch((result) => result.stop());

    const watchStream = watch("src");
    for await (let entry of watchStream) {
        console.log("Rebuild", entry);
        await result.rebuild();
    }

    result.rebuild.dispose();
}

start();
