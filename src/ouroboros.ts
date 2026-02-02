import { type ConfigParams, toConfig } from "./config.js"

const configParams: ConfigParams = {
  root: ".",
  sections: {
    tests: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: "generated",
      cleanFirst: true,
      debug: true,
    },
    main: {
      relativeInputPaths: ["src/config.ts"],
      relativeOutdir: "platformWorkerConfig",
      cleanFirst: true,
      debug: true,
    },
  },
}

export default toConfig(configParams)
