import { type ConfigParams, toConfig } from "./config.js"
import * as fs from "../lib/fs.js"
import path from "path"

const __dirname = fs.toModuleDir(import.meta.url)
const packageRoot = path.join(__dirname, "..")

const configParams: ConfigParams = {
  root: packageRoot,
  sections: {
    main: {
      relativeInputPaths: ["src/config.ts"],
      relativeOutdir: "platformWorkerConfig",
      cleanFirst: true,
      debug: true,
      outputModuleNamespace: [],
    },
  },
}

export default toConfig(configParams)
