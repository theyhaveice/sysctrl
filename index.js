const childPro = require("child_process");
const path = require("path");

const BIN = path.join(__dirname, "bin", process.platform === "darwin" ? "sysctrl-darwin" : "control");

function run(args) {
  return childPro.execFileSync(BIN, args, { encoding: "utf8" }).trim();
}

function mouse(id = 0) {
  const obj = {};

  Object.defineProperty(obj, "x", {
    get() {
      return parseInt(run(["--device=mouse", `--id=${id}`, "--action=getX"]), 10);
    }
  });

  Object.defineProperty(obj, "y", {
    get() {
      return parseInt(run(["--device=mouse", `--id=${id}`, "--action=getY"]), 10);
    }
  });

  Object.defineProperty(obj, "currentButton", {
    get() {
      return parseInt(run(["--device=mouse", `--id=${id}`, "--action=getButton"]), 10);
    }
  });

  obj.move = (x, y, options = {}) => {
    const opts = [];
    if (options.duration !== undefined) opts.push(`duration=${options.duration}`);
    if (options.easeIn !== undefined) opts.push(`easeIn=${options.easeIn}`);
    if (options.easeOut !== undefined) opts.push(`easeOut=${options.easeOut}`);
    const args = ["--device=mouse", `--id=${id}`, "--action=move", `--params=x=${x},y=${y}`];
    if (opts.length) args.push(`--options=${opts.join(",")}`);
    run(args);
  };

  obj.click = (button = 0, options = {}) => {
    const opts = [];
    if (options.clickAmount !== undefined) opts.push(`clickAmount=${options.clickAmount}`);
    if (options.timePerClick !== undefined) opts.push(`timePerClick=${options.timePerClick}`);
    const args = ["--device=mouse", `--id=${id}`, "--action=click", `--params=button=${button}`];
    if (opts.length) args.push(`--options=${opts.join(",")}`);
    run(args);
  };

  obj.mouseDown = (button = 0) => {
    run(["--device=mouse", `--id=${id}`, "--action=buttonDown", `--params=button=${button}`]);
  };

  obj.mouseUp = (button = 0) => {
    run(["--device=mouse", `--id=${id}`, "--action=buttonUp", `--params=button=${button}`]);
  };

  obj.scroll = (dx = 0, dy = 0, options = {}) => {
    const opts = [];
    if (options.duration !== undefined) opts.push(`duration=${options.duration}`);
    if (options.easeIn !== undefined) opts.push(`easeIn=${options.easeIn}`);
    if (options.easeOut !== undefined) opts.push(`easeOut=${options.easeOut}`);
    const args = ["--device=mouse", `--id=${id}`, "--action=scroll", `--params=dx=${dx},dy=${dy}`];
    if (opts.length) args.push(`--options=${opts.join(",")}`);
    run(args);
  };

  obj.drag = (x1, y1, x2, y2, button = 0, options = {}) => {
    const opts = [];
    if (options.duration !== undefined) opts.push(`duration=${options.duration}`);
    if (options.easeIn !== undefined) opts.push(`easeIn=${options.easeIn}`);
    if (options.easeOut !== undefined) opts.push(`easeOut=${options.easeOut}`);
    const args = [
      "--device=mouse",
      `--id=${id}`,
      "--action=drag",
      `--params=x1=${x1},y1=${y1},x2=${x2},y2=${y2},button=${button}`
    ];
    if (opts.length) args.push(`--options=${opts.join(",")}`);
    run(args);
  };

  return obj;
}

const screen = (id = 0) => {
  const obj = {};
  Object.defineProperty(obj, "width", {
    get() {
      return parseInt(run(["--device=screen", `--id=${id}`, "--action=getWidth"]), 10);
    }
  });
  Object.defineProperty(obj, "height", {
    get() {
      return parseInt(run(["--device=screen", `--id=${id}`, "--action=getHeight"]), 10);
    }
  });
  return obj;
};

module.exports = { mouse, screen };