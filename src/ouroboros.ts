import { type ConfigParams, toConfig } from "./config.js"

const configParams: ConfigParams = {
  root: ".",
  sections: {
    tests: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: "generated",
      elmCodegenOverrides: {
        cleanFirst: true,
      },
    },
    main: {
      relativeInputPaths: [],
      relativeOutdir: "workerConfig",
      elmCodegenOverrides: {
        cleanFirst: true,
      },
    },
  },
}

export default toConfig(configParams)
