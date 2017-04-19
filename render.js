#!/usr/bin/env node
const argv = require("optimist").argv;

["arms", "tiles", "height", "width"].forEach(arg => {
  if (!argv[arg]) {
    console.error("need", arg);
    process.exit(1);
  }
});

const tag = `a${argv.arms}t${argv.tiles}w${argv.width}h${argv.height}`;
const name = `render-${tag}`;

require("shelljs/global");
set("-e");

mkdir("-p", "build");
cat("shader.glsl")
  .sed("float arms = 1.0;", `float arms = ${argv.arms}.0;`)
  .sed("float tiles = 4.0;", `float tiles = ${argv.tiles}.0;`)
  .to(`build/${name}.glsl`);

exec(
  [
    "./node_modules/.bin/shadertoy-export",
    `build/${name}.glsl`,
    `--output build/${name}.png`,
    `--size ${argv.width},${argv.height}`
  ].join(" ")
);
