import { type ConfigParams, toConfig } from "./config.js"

const configParams: ConfigParams = {
  root: ".",
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
