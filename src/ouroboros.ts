import { type ConfigParams, toConfig } from "./config.js"

const configParams: ConfigParams = {
  root: ".",
  sections: {
    main: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: "./generated",
      cleanFirst: true,
    },
  },
}

export default toConfig(configParams)
