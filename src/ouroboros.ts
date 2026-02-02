import { type ConfigParams, toConfig } from "./config.js"

const configParams: ConfigParams = {
  root: ".",
  sections: {
    tests: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: "generated",
      cleanFirst: true,
      debug: true,
      outputModuleNamespace: ["IntegrationTests"],
    },
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
