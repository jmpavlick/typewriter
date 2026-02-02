import { type ConfigParams } from "@jmpavlick/typewriter"

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
