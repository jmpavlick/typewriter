import { type ConfigParams, toConfig } from "../src/config.js"

const configParams: ConfigParams = {
  root: ".",
  sections: {
    main: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: "generated",
      cleanFirst: true,
      debug: true,
      outputModuleNamespace: ["Tests", "SchemaVariants"],
    },
  },
}

export default toConfig(configParams)
