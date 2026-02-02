import { type ConfigParams } from "./src/config.js"

const config: ConfigParams = {
  sections: {
    default: {
      relativeInputPaths: ["sampleSchema.ts"],
      relativeOutdir: "generated",
      outputModuleNamespace: ["Typewriter"],
    },
  },
}

export default config
