import type { ConfigParams } from "./schema.js"

const configParams: ConfigParams = {
  root: ".",
  defaultElmCodegenParams: {
    relativeGeneratorModulePath: "codegen/GenerateZodBindings.elm",
    debug: true,
  },
  sections: {
    main: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: "./generated",
      cleanFirst: true,
    },
  },
}

export default configParams
